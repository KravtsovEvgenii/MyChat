//
//  UIViewController + Ext.swift
//  Chat
//
//  Created by User on 14.12.2020.
//

import UIKit

extension UIViewController {
    //configure cells
    func configure<T: SelfConfiguringCell, U: Hashable>(collectionView: UICollectionView, cellType: T.Type, with value: U, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseId, for: indexPath) as? T else { fatalError("Unable to dequeue \(cellType)") }
        cell.configure(with: value)
        return cell
    }
    
    func showAlert(withTitle title: String, withMessage message: String, completion: @escaping ()->() = { }) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
        completion()
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
