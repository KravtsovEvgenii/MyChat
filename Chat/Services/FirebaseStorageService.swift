//
//  FirebaseStorageService.swift
//  Chat
//
//  Created by User on 24.12.2020.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class FirebaseStorageService {
    static let shared = FirebaseStorageService()
    let storageRef = Storage.storage().reference()
    //ссылка на папку аватарок
    private var avatarsRef :StorageReference {
        return storageRef.child("avatars")
    }
    private var chatsRef :StorageReference {
        return storageRef.child("chats")
    }
    //так как использование данного метода подразумевается в экране настройки профиля то мы гарантируем что юзер есть, поэтому можем принудительно извлечь его.
    private var currentUserId: String {
        return Auth.auth().currentUser!.uid
    }
    
    func upload(image: UIImage, completion: @escaping (Result<URL, Error>) -> ()){
        //Сжимаем изображение
        guard let scaledImage = image.scaledToSafeUploadSize, let imageData = scaledImage.jpegData(compressionQuality: 0.4) else {return}
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        avatarsRef.child(currentUserId).putData(imageData, metadata: metaData) { (metaData, error) in
            guard  metaData != nil else {
                completion(.failure(error!))
                return
            }
            self.avatarsRef.child(self.currentUserId).downloadURL { (url, error) in
                guard let downloadURL = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(downloadURL))
            }
        }
    }
    
    func uploadImageMessage(image: UIImage, toChat chat: Chat, completion: @escaping (Result<URL,Error>)-> Void) {
        guard let scaledImage = image.scaledToSafeUploadSize, let imageData = scaledImage.jpegData(compressionQuality: 0.4) else {return}
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        let imageName = [UUID().uuidString,String(Date().timeIntervalSince1970)].joined()
        let uid = Auth.auth().currentUser?.uid ?? "default"
        let chatName = [chat.friendName,uid].joined()
        self.chatsRef.child(chatName).child(imageName).putData(imageData, metadata: metaData) { (metaData, error) in
            guard  metaData != nil else {
                completion(.failure(error!))
                return
            }
            
            self.chatsRef.child(chatName).child(imageName).downloadURL { (url, error) in
                guard let downloadUrl = url  else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(downloadUrl))
            }
        }
    }
    
    func downloadImage(url: URL, completion: @escaping (Result<UIImage?,Error>)-> Void) {
        let ref = Storage.storage().reference(forURL: url.absoluteString)
        ref.getData(maxSize: Int64(1064 * 1064 * 5)) { (data, error) in
            if let imageData = data {
                completion(.success(UIImage(data: imageData)))
            }else {
                completion(.failure(error ?? AuthError.unknownError))
            }
        }
    }
}
