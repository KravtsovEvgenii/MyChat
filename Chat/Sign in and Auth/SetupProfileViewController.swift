//
//  SetupProfileViewController.swift
//  Chat
//
//  Created by User on 03.12.2020.
//

import UIKit
import FirebaseAuth
import SDWebImage

class SetupProfileViewController: UIViewController {
    init(currentUser: User){
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        if let userName = currentUser.displayName {
            fullNameTextField.text = userName
        }
        if let photoUrl = currentUser.photoURL {
            self.addPhotoView.circleImageView.sd_setImage(with: photoUrl, completed: nil)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//MARK: Properties
    let addPhotoView = AddPhotoView()
    //Labels
    let welcomeLabel = UILabel(withText: "My Account", font: .avenir26())
    let fullNameLabel = UILabel(withText: "Full Name")
    let aboutLabel = UILabel(withText: "About Me")
    let sexLabel = UILabel(withText: "Sex")
    //TextFields
    let fullNameTextField = OneLineTextField(font: .avenir20())
    let aboutMeTextField = OneLineTextField(font: .avenir20())
    //SegmentControl
    let sexSegmentControl = UISegmentedControl(first: "Male", second: "Female")
    
    //Button
    let gotoChatsButton = UIButton(withTitle: "Go to chats", backgroundColor: .black, titleColor: .white)
    private let currentUser: User
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupConstraints()
        gotoChatsButton.addTarget(self, action: #selector(gotoChatsButtonAction), for: .touchUpInside)
        addPhotoView.plusButton.addTarget(self, action: #selector(addPhotoAction), for: .touchUpInside)
    }
    
    @objc private func addPhotoAction () {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func gotoChatsButtonAction() {
        FireStoreService.shared.saveProfile(id: currentUser.uid,
                                            email: currentUser.email!,
                                            username: fullNameTextField.text,
                                            avatarImage: addPhotoView.circleImageView.image,
                                            description: aboutMeTextField.text,
                                            sex: sexSegmentControl.titleForSegment(at: sexSegmentControl.selectedSegmentIndex)) { (result) in
            switch result{
            
            case .success(let user ):
                self.showAlert(withTitle: "Success", withMessage: "Have a nice talks") {
                    let mainTabBar = MainTabBarController(currentUser: user)
                    mainTabBar.modalPresentationStyle = .fullScreen
                    self.present(mainTabBar, animated: true, completion: nil)
                }
                
            case .failure(let error):
                self.showAlert(withTitle: "Error", withMessage: error.localizedDescription)
            }
        }
    }
    
  
}

//MARK: Setup Constraints
extension SetupProfileViewController {
    private func setupConstraints() {
        
        
        let fullNameStackView = UIStackView(arrangeSubviews: [fullNameLabel,fullNameTextField], axis: .vertical, spacing: 0)
        let aboutMeStackView = UIStackView(arrangeSubviews: [aboutLabel,aboutMeTextField], axis: .vertical, spacing: 0)
        let sexStackView = UIStackView(arrangeSubviews: [sexLabel,sexSegmentControl], axis: .vertical, spacing: 10)
        
        let generalStackView = UIStackView(arrangeSubviews: [fullNameStackView,
                                                             aboutMeStackView,
                                                             sexStackView,
                                                             gotoChatsButton],
                                           axis: .vertical,
                                           spacing: 40)
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        generalStackView.translatesAutoresizingMaskIntoConstraints = false
        addPhotoView.translatesAutoresizingMaskIntoConstraints = false
       
      
        view.addSubview(addPhotoView)
        view.addSubview(welcomeLabel)
        view.addSubview(generalStackView)
        //Constraints
        welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 120).isActive = true
        welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        addPhotoView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 40).isActive = true
        addPhotoView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        gotoChatsButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
        
        generalStackView.topAnchor.constraint(equalTo: addPhotoView.bottomAnchor, constant: 40).isActive = true
        generalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        generalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
    }
    
    
  
}

//MARK: Image Picker Delegate
extension SetupProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {return}
            self.addPhotoView.circleImageView.image = image
        }
     
    }
}
//MARK: Canvas setup
import SwiftUI
struct SetupProfileViewControllerProvider: PreviewProvider {
    
    static var previews: some View {
        Group {
            ContainerView().padding(.top).edgesIgnoringSafeArea(.all)
        }
    }
    
    struct ContainerView: UIViewControllerRepresentable{
        typealias UIViewControllerType = SetupProfileViewController
        
        func makeUIViewController(context: Self.Context) -> Self.UIViewControllerType{
            return SetupProfileViewController(currentUser: Auth.auth().currentUser!)
        }
        
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
        
        
    }
}

