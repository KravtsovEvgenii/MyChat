//
//  ListenerService.swift
//  Chat
//
//  Created by User on 27.12.2020.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore


class ListenerService {
    static let shared = ListenerService()
    
    private let dataBase = Firestore.firestore()
    
    private var usersRef: CollectionReference  {
        return dataBase.collection("users")
    }
    private var currentUserId: String {
        return Auth.auth().currentUser!.uid
    }
    
    func usersObserve(users: [ChatUser], completion: @escaping (Result<[ChatUser],Error>)->()) -> ListenerRegistration? {
        var chatUsers = users
        let usersListener = usersRef.addSnapshotListener { (snapshot, error) in
            guard let querySnapshot = snapshot else {
                completion(.failure(error!))
                return
            }
            querySnapshot.documentChanges.forEach { (difference) in
                guard let chatUser = ChatUser(snapshot: difference.document) else {
                    completion(.failure(error ?? AuthError.unknownError))
                    return
                }
                switch difference.type {
                
                case .added:
                    guard  !chatUsers.contains(chatUser) else {return}
                    guard chatUser.id != self.currentUserId else {return}
                    chatUsers.append(chatUser)
                case .modified:
                    guard let index = chatUsers.firstIndex(of: chatUser) else {return}
                    chatUsers[index] = chatUser
                case .removed:
                    guard let index = chatUsers.firstIndex(of: chatUser) else {return}
                    chatUsers.remove(at: index)
                }
            }
            completion(.success(chatUsers))
        }
        
        return usersListener
    }
    
    
    func waitingChatsObserve(chats: [Chat], completion: @escaping (Result<[Chat],Error>)->()) -> ListenerRegistration? {
        var tempChats = chats
        let chatsReference = dataBase.collection(["users",currentUserId,"waitingChats"].joined(separator: "/"))
        let listener = chatsReference.addSnapshotListener { (snapshot, error) in
            guard let querySnapshot = snapshot else {
                completion(.failure(error!))
                return
            }
            querySnapshot.documentChanges.forEach { (difference) in
                guard let chat = Chat(snapshot: difference.document) else {
                    completion(.failure(error ?? AuthError.unknownError))
                    return
                }
                switch difference.type {
                
                case .added:
                    guard  !tempChats.contains(chat) else {return}
                    tempChats.append(chat)
                case .modified:
                    guard let index = tempChats.firstIndex(of: chat) else {return}
                    tempChats[index] = chat
                case .removed:
                    guard let index = tempChats.firstIndex(of: chat) else {return}
                    tempChats.remove(at: index)
                }
            }
            completion(.success(tempChats))
        }
        return listener
    }
    
    
    func activeChatsObserve(chats: [Chat], completion: @escaping (Result<[Chat],Error>)->()) -> ListenerRegistration? {
        var tempChats = chats
        let chatsReference = dataBase.collection(["users",currentUserId,"activeChats"].joined(separator: "/"))
        let listener = chatsReference.addSnapshotListener { (snapshot, error) in
            guard let querySnapshot = snapshot else {
                completion(.failure(error!))
                return
            }
            querySnapshot.documentChanges.forEach { (difference) in
                guard let chat = Chat(snapshot: difference.document) else {
                    completion(.failure(error ?? AuthError.unknownError))
                    return
                }
                switch difference.type {
                
                case .added:
                    guard  !tempChats.contains(chat) else {return}
                    tempChats.append(chat)
                case .modified:
                    guard let index = tempChats.firstIndex(of: chat) else {return}
                    tempChats[index] = chat
                case .removed:
                    guard let index = tempChats.firstIndex(of: chat) else {return}
                    tempChats.remove(at: index)
                }
            }
            completion(.success(tempChats))
        }
        return listener
    }
    
    func messagesObserve(chat: Chat, completion: @escaping (Result<Message,Error>)->())-> ListenerRegistration? {
        let ref = usersRef.document(currentUserId).collection("activeChats").document(chat.friendId).collection("messages")
        let messagesListener = ref.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            
            snapshot.documentChanges.forEach { (diff) in
                guard let message = Message(document: diff.document) else { return }
                switch diff.type {
                case .added:
                    completion(.success(message))
                case .modified:
                    break
                case .removed:
                    break
                }
            }
        }
        return messagesListener
    }
}
