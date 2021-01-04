//
//  ChatsViewController.swift
//  Chat
//
//  Created by User on 30.12.2020.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore

class ChatsViewController: MessagesViewController {

    private let user: ChatUser
    private let chat: Chat
    private var messageListener: ListenerRegistration?
    private var messages: [Message] = []
    init(user: ChatUser, chat: Chat) {
        self.user = user
        self.chat = chat
        super.init(nibName: nil, bundle: nil)
        title = chat.friendName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        messageListener?.remove()
    }
    //MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInputTextField()
        messagesCollectionView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        //Fixing ofsets
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.photoMessageSizeCalculator.incomingAvatarSize = .zero
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
        }
        //MARK: Setup Listener
        messageListener = ListenerService.shared.messagesObserve(chat: chat, completion: { (result) in
            switch result {
            case .success(var message):
                if let url = message.downloadURL {
                    FirebaseStorageService.shared.downloadImage(url: url) { [weak self](result) in
                        guard let self = self else {return}
                        switch result {
                        case .success(let image):
                            message.image = image
                            self.insertNewMessage(message: message)
                        case .failure(let error):
                            self.showAlert(withTitle: "Error", withMessage: error.localizedDescription)
                        }
                    }
                }else {
                self.insertNewMessage(message: message)
                }
            case .failure(let error):
                self.showAlert(withTitle: "Error", withMessage: error.localizedDescription)
            }
        })
    }
    
    private func insertNewMessage(message: Message) {
        guard !messages.contains(message) else {return}
        messages.append(message)
        messages.sort()
        let isLatestMessage = messages.lastIndex(of: message) == messages.count - 1
        let shouldScrollToBottom = isLatestMessage && messagesCollectionView.isAtBottom
        messagesCollectionView.reloadData()
        if shouldScrollToBottom {
            DispatchQueue.main.async {
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }

}
//MARK: Configure TextField
extension ChatsViewController {
    func configureInputTextField() {
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.backgroundView.backgroundColor = .mainWhite()
        messageInputBar.inputTextView.backgroundColor = .white
        messageInputBar.inputTextView.placeholderTextColor = #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 14, left: 30, bottom: 14, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 14, left: 36, bottom: 14, right: 36)
        messageInputBar.inputTextView.layer.borderColor = #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 0.4033635232)
        messageInputBar.inputTextView.layer.borderWidth = 0.2
        messageInputBar.inputTextView.layer.cornerRadius = 18.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        
        
        messageInputBar.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        messageInputBar.layer.shadowRadius = 5
        messageInputBar.layer.shadowOpacity = 0.3
        messageInputBar.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        configureSendButton()
        configureCameraIcon()
    }
    
    func configureSendButton() {
        messageInputBar.sendButton.setImage(UIImage(named: "Sent"), for: .normal)
        messageInputBar.sendButton.applyGradient(cornerRadius: 10)
        messageInputBar.setRightStackViewWidthConstant(to: 56, animated: false)
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 6, right: 30)
        messageInputBar.sendButton.setSize(CGSize(width: 48, height: 48), animated: false)
        messageInputBar.middleContentViewPadding.right = -38
    }
    func configureCameraIcon() {
        let cameraItem = InputBarButtonItem(type: .system)
        cameraItem.tintColor = .systemPurple
        let cameraImage = UIImage(systemName: "camera")!
        cameraItem.image = cameraImage
        cameraItem.addTarget(self, action: #selector(cameraAction), for: .primaryActionTriggered)
        cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)
    }
    @objc func cameraAction() {
        let picker = UIImagePickerController()
        picker.delegate = self
        let alertController = UIAlertController(title: "Choose source", message: "", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
        }
        let libraryAction =  UIAlertAction(title: "Library", style: .default) { (_) in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        }
        alertController.addAction(cameraAction)
        alertController.addAction(libraryAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
//MARK: MessagesDataSource
extension ChatsViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return Sender(senderId: user.id
                      ,displayName: user.username)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.item]
    }
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return 1
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.item % 10 == 0 {
        return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                                  attributes: [
                                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                                    NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }else {
            return nil
        }
    }
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.item % 10 == 0 {
        return 30
        }else {
            return 0
        }
    }
    
}
//MARK: MessagesLayoutDelegate
extension ChatsViewController:MessagesLayoutDelegate {
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
}
extension ChatsViewController:MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white: .systemPurple
    }
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .black : .white
    }
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
        avatarView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .bubble
    }
}
//MARK: InputBarAccessoryViewDelegate
extension ChatsViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = Message(user: user, content: text)
        FireStoreService.shared.sendMessage(chat: chat, message: message) { (result) in
            switch result {
            case .success():
                self.messagesCollectionView.scrollToBottom()
            case .failure(let error):
                self.showAlert(withTitle: "Error", withMessage: error.localizedDescription)
            }
        }
        inputBar.inputTextView.text = ""
    }
}
//MARK: UIImagePickerControllerDelegate
extension ChatsViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {return}
        sendImage(image: image)
    }
    private func sendImage(image: UIImage) {
        FirebaseStorageService.shared.uploadImageMessage(image: image, toChat: chat) { (result) in
            switch result {
            
            case .success(let url):
                var imageMessage = Message(user: self.user, image: image)
                imageMessage.downloadURL = url
                FireStoreService.shared.sendMessage(chat: self.chat, message: imageMessage) { (result) in
                    switch result {
                    
                    case .success():
                        self.messagesCollectionView.scrollToBottom()
                    case .failure(let error):
                        self.showAlert(withTitle: "Error", withMessage: error.localizedDescription)
                    }
                }
            case .failure(let error):
                self.showAlert(withTitle: "Error", withMessage: error.localizedDescription)
            }
        }
    }
}
