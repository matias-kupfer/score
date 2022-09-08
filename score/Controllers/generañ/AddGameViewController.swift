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
    
    var gameColor: GameColorModel?
    
    public var addGameViewControllerDelegate: AddGameViewControllerDelegate!
    
    private var users: [String] = [String]()
    
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
        button.action = #selector(onCancel)
        button.tintColor = .red
        return button
    }()
    
    let rightBarButtonItem: UIBarButtonItem = {
        var button = UIBarButtonItem()
        button.title = "Save"
        button.style = UIBarButtonItem.Style.plain
        button.action = #selector(onSaveTask)
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
    
    let searchUserButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "send.png"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
//        button.frame = CGRect(x: CGFloat(txt.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
//        button.addTarget(self, action: #selector(self.refresh), for: .touchUpInside)
        return button
    }()
    
    let colorPicker: UIColorPickerViewController = {
        let colorPicker = UIColorPickerViewController()
        return colorPicker
    }()
    
    let colorPickerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Color", for: .normal)
        //        button.setImage(UIImage(systemName: "eyedropper"), for: .normal)
        button.configuration = UIButton.Configuration.plain()
        button.configuration?.buttonSize = UIButton.Configuration.Size.medium
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        colorPickerButton.addTarget(self, action: #selector(openColorPicker(_:)), for: .touchUpInside)
        colorPicker.delegate = self
        
        view.addSubview(formView)
        formView.addSubview(nameInputField)
        formView.addSubview(desciptionInputField)
        formView.addSubview(usersInputField)
        view.addSubview(userCardView)
        view.addSubview(colorPickerButton)
        
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
        
        constraints.append(colorPickerButton.topAnchor.constraint(equalTo: userCardView.bottomAnchor, constant: 20))
        
        
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
                if (self.users.contains(user.id)) {
                    return
                }
                self.users.append(user.id)
                self.userCardView.configure(with: user)
            }
        }
        
    }
    
    @objc private func onCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func onSaveTask() {
        let gameObject = GameModel(name: nameInputField.text!, id: "id", users: self.users, color: gameColor!)
        let gamesRef = db.collection("games")
        do {
            let gameRef: DocumentReference = try gamesRef.addDocument(from: gameObject)
            gameRef.updateData(["id": gameRef.documentID]) { (error: Error?) in
                if let error = error {
                    print("Data could not be saved: \(error).")
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
    }
}

extension AddGameViewController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let colorPicked: UIColor = viewController.selectedColor
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        colorPicked.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        gameColor = GameColorModel(red: red, blue: blue, green: green, alpha: alpha)
        colorPickerButton.backgroundColor = viewController.selectedColor
        //        color = viewController.selectedColor
    }
    
    @objc private func openColorPicker(_: UIButton) {
        navigationController?.present(colorPicker, animated: true)
    }
}
