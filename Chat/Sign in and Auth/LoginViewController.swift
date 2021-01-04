//
//  LoginViewController.swift
//  Chat
//
//  Created by User on 02.12.2020.
//

import UIKit

class LoginViewController: UIViewController {
    
    //MARK: Properties
    //Labels
    let welcomeLabel = UILabel(withText: "Welcome back!", font: .avenir26())
    let loginWith = UILabel(withText: "Login with")
    let orLabel = UILabel(withText: "or")
    let emailLabel = UILabel(withText: "Email")
    let passwordLabel = UILabel(withText: "Password")
    let needAccountLabel = UILabel(withText: "Need an account")
    //Buttons
    let googleButton = UIButton(withTitle: "Google", backgroundColor: .white, titleColor: .buttonBlack(), isShadow: true)
    let loginButton = UIButton(withTitle: "Login", backgroundColor: .black, titleColor: .white)
    let signUpButton = UIButton(withTitle: "Sign Up", backgroundColor: .clear, titleColor: .buttonRed())
    //Text Fields
    let emailTextField = OneLineTextField(font: .avenir20())
    let passwordTextField = OneLineTextField(font: .avenir20())
    weak var delegate: AuthNavigationDelegate? 
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupConstraints()
        loginButton.addTarget(self, action: #selector(loginButtonAction), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonAction), for: .touchUpInside)
    }
    @objc private func loginButtonAction() {
        AuthService.shared.login(withEmail: emailTextField.text, withPassword: passwordTextField.text) { (result) in
            switch result {
            case .success(let user):
                self.showAlert(withTitle: "Success", withMessage: "Autorization Success",completion: {
                    FireStoreService.shared.getUserData(user: user) { (result) in
                        switch result {
                        case .success(let chatUser):
                            let mainTabBar = MainTabBarController(currentUser: chatUser)
                            mainTabBar.modalPresentationStyle = .fullScreen
                            self.present(mainTabBar, animated: true, completion: nil)
                        case .failure(_):
                            self.present(SetupProfileViewController(currentUser: user),animated:true)
                        }
                    }
                   
                })
            case .failure(let error):
                self.showAlert(withTitle: "Fail!", withMessage: error.localizedDescription)
                print(error.localizedDescription)
            }
        }
    }
    @objc private func signUpButtonAction() {
        self.dismiss(animated: true) {
            self.delegate?.goToSignUpVC()
        }    }
    
}

//MARK: Constraints
extension LoginViewController {
    private func setupConstraints() {
        googleButton.setupGoogleButton()
        //Some work with Stack Views
        let loginWithView = ButtonFormView(label: loginWith, button: googleButton)
        let emailStackView = UIStackView(arrangeSubviews: [emailLabel,emailTextField], axis: .vertical, spacing: 0)
        let passwordStackView = UIStackView(arrangeSubviews: [passwordLabel,passwordTextField], axis: .vertical, spacing: 0)
        loginButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        let generalStackView = UIStackView(arrangeSubviews: [
            loginWithView,
            orLabel,
            emailStackView,
            passwordStackView,
            loginButton
        ],
        axis: .vertical, spacing: 40)
        signUpButton.contentHorizontalAlignment = .leading
        let bottomStackView = UIStackView(arrangeSubviews: [needAccountLabel,signUpButton], axis: .horizontal, spacing: 50)
        bottomStackView.alignment = .firstBaseline
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        generalStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(welcomeLabel)
        view.addSubview(generalStackView)
        view.addSubview(bottomStackView)
        
        //Constraints
        welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 140).isActive = true
        welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        generalStackView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 40).isActive = true
        generalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant:  40).isActive = true
        generalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant:  -40).isActive = true
        
        bottomStackView.topAnchor.constraint(equalTo: generalStackView.bottomAnchor, constant: 50).isActive = true
        bottomStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant:  40).isActive = true
        bottomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant:  -40).isActive = true
        
        
    }
}

//MARK: Canvas setup
import SwiftUI
struct LoginViewControllerProvider: PreviewProvider {
    
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable{
        typealias UIViewControllerType = LoginViewController
        
        func makeUIViewController(context: Self.Context) -> Self.UIViewControllerType{
            return LoginViewController()
        }
        
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
        
        
    }
}
