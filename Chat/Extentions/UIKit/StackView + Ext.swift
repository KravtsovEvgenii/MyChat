//
//  StackView + Ext.swift
//  Chat
//
//  Created by User on 02.12.2020.
//

import Foundation
import UIKit

extension UIStackView {
    
    convenience init(arrangeSubviews: [UIView],axis:NSLayoutConstraint.Axis , spacing: CGFloat) {
        self.init(arrangedSubviews: arrangeSubviews)
        self.axis = axis
        self.spacing = spacing
    }
    
}
