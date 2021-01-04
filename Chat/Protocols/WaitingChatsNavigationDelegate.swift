//
//  WaitingChatsNavigationDelegate.swift
//  Chat
//
//  Created by User on 30.12.2020.
//

import Foundation
 
protocol WaitingChatsNavigationDelegate: class {
    func removeWaitingChat(chat: Chat)
    func changeChatToActive(chat: Chat)
}
