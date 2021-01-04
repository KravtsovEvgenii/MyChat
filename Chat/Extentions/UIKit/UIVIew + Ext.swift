//
//  UIVIew + Ext.swift
//  Chat
//
//  Created by User on 18.12.2020.
//

import UIKit

extension UIView {
    
    func applyGradient(cornerRadius: CGFloat) {
        self.backgroundColor = nil
        self.layoutIfNeeded()
        let gradientView = GradientView(from: .topTrailing, to: .bottomLeading, startColor: .systemPink, endColor: .systemTeal)
        if let gradientLayer = gradientView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = bounds
            gradientLayer.cornerRadius = cornerRadius
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
       
        
    }
}
