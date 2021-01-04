//
//  ProfileViewController.swift
//  Chat
//
//  Created by User on 15.12.2020.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController {
    
    let contentView = UIView()
    let imageView = UIImageView(withImage: #imageLiteral(resourceName: "human10"), contendMode: .scaleAspectFill)
    let nameLabel = UILabel(withText: "TGW - Please", font: .systemFont(ofSize: 20, weight: .light))
    let aboutMeLabel = UILabel(withText: "We will be counting stars", font: .systemFont(ofSize: 16, weight: .light))
    let textField = InsertabletextField()
    
    private var user: ChatUser
    
    init(user: ChatUser) {
        self.user = user
        self.nameLabel.text = user.username
        self.imageView.sd_setImage(with: URL(string: user.avatarStringURL), completed: nil)
        self.aboutMeLabel.text = user.description
        super.init(nibName: nil, bundle: nil)
        textField.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeElements()
        setupConstraints()
    }
    
}

extension ProfileViewController {
    private func setupConstraints() {
        view.addSubview(imageView)
        view.addSubview(contentView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(aboutMeLabel)
        contentView.addSubview(textField)
        
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
        
        textField.topAnchor.constraint(equalTo: aboutMeLabel.bottomAnchor, constant: 10).isActive = true
        textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
        textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 24).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        
        
    }
    private func customizeElements() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutMeLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        aboutMeLabel.numberOfLines = 0
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 30
        
        if let button = textField.rightView as? UIButton {
            button.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        }
    }
    @objc private func sendMessage() {
        guard let message = textField.text, message != "" else {return}
        self.dismiss(animated: true) {
            FireStoreService.shared.createWaitingChat(message: message, reciever: self.user) { (result) in
                switch result {
                
                case .success():
                    UIApplication.getTopViewController()?.showAlert(withTitle: "Success", withMessage: "Message delivered to \(self.user.username)")
                case .failure(let error):
                    UIApplication.getTopViewController()?.showAlert(withTitle: "Error", withMessage: error.localizedDescription)
                }
            }
        }
    }
}

extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}
//MARK: Canvas setup
//import SwiftUI
//struct ProfileViewControllerProvider: PreviewProvider {
//
//    static var previews: some View {
//        ContainerView().edgesIgnoringSafeArea(.all)
//    }
//
//    struct ContainerView: UIViewControllerRepresentable{
//        typealias UIViewControllerType = ProfileViewController
//
//        func makeUIViewController(context: Self.Context) -> Self.UIViewControllerType{
//            return ProfileViewController(user: ChatUser(username: "", email: "", avatarStringURL: "", description: "", sex: "", id: ""))
//        }
//        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
//
//        }
//    }
//}
