//
//  ChatRequestViewController.swift
//  Chat
//
//  Created by User on 18.12.2020.
//

import UIKit

class ChatRequestViewController: UIViewController {
    let contentView = UIView()
    let imageView = UIImageView(withImage: #imageLiteral(resourceName: "human3"), contendMode: .scaleAspectFill)
    let nameLabel = UILabel(withText: "TGW - Please", font: .systemFont(ofSize: 20, weight: .light))
    let aboutMeLabel = UILabel(withText: "We will be counting stars", font: .systemFont(ofSize: 16, weight: .light))
    let acceptButton = UIButton(withTitle: "Accept", backgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), titleColor: .white, font: UIFont.laoSangamMN20(),isShadow: false,cornerRadius: 10)
    let denyButton = UIButton(withTitle: "Deny", backgroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), titleColor: .systemRed, font: UIFont.laoSangamMN20(),isShadow: false,cornerRadius: 10)
    
    weak var delegate: WaitingChatsNavigationDelegate?
    private var currentChat: Chat
    
    init(chat: Chat) {
        self.currentChat = chat
        self.imageView.sd_setImage(with: URL(string: chat.friendImageString), completed: nil)
        self.nameLabel.text = chat.friendName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeElements()
        setupConstraints()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        acceptButton.applyGradient(cornerRadius: 10)
    }
    
}

extension ChatRequestViewController {
    private func setupConstraints() {
        view.addSubview(imageView)
        view.addSubview(contentView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(aboutMeLabel)
        
        let buttonsStackView = UIStackView(arrangeSubviews: [acceptButton,denyButton], axis: .horizontal, spacing: 10)
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(buttonsStackView)
        
        denyButton.layer.borderWidth = 1.2
        denyButton.layer.borderColor = UIColor.systemRed.cgColor
        
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.topAnchor, constant: 30).isActive = true
        
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: 206).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 24).isActive = true
        
        aboutMeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10).isActive = true
        aboutMeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
        aboutMeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 24).isActive = true
        
        buttonsStackView.topAnchor.constraint(equalTo: aboutMeLabel.bottomAnchor, constant: 20).isActive = true
        buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
        buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 24).isActive = true
        buttonsStackView.heightAnchor.constraint(equalToConstant: 58).isActive = true
        
       
        
    }
    private func customizeElements() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutMeLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutMeLabel.numberOfLines = 0
        contentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        contentView.layer.cornerRadius = 30
        
        denyButton.addTarget(self, action: #selector(denyAction), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(acceptAction), for: .touchUpInside)
    }
    @objc private func denyAction() {
        self.dismiss(animated: true) {
            self.delegate?.removeWaitingChat(chat: self.currentChat)
        }
    }
    
    @objc private func acceptAction() {
        self.dismiss(animated: true) {
            self.delegate?.changeChatToActive(chat: self.currentChat)
        }
    }
    
    @objc private func sendMessage() {
        print(#function)
    }
}
