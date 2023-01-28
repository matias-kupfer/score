//
//  AddGameViewController.swift
//  score
//
//  Created by Matias Kupfer on 29.03.22.
//

import UIKit
import SwiftUI

protocol AddGameViewControllerDelegate: AnyObject {
    func onGameSaved()
}

class AddGameViewController: UIViewController {
    
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
        button.action = #selector(onSaveGame)
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
        FirebaseService.shared.searchUserByUsername(username: textField.text!) { (user, error) in
            if let user = user {
                self.users.append(user.id)
                self.userCardView.configure(with: user)
            } else if let error = error {
                print(error)
            } else {
                print("User not found")
            }
        }
    }
    
    @objc private func onCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func onSaveGame() {
        self.users.append(AuthService.shared.getAuthUserId())
        let gameObject = GameModel(name: nameInputField.text!, description: desciptionInputField.text!, id: "id", players: self.users, color: gameColor!)
        FirebaseService.shared.saveGame(game: gameObject) { error, gameRef in
            if let error = error {
                print("Error adding game: \(error)")
            } else {
                if let gameRef = gameRef {
                    print("Game added with ID: \(gameRef.documentID)")
                    self.dismiss(animated: true, completion: nil)
                }
            }
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
