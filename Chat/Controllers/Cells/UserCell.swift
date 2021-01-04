//
//  UserCell.swift
//  Chat
//
//  Created by User on 14.12.2020.
//

import UIKit
import SDWebImage

class UserCell: UICollectionViewCell, SelfConfiguringCell {
    
    static var reuseId: String = "UserCell"
    let userImageView = UIImageView()
    let userNameLabel = UILabel(withText: "Evgeny", font: .laoSangamMN20())
    let containerView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        backgroundColor = .white
        self.layer.cornerRadius = 4
        
        self.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    
    override func prepareForReuse() {
        userImageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.layer.cornerRadius = 4
        self.containerView.clipsToBounds = true
    }
    
    func configure<U>(with value: U) where U : Hashable {
        guard let user: ChatUser = value as? ChatUser else { return }
        userNameLabel.text = user.username
        guard let url = URL(string: user.avatarStringURL) else { return }
        userImageView.sd_setImage(with: url, completed: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(containerView)
        containerView.addSubview(userImageView)
        containerView.addSubview(userNameLabel)
        
        containerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        userImageView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        userImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        userImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        userImageView.heightAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        
        userNameLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor).isActive = true
        userNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8).isActive = true
        userNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8).isActive = true
        userNameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
    }
}
