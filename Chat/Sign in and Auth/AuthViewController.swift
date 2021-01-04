//
//  ViewController.swift
//  Chat
//
//  Created by User on 02.12.2020.
//

import UIKit
import SwiftUI
import GoogleSignIn

class AuthViewController: UIViewController {
//MARK: Properties
    
    //Logo Image View
    let logoImageView = UIImageView(withImage: #imageLiteral(resourceName: "Logo"), contendMode: .scaleAspectFit)
    
    //Labels
    let googleLabel = UILabel(withText: "Get started with")
    let emailLabel = UILabel(withText: "Or Sign up with")
    let alreadyOnBoardLabel = UILabel(withText: "Already on board")
    
    
    //Buttons
    let emailButton = UIButton(withTitle: "Email", backgroundColor: .black, titleColor: .white)
    let loginButton = UIButton(withTitle: "Login", backgroundColor: .white, titleColor: .buttonRed(), isShadow: true)
    let googleButton = UIButton(withTitle: "Google", backgroundColor: .white, titleColor: .buttonBlack(), isShadow: true)
    
    let signUpVC = SignUpViewController()
    let loginVC = LoginViewController()
    
    var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self
        loginVC.delegate = self
        signUpVC.delegate = self
        self.view.backgroundColor = .white
        setupConstraints()
     
        emailButton.addTarget(self, action: #selector(emailButtonAction), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonAction), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(googleButtonAction), for: .touchUpInside)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    @objc private func emailButtonAction() {
        present(signUpVC, animated: true, completion: nil)
        
    }
    @objc private func loginButtonAction() {
        present(loginVC, animated: true, completion: nil)
        
    }
    @objc private func googleButtonAction() {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
    }
}
//MARK: GIDSignInDelegate
extension AuthViewController : GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        AuthService.shared.googleLogin(user: user, error: error) { (result) in
            switch result {
            case .success(let user):
                FireStoreService.shared.getUserData(user: user) { (result) in
                    switch result {
                    case .success(let chatUser):
                        UIApplication.getTopViewController()?.showAlert(withTitle: "Success", withMessage: "Register complete") {
                            let mainTabBar = MainTabBarController(currentUser: chatUser)
                            mainTabBar.modalPresentationStyle = .fullScreen
                            self.present(mainTabBar, animated: true, completion: nil)
                        }
                    case .failure(_):
                        UIApplication.getTopViewController()?.showAlert(withTitle: "Success", withMessage: "Register complete") {
                            self.present(SetupProfileViewController(currentUser: user), animated: true, completion: nil)
                        }
                    }
                }
                
            case .failure(let error):
                self.showAlert(withTitle: "Error", withMessage: error.localizedDescription)
            }
        }
    }
}

extension AuthViewController {
    //MARK: Setup Constraints
    private func setupConstraints() {
        
        scrollView  = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        scrollView.isScrollEnabled = true
        
        
        //Google image into Button
        googleButton.setupGoogleButton()
        
        let googleView = ButtonFormView(label: googleLabel, button: googleButton)
        let emailView = ButtonFormView(label: emailLabel,button: emailButton)
        let loginView = ButtonFormView(label: alreadyOnBoardLabel ,button: loginButton)
        //Stack View
        let stackView = UIStackView(arrangeSubviews: [googleView,emailView,loginView],axis: .vertical, spacing: 40)
        
        
   
        scrollView.addSubview(logoImageView)
        scrollView.addSubview(stackView)
        self.view.addSubview(scrollView)
        //Logo Constraints
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
      
        logoImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: 0).isActive = true
        logoImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 140).isActive = true
        
        //StackView Constraints
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 140).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        scrollView.isScrollEnabled = true
        scrollView.backgroundColor = .white
        //!!!!!!
        scrollView.contentSize = CGSize(width: view.frame.width, height: loginView.frame.maxX + 1000)
    }
}
extension AuthViewController: AuthNavigationDelegate {
    func goToLoginVC() {
        self.present(loginVC, animated: true, completion: nil)
    }
    
    func goToSignUpVC() {
        self.present(signUpVC, animated: true, completion: nil)
    }
    
    
}

//MARK: Canvas setup
import SwiftUI
struct AuthViewControllerProvider: PreviewProvider {
    
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable{
        typealias UIViewControllerType = AuthViewController
        
        func makeUIViewController(context: Self.Context) -> Self.UIViewControllerType{
            return AuthViewController()
        }
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
    }
}
