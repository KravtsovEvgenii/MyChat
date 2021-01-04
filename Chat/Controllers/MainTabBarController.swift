//
//  TabBarController.swift
//  Chat
//
//  Created by User on 05.12.2020.
//

import UIKit
import FirebaseAuth
class MainTabBarController: UITabBarController {
    private let currentUser: ChatUser
    
    init(currentUser: ChatUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = currentUser.username
        tabBar.tintColor = .purple
        let boldConfiguration = UIImage.SymbolConfiguration(weight: .medium)
        let peopleImage = UIImage(systemName: "person.2",withConfiguration: boldConfiguration)
        let convImage = UIImage(systemName: "bubble.left.and.bubble.right",withConfiguration: boldConfiguration)
       let listVC = makeNavigationController(forVC: ListViewController(currentUser: currentUser), withTitle: "Conversations", withImage: convImage!)
        let peopleVC = makeNavigationController(forVC: PeopleViewController(currentUser: currentUser) , withTitle: "People", withImage: peopleImage!)
        viewControllers = [listVC,peopleVC]
        
        if let user = Auth.auth().currentUser {
            FireStoreService.shared.getUserData(user: user) { (result) in
                switch result {
                case .success(_):
                  print("success")
                case .failure(_):
                   print("something goes wrong")
                }
            }
        }

    }
    

    private func makeNavigationController(forVC vc: UIViewController,withTitle title: String, withImage image: UIImage) -> UIViewController {
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.tabBarItem.title = title
        navigationController.tabBarItem.image = image
        return navigationController
    }

}
