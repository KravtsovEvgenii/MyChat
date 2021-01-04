//
//  UIImageView + Ext.swift
//  Chat
//
//  Created by User on 02.12.2020.
//

import Foundation
import UIKit

extension UIImageView {
    convenience init(withImage image: UIImage, contendMode: UIView.ContentMode) {
        self.init()
        self.image = image
        self.contentMode = contendMode
    }
}
// Расширение для изменения цвета изображения

extension UIImageView {
    func setupColor (color: UIColor) {
        let tempImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = tempImage
        self.tintColor = color
    }
}
