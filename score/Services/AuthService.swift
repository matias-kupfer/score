//
//  AuthService.swift
//  score
//
//  Created by Matias Kupfer on 28.01.23.
//
import FirebaseAuth
import Foundation

class AuthService {
    let auth = FirebaseAuth.Auth.auth()
    
    static let shared = AuthService()
    private init() {}
    
    func signIn(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        auth.signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                print(error)
                completion(nil, error)
            } else {
                print(authResult!.user)
                print("logged in")
                completion(authResult, nil)
            }
        }
    }
    
    func createUser(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        auth.createUser(withEmail: email, password: password) { authResult, error in
            if (error != nil) {
                print(error)
            } else {
                print("registered")
                print(authResult?.user.uid)
            }
        }
    }
    
    func signOut(completion: @escaping (Error?) -> Void) {
        do {
          try auth.signOut()
            completion(nil)
        } catch let error as NSError {
            completion(error)
        }
          
    }
    
    func getAuthUserId() -> String {
        return auth.currentUser!.uid
    }
}
