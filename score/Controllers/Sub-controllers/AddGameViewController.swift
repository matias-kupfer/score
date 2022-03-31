//
//  AddGameViewController.swift
//  score
//
//  Created by Matias Kupfer on 29.03.22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import SwiftUI

protocol AddGameViewControllerDelegate: AnyObject {
    func onGameSaved()
}

class AddGameViewController: UIViewController {
    let db = Firestore.firestore()
    
    public var addGameViewControllerDelegate: AddGameViewControllerDelegate!
        
    let userCardView: UserCardView = {
        let view = UserCardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let formView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let leftBarButtonItem: UIBarButtonItem = {
        var button = UIBarButtonItem()
        button.title = "Cancel"
        button.style = UIBarButtonItem.Style.plain
        button.action = #selector(onCancel(_:))
        button.tintColor = .red
        return button
    }()
    
    let rightBarButtonItem: UIBarButtonItem = {
        var button = UIBarButtonItem()
        button.title = "Save"
        button.style = UIBarButtonItem.Style.plain
        button.isEnabled = false
        button.action = #selector(onSaveTask(_:))
        button.tintColor = .systemBlue
        return button
    }()
    
    let nameInputField: UITextField = {
        let input = UITextField()
        //        input.text = "Name: "
        input.placeholder = "Name"
        input.textColor = .lightGray
        input.translatesAutoresizingMaskIntoConstraints = false
        input.font = UIFont.systemFont(ofSize: 15)
        input.borderStyle = .none
        input.autocorrectionType = .no
        input.keyboardType = .default
        input.returnKeyType = .next
        input.clearButtonMode = .whileEditing
        input.contentVerticalAlignment = .center
        return input
    }()
    
    let desciptionInputField: UITextField = {
        let input = UITextField()
        //        input.text = "Description: "
        input.placeholder = "Description"
        input.textColor = .lightGray
        input.translatesAutoresizingMaskIntoConstraints = false
        input.font = UIFont.systemFont(ofSize: 15)
        input.borderStyle = .none
        input.autocorrectionType = .no
        input.keyboardType = .default
        input.returnKeyType = .next
        input.clearButtonMode = .whileEditing
        input.contentVerticalAlignment = .center
        return input
    }()
    
    let usersInputField: UITextField = {
        let input = UITextField()
        input.text = "johnd"
        input.placeholder = "Add users"
        input.textColor = .lightGray
        input.translatesAutoresizingMaskIntoConstraints = false
        input.font = UIFont.systemFont(ofSize: 15)
        input.borderStyle = .none
        input.autocorrectionType = .no
        input.keyboardType = .default
        input.returnKeyType = .next
        input.clearButtonMode = .whileEditing
        input.contentVerticalAlignment = .center
        return input
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Create game"
        view.backgroundColor = .systemBackground
        leftBarButtonItem.target = self
        rightBarButtonItem.target = self
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        //        UserCardView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 500))
        
        usersInputField.addTarget(self, action: #selector(searchUser(_:)), for: .editingChanged)
        view.addSubview(formView)
        formView.addSubview(nameInputField)
        formView.addSubview(desciptionInputField)
        formView.addSubview(usersInputField)
        
        view.addSubview(userCardView)

        setUpConstraints()
    }
    
    private func setUpConstraints() {
        let margins = view.layoutMarginsGuide
        var constraints = [NSLayoutConstraint]()
        constraints.append(formView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor))
        constraints.append(formView.leadingAnchor.constraint(equalTo: margins.leadingAnchor))
        constraints.append(formView.trailingAnchor.constraint(equalTo: margins.trailingAnchor))
        constraints.append(formView.bottomAnchor.constraint(equalTo: usersInputField.bottomAnchor))
        
        constraints.append(nameInputField.topAnchor.constraint(equalTo: formView.topAnchor, constant: 20))
        constraints.append(nameInputField.leadingAnchor.constraint(equalTo: formView.leadingAnchor))
        constraints.append(nameInputField.trailingAnchor.constraint(equalTo: formView.trailingAnchor))
        
        constraints.append(desciptionInputField.topAnchor.constraint(equalTo: nameInputField.bottomAnchor, constant: 20))
        constraints.append(desciptionInputField.leadingAnchor.constraint(equalTo: formView.leadingAnchor))
        constraints.append(desciptionInputField.trailingAnchor.constraint(equalTo: formView.trailingAnchor))
        
        constraints.append(usersInputField.topAnchor.constraint(equalTo: desciptionInputField.bottomAnchor, constant: 20))
        constraints.append(usersInputField.leadingAnchor.constraint(equalTo: formView.leadingAnchor))
        constraints.append(usersInputField.trailingAnchor.constraint(equalTo: formView.trailingAnchor))
        
        constraints.append(userCardView.topAnchor.constraint(equalTo: formView.bottomAnchor, constant: 20))
        constraints.append(userCardView.leadingAnchor.constraint(equalTo: margins.leadingAnchor))
        constraints.append(userCardView.trailingAnchor.constraint(equalTo: margins.trailingAnchor))
        constraints.append(userCardView.heightAnchor.constraint(equalToConstant: 20))
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    @objc private func searchUser(_ textField: UITextField) {
        //        self.rightBarButtonItem.isEnabled = textField.text != ""
        let usersRef = db.collection("users").whereField("username", isEqualTo: textField.text!).limit(to: 1)
        usersRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                guard let documents: [QueryDocumentSnapshot] = querySnapshot?.documents else {
                    return
                }
                if (documents.count == 0) {
                    print("no documents")
                    return
                }
                let user: UserModel = try! documents.first!.data(as: UserModel.self)
                self.userCardView.configure(with: user)
//                self.view.addSubview(self.userCardView)
            }
        }
        
    }
    
    @objc private func onCancel(_: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func onSaveTask(_: UIBarButtonItem) {
        let gameObject = GameModel(name: nameInputField.text!)
        let gamesRef = db.collection("games")
        do {
            try gamesRef.addDocument(from: gameObject)
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
    }
    
}
