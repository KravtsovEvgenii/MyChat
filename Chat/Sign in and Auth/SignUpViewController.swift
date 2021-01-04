//
//  SignUpViewController.swift
//  Chat
//
//  Created by User on 02.12.2020.
//

import UIKit

class SignUpViewController: UIViewController {
//MARK: Properties
    //Labels
    let welcomeLabel = UILabel(withText: "Welcome!", font: .avenir26())
    let emailLabel = UILabel(withText: "Email")
    let passwordLabel = UILabel(withText: "Password")
    let confirmPasswordLabel = UILabel(withText: "Confirm Password")
    let alreadyOnBoardLabel = UILabel(withText: "Already on board?")
    //Buttons
    let signUpButton = UIButton(withTitle: "Sign Up", backgroundColor: .black, titleColor: .white)
    let loginButton = UIButton(withTitle: "Login", backgroundColor: .clear, titleColor: .buttonRed())
    //Text Fielsd
    let emailTextField = OneLineTextField(font: .avenir20())
    let passwordTextField = OneLineTextField(font: .avenir20())
    let confirmPasswordTextField = OneLineTextField(font: .avenir20())
    weak var delegate: AuthNavigationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        view.backgroundColor = .white
        signUpButton.addTarget(self, action: #selector(signUpButtonAction), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonAction), for: .touchUpInside)
       
    }
    @objc private func signUpButtonAction() {
        AuthService.shared.registerUser(withEmail: emailTextField.text, withPassword: passwordTextField.text, confirmPassword: confirmPasswordTextField.text) { (result) in
            switch result {
            case .success(let user):
                self.showAlert(withTitle: "Success", withMessage: "Welcome to chats", completion: {
                    self.present(SetupProfileViewController(currentUser: user),animated: true)
                })
            case .failure(let error):
                self.showAlert(withTitle: "Fail!", withMessage: "\(error.localizedDescription)")
                print(error.localizedDescription)
            }
        }
        
    }
    
    @objc private func loginButtonAction() {
        self.dismiss(animated: true) {
            self.delegate?.goToLoginVC()
        }
        
    }

}
//MARK: Setup Constraints
extension SignUpViewController {
    private func setupConstraints() {
        //Email
        let emailStackView = UIStackView(arrangeSubviews: [emailLabel,emailTextField], axis: .vertical, spacing: 0)
        let passwordStackView = UIStackView(arrangeSubviews: [passwordLabel,passwordTextField], axis: .vertical, spacing: 0)
        let confirmPasswordStackView = UIStackView(arrangeSubviews: [confirmPasswordLabel,confirmPasswordTextField], axis: .vertical, spacing: 0)
        
        signUpButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
        let generalStackView = UIStackView(arrangeSubviews: [emailStackView,passwordStackView,confirmPasswordStackView,signUpButton], axis: .vertical, spacing: 40)
        
        let bottomStackView = UIStackView(arrangeSubviews: [alreadyOnBoardLabel,loginButton], axis: .horizontal, spacing: 100)
        
        generalStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(generalStackView)
        view.addSubview(bottomStackView)
        view.addSubview(welcomeLabel)
        
        welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor,constant: 140).isActive = true
        welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //General Stack View
        generalStackView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 140).isActive = true
        generalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 40).isActive = true
        generalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -40).isActive = true
        //Bottom
        bottomStackView.topAnchor.constraint(equalTo: generalStackView.bottomAnchor, constant: 60).isActive = true
        bottomStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 40).isActive = true
        bottomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -40).isActive = true
        loginButton.contentHorizontalAlignment = .leading
        bottomStackView.alignment = .firstBaseline
     
    }
}



//MARK: Canvas setup
import SwiftUI
struct SignUpViewControllerProvider: PreviewProvider {
    
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable{
        typealias UIViewControllerType = SignUpViewController
        
        func makeUIViewController(context: Self.Context) -> Self.UIViewControllerType{
            return SignUpViewController()
        }
        
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
        
        
    }
}
