//
//  Model.swift
//  Chat
//
//  Created by User on 06.12.2020.
//

import Foundation
import  UIKit
import FirebaseFirestore

struct Chat: Hashable,Decodable {
    init(friendName: String, friendImageString: String, friendId: String, lastMessage: String) {
        self.friendName = friendName
        self.friendImageString = friendImageString
        self.friendId = friendId
        self.lastMessage = lastMessage
    }
    var friendName: String
    var friendImageString: String
    var friendId : String
    var lastMessage: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(friendId)
    }
    static func == (lhs: Chat,rhs: Chat) -> Bool {
        return lhs.friendId == rhs.friendId
    }
    
    var representation: [String: Any] {
        var rep = ["friendName": friendName]
        rep["friendImageString"] = friendImageString
        rep["friendId"] = friendId
        rep["lastMessage"] = lastMessage
        return rep
    }
    
    
    init?(snapshot: QueryDocumentSnapshot) {
        let data = snapshot.data()
        guard let friendName = data["friendName"] as? String,
              let friendImageString = data["friendImageString"]  as? String,
              let friendId = data["friendId"] as? String,
              let lastMessage = data["lastMessage"] as? String
        else {
            return nil
        }
        self.friendName = friendName
        self.friendImageString = friendImageString
        self.friendId = friendId
        self.lastMessage = lastMessage
        
    }
}


struct ChatUser: Hashable,Decodable {
    var username: String
    var email: String
    var avatarStringURL: String
    var description: String
    var sex: String
    var id: String
    
    var representation: [String: Any] {
        var rep = ["username": username]
        rep["email"] = email
        rep["avatarStringURL"] = avatarStringURL
        rep["description"] = description
        rep["sex"] = sex
        rep["uid"] = id
        return rep
    }
    
    init(username: String, email: String, avatarStringURL: String, description: String ,sex: String, id: String) {
        self.username = username
        self.email = email
        self.avatarStringURL = avatarStringURL
        self.description = description
        self.sex = sex
        self.id = id
    }
    
    init?(snapshot: DocumentSnapshot) {
        guard let data = snapshot.data() else {return nil}
        guard let username = data["username"] as? String,
              let email = data["email"]  as? String,
              let description = data["description"] as? String,
              let sex = data["sex"] as? String,
              let id = data["uid"] as? String,
              let avatarStringURL = data["avatarStringURL"] as? String
        else {
            return nil
        }
        self.username = username
        self.email = email
        self.description = description
        self.id = id
        self.sex = sex
        self.avatarStringURL = avatarStringURL
    }
    init?(snapshot: QueryDocumentSnapshot) {
        let data = snapshot.data()
        guard let username = data["username"] as? String,
              let email = data["email"]  as? String,
              let description = data["description"] as? String,
              let sex = data["sex"] as? String,
              let id = data["uid"] as? String,
              let avatarStringURL = data["avatarStringURL"] as? String
        else {
            return nil
        }
        self.username = username
        self.email = email
        self.description = description
        self.id = id
        self.sex = sex
        self.avatarStringURL = avatarStringURL
    }
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: ChatUser,rhs: ChatUser) -> Bool {
        return lhs.id == rhs.id
    }
    
    func contains(text: String?) -> Bool {
        guard let text = text, !text.isEmpty else {return true}
        let lowerText = text.lowercased()
        return username.lowercased().contains(lowerText)
    }
}
