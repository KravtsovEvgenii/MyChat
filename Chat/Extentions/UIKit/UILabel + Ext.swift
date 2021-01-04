//
//  UILabel + Ext.swift
//  Chat
//
//  Created by User on 02.12.2020.
//

import Foundation
import UIKit

extension UILabel {
    convenience init(withText text: String,font: UIFont? = .avenir20()) {
        self.init()
        self.text = text
        self.font = font
    }
}
