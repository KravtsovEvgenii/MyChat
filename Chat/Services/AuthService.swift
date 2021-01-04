//
//  AuthService.swift
//  Chat
//
//  Created by User on 21.12.2020.
//

import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn
class AuthService {
    
   static let shared = AuthService()
    private let auth = Auth.auth()
    
    func googleLogin(user: GIDGoogleUser!, error: Error!, completion: @escaping (Result<User, Error>) -> Void) {
        if let error = error {
            completion(.failure(error))
            return
        }
        guard let auth = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        
        Auth.auth().signIn(with: credential) { (result, error) in
            guard let result = result else {
                completion(.failure(error!))
                return
            }
            completion(.success(result.user))
        }
    }
    
    
    func registerUser(withEmail email: String?, withPassword password: String?, confirmPassword: String?, completion: @escaping (Result<User, Error>) -> Void) {
        guard Validators.isFilled(email: email, password: password, confirmPassword: confirmPassword) else{
            completion(.failure(AuthError.notFilled))
            return
        }
        guard password! == confirmPassword! else{
            completion(.failure(AuthError.passwordsNotMatched))
            return
        }
        guard Validators.isSimpleEmail(email!) else {
            completion(.failure(AuthError.invalidEmail))
            return
        }
        auth.createUser(withEmail: email!, password: password!) { (result, error) in
            guard let result = result else {
                completion(.failure(error!))
                return
            }
            completion(.success(result.user))
        }
    }
    func login(withEmail email: String?, withPassword password: String?, completion: @escaping (Result<User, Error>) -> Void) {
        guard let email = email ,let password = password else {
            completion(.failure(AuthError.notFilled))
            return
        }
        
        auth.signIn(withEmail: email, password: password) { (result, error) in
            
            guard let result = result else {
                completion(.failure(error!))
                return
            }
            completion(.success(result.user))
        }
        
    }
}
