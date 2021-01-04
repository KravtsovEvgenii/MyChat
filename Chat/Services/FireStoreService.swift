//
//  FireStoreService.swift
//  Chat
//
//  Created by User on 22.12.2020.
//

import Firebase
import FirebaseFirestore

class FireStoreService {
    static let shared = FireStoreService()
    let db = Firestore.firestore()
    
    private var users: CollectionReference {
        return db.collection("users")
    }
    var currentUser: ChatUser!
    
    private var waitingChatsRef: CollectionReference {
        return db.collection(["users", currentUser.id, "waitingChats"].joined(separator: "/"))
    }
    
    private var activeChatsRef: CollectionReference {
        return db.collection(["users", currentUser.id, "activeChats"].joined(separator: "/"))
    }
    
    func getUserData(user: User, completion: @escaping (Result<ChatUser,Error>) -> ()) {
        let userDoc = users.document(user.uid)
        userDoc.getDocument { (snapshot, error) in
            if let snapshot = snapshot, snapshot.exists {
                guard let chatUser = ChatUser(snapshot: snapshot) else {
                    completion(.failure(UserError.cannotCastToChatUser))
                    return
                }
                self.currentUser = chatUser
                completion(.success(chatUser))
            }   else {
                completion(.failure(UserError.cannotGetUserInfo))
            }
        }
    }
    func saveProfile(id: String,email:String, username: String?, avatarImage: UIImage?, description: String?, sex: String?, completion: @escaping (Result<ChatUser,Error>) -> ()) {
        guard Validators.isFilled(username: username, sex: sex, description: description) else {
            completion(.failure(UserError.notFilled))
            return
        }
        guard avatarImage != #imageLiteral(resourceName: "avatar") else {
            completion(.failure(UserError.photoNotExist))
            return
        }
        
        var user = ChatUser(username: username!,
                            email: email,
                            avatarStringURL: "default",
                            description: description! ,
                            sex: sex!,
                            id: id)
        FirebaseStorageService.shared.upload(image: avatarImage!) { (result) in
            switch result {
            
            case .success(let url):
                user.avatarStringURL = url.absoluteString
                self.users.document(user.id).setData(user.representation) { (error) in
                    if let error = error {
                        completion(.failure(error))
                    }else{
                        completion(.success(user))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        
    }
    
    
    
    func createWaitingChat(message: String, reciever: ChatUser, completion: @escaping (Result<Void,Error>)->()) {
        let reference = db.collection(["users",reciever.id,"waitingChats"].joined(separator: "/"))
        let messageReference = reference.document(self.currentUser.id).collection("messages")
        let message = Message(user: currentUser, content: message)
        let chat = Chat(friendName: currentUser.username, friendImageString: currentUser.avatarStringURL, friendId: currentUser.id, lastMessage: message.content)
        reference.document(currentUser.id).setData(chat.representation) { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            messageReference.addDocument(data: message.representation) { (error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
        }
    }
    
    func deleteWaitingChat(chat: Chat, completion: @escaping (Result<Void, Error>) -> Void) {
        waitingChatsRef.document(chat.friendId).delete { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            self.deleteMessages(chat: chat, completion: completion)
        }
    }
    
    func deleteMessages(chat: Chat, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = waitingChatsRef.document(chat.friendId).collection("messages")
        
        getWaitingChatMessages(chat: chat) { (result) in
            switch result {
                
            case .success(let messages):
                for message in messages {
                    guard let documentId = message.id else { return }
                    let messageRef = reference.document(documentId)
                    messageRef.delete { (error) in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        completion(.success(Void()))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getWaitingChatMessages(chat: Chat, completion: @escaping (Result<[Message], Error>) -> Void) {
        let reference = waitingChatsRef.document(chat.friendId).collection("messages")
        var messages = [Message]()
        reference.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            for document in querySnapshot!.documents {
                guard let message = Message(document: document) else { return }
                messages.append(message)
            }
            completion(.success(messages))
        }
    }
    
    func changeToActive(chat: Chat, completion:@escaping (Result<Void,Error>)->()) {
        getWaitingChatMessages(chat: chat) { (result) in
            switch result {
            case .success(let messages):
                self.deleteWaitingChat(chat: chat) { (result) in
                    switch result {
                    case .success():
                        self.createActiveChat(chat: chat, messages: messages) { (result) in
                            switch result {
                            case .success():
                                completion(.success(()))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    func createActiveChat(chat: Chat, messages: [Message], completion:@escaping (Result<Void,Error>)->()) {
        let messageRef = activeChatsRef.document(chat.friendId).collection("messages")
        activeChatsRef.document(chat.friendId).setData(chat.representation) { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            for message in messages {
                messageRef.addDocument(data: message.representation) { (error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                }
                completion(.success(()))
            }
            
        }
    }
    
    func sendMessage(chat: Chat, message: Message, completion: @escaping (Result<Void, Error>) -> Void) {
        let friendRef = users.document(chat.friendId).collection("activeChats").document(currentUser.id)
        let friendMessageRef = friendRef.collection("messages")
        let myMessageRef = users.document(currentUser.id).collection("activeChats").document(chat.friendId).collection("messages")
        
        let chatForFriend = Chat(friendName: currentUser.username,
                                 friendImageString: currentUser.avatarStringURL,
                                 friendId: currentUser.id,
                                 lastMessage: message.content)
        friendRef.setData(chatForFriend.representation) { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            friendMessageRef.addDocument(data: message.representation) { (error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                myMessageRef.addDocument(data: message.representation) { (error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(Void()))
                }
            }
        }
    }
}
