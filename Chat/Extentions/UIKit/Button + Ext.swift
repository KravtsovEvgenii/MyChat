//
//  Button + Ext.swift
//  Chat
//
//  Created by User on 02.12.2020.
//

import Foundation
import UIKit

extension UIButton {
    convenience init (withTitle title: String,
                      backgroundColor: UIColor,
                      titleColor: UIColor,
                      font: UIFont? = .avenir20(),
                      isShadow: Bool = false,
                      cornerRadius: CGFloat = 4){
        //
        self.init(type:.system)
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.backgroundColor = backgroundColor
        self.titleLabel?.font = font
        self.layer.cornerRadius = cornerRadius
        
        if isShadow {
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowRadius = 4
            self.layer.shadowOffset = CGSize(width: 0, height: 4)
            //блик
            self.layer.shadowOpacity = 0.2
        }
        
    }
    
    func setupGoogleButton() {
        let googleLogo = UIImageView(withImage: #imageLiteral(resourceName: "googleLogo"), contendMode: .scaleAspectFit)
        googleLogo.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(googleLogo)
        googleLogo.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24).isActive = true
        googleLogo.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
}
