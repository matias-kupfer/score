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
        input.text = "matias@score.com"
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
    
    let progressView: UIActivityIndicatorView = {
        let progressView = UIActivityIndicatorView()
        return progressView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad LoginViewController")
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Login"
        
        headerLabel.text = defaultText
        
        view.addSubview(emailInputField)
        view.addSubview(passwordInputField)
        view.addSubview(loginButton)
        
        setUpConstraints()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func setUpConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        //        constraints.append(headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20))
        //        constraints.append(headerLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20))
        //        constraints.append(headerLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20))
        
        constraints.append(emailInputField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20))
        constraints.append(emailInputField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20))
        constraints.append(emailInputField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20))
        
        constraints.append(passwordInputField.topAnchor.constraint(equalTo: emailInputField.safeAreaLayoutGuide.topAnchor, constant: 60))
        constraints.append(passwordInputField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20))
        constraints.append(passwordInputField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20))
        
        constraints.append(loginButton.topAnchor.constraint(equalTo: passwordInputField.safeAreaLayoutGuide.topAnchor, constant: 80))
        constraints.append(loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20))
        constraints.append(loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc private func onLoginClick(_: AnyObject) {
        auth.signIn(withEmail: emailInputField.text!, password: passwordInputField.text!) { [weak self] authResult, error in
            if (error != nil) {
                print(error)
            } else {
                print(authResult!.user)
                print("logged in")
                self?.dismiss(animated: true)
            }
        }
    }
}
