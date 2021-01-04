//
//  Message.swift
//  Chat
//
//  Created by User on 30.12.2020.
//

import UIKit
import FirebaseFirestore
import MessageKit

struct ImageItem :MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct Message: Hashable,MessageType {
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate == rhs.sentDate
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(messageId)
    }
    var sender: SenderType
    var messageId: String {
        return self.id ?? UUID().uuidString
    }
    var sentDate: Date
    let content: String
    let id: String?
    
    var kind: MessageKind {
        if let image = self.image {
            let mediaItem = ImageItem(url: nil, image: nil, placeholderImage: image, size: image.size)
            return .photo(mediaItem)
        }else {
            return .text(content)
        }
    }
    var image: UIImage? = nil
    var downloadURL: URL? = nil
    init(user: ChatUser, content: String) {
        self.sender = Sender(senderId: user.id, displayName: user.username)
        sentDate = Date()
        self.content = content
        id = nil
    }
    init(user: ChatUser, image: UIImage) {
        self.sender = Sender(senderId: user.id, displayName: user.username)
        self.image = image
        self.content = ""
        self.id = nil
        self.sentDate = Date()
    }
    
    init? (document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let senderId = data["senderId"] as? String,
              let senderName = data["senderName"] as? String,
              let sentDate = data["sentDate"] as? Timestamp
        else {return nil}
        
        if let content = data["content"] as? String {
            self.content = content
            self.downloadURL = nil
        }else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            self.downloadURL = url
            self.content = ""
        }else {
            return nil
        }
       
        self.sender = Sender(senderId: senderId, displayName: senderName)
        self.sentDate = sentDate.dateValue()
        self.id = document.documentID
    }
    
    var representation: [String: Any]  {
        var rep: [String: Any] = [
            "senderId":sender.senderId,
            "senderName":sender.displayName,
            "sentDate":sentDate,
        ]
        if let url = self.downloadURL {
            rep["url"] = url.absoluteString
        }else {
            rep["content"] = content
        }
        return rep
    }
}

extension Message: Comparable {
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
    
    
}
