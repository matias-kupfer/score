//
//  LoginViewController.swift
//  score
//
//  Created by Matias Kupfer on 08.09.22.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestoreSwift
import Promises

class LoginViewController: UIViewController {
    
    let auth = FirebaseAuth.Auth.auth()
    let db: Firebase.Firestore = Firestore.firestore()
    
    let defaultText: String = "Login to see your profile"
    
    let headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    let emailInputField: UITextField = {
        let input = UITextField()
        input.placeholder = "Email"
        input.text = "register@score.com"
        input.textColor = .lightGray
        input.translatesAutoresizingMaskIntoConstraints = false
        input.font = UIFont.systemFont(ofSize: 24)
        input.borderStyle = .none
        input.autocorrectionType = .no
        input.keyboardType = .emailAddress
        input.returnKeyType = .next
        input.clearButtonMode = .whileEditing
        input.contentVerticalAlignment = .center
        return input
    }()
    
    let passwordInputField: UITextField = {
        let input = UITextField()
        input.text = "qwerty"
        input.textColor = .lightGray
        input.placeholder = "******"
        input.translatesAutoresizingMaskIntoConstraints = false
        input.font = UIFont.systemFont(ofSize: 24)
        input.borderStyle = .none
        input.autocorrectionType = .no
        input.keyboardType = .default
        input.returnKeyType = .next
        input.clearButtonMode = .whileEditing
        input.contentVerticalAlignment = .center
        return input
    }()
    
    let loginButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.buttonSize = .large
        config.baseBackgroundColor = .systemBlue
        config.cornerStyle = .medium
        config.image = UIImage(systemName: "arrow.right.circle")
        config.imagePadding = 5
        config.imagePlacement = .trailing
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
        
        let button = UIButton(configuration: config, primaryAction: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Login", for: .normal)
        
        button.addTarget(self, action: #selector(onLoginClick(_:)), for: .touchUpInside)
        return button
    }()
    
    let usernameInputField: UITextField = {
        let input = UITextField()
        input.text = ""
        input.textColor = .lightGray
        input.placeholder = "username"
        input.translatesAutoresizingMaskIntoConstraints = false
        input.font = UIFont.systemFont(ofSize: 24)
        input.borderStyle = .none
        input.autocorrectionType = .no
        input.keyboardType = .default
        input.returnKeyType = .next
        input.clearButtonMode = .whileEditing
        input.contentVerticalAlignment = .center
        return input
    }()
    
    let registerButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.buttonSize = .large
        config.baseBackgroundColor = .systemBlue
        config.cornerStyle = .medium
        config.image = UIImage(systemName: "arrow.right.circle")
        config.imagePadding = 5
        config.imagePlacement = .trailing
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
        
        let button = UIButton(configuration: config, primaryAction: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Register", for: .normal)
        
        button.addTarget(self, action: #selector(onRegisterClick(_:)), for: .touchUpInside)
        return button
    }()
    
    let progressView: UIActivityIndicatorView = {
        let progressView = UIActivityIndicatorView()
        return progressView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        print("viewDidLoad LoginViewController")
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Login/Register"
        
        headerLabel.text = defaultText
        
        view.addSubview(emailInputField)
        view.addSubview(passwordInputField)
        view.addSubview(loginButton)
        view.addSubview(usernameInputField)
        view.addSubview(registerButton)
        
        setUpConstraints()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            emailInputField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            emailInputField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            emailInputField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            passwordInputField.topAnchor.constraint(equalTo: emailInputField.bottomAnchor, constant: 20),
            passwordInputField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            passwordInputField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            loginButton.topAnchor.constraint(equalTo: passwordInputField.bottomAnchor, constant: 20),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            usernameInputField.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            usernameInputField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            usernameInputField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            registerButton.topAnchor.constraint(equalTo: usernameInputField.bottomAnchor, constant: 20),
            registerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            registerButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func onLoginClick(_: AnyObject) {
        auth.signIn(withEmail: emailInputField.text!, password: passwordInputField.text!) { [weak self] authResult, error in
            if (error != nil) {
                print(error)
            } else {
                print(authResult!.user)
                print("logged in")
                self!.searchUser(userId: authResult!.user.uid)
            }
        }
    }
    
    @objc private func onRegisterClick(_: AnyObject) {
        auth.createUser(withEmail: emailInputField.text!, password: passwordInputField.text!) { authResult, error in
            if (error != nil) {
                print(error)
            } else {
                print(authResult!.user)
                print("registered")
                print(authResult?.user.uid)
                do {
                    self.db.collection("users").document(authResult!.user.uid).setData([
                        "id": authResult!.user.uid,
                        "email": authResult!.user.email,
                        "username": self.usernameInputField.text!
                    ])
                } catch let error {
                    print("Error writing city to Firestore: \(error)")
                }
                self.searchUser(userId: authResult!.user.uid)
            }
        }
    }
    
    private func searchUser(userId: String) -> Void{
        let docRef = db.collection("users").document(userId)
        docRef.getDocument(source: .cache) { (document, error) in
            if let document = document {
                let encoder = JSONEncoder()
                if let user = try! document.data(as: UserModel?.self) {
                    let encoder = JSONEncoder()
                    if let encoded = try? encoder.encode(user) {
                        UserDefaults.standard.set(encoded, forKey: "user")
                        self.dismiss(animated: true)
                    }
                }
            } else {
                print("Document does not exist in cache")
            }
        }
    }
}
