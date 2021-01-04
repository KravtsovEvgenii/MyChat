//
//  OneLineTextField.swift
//  Chat
//
//  Created by User on 02.12.2020.
//

import Foundation
import UIKit

class OneLineTextField: UITextField{
    
    convenience init(font: UIFont? = .avenir20()) {
        self.init()
        self.font = font
        self.translatesAutoresizingMaskIntoConstraints = false
        self.borderStyle = .none
        
        let bottomView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        bottomView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        self.addSubview(bottomView)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        bottomView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        bottomView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
}
