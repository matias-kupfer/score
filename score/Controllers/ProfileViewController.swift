//
//  ProfileViewController.swift
//  score
//
//  Created by Matias Kupfer on 28.03.22.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestoreSwift

class ProfileViewController: UIViewController {
    
    let auth = FirebaseAuth.Auth.auth()
    let db: Firebase.Firestore = Firestore.firestore()
    var games = [GameModel]()
    
    let defaultText: String = "Login to see your profile"
    
    let leftNavigationButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "plus")
        button.style = UIBarButtonItem.Style.plain
        button.action = #selector(ProfileViewController.addGameModal(_:))
        button.isEnabled = false
        return button
    }()
    
    let rightNavigationButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
        button.style = UIBarButtonItem.Style.plain
        button.action = #selector(ProfileViewController.onLogoutClick(_:))
        button.isEnabled = false
        return button
    }()
    
    let headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    let loginView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tag = 1
        return view
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
    
    let table: UITableView = {
        let table = UITableView()
        table.register(GameTableViewCell.self, forCellReuseIdentifier: GameTableViewCell.identifier)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Login"
        leftNavigationButton.target = self
        navigationItem.leftBarButtonItem = leftNavigationButton
        rightNavigationButton.target = self
        navigationItem.rightBarButtonItem = rightNavigationButton
        
        headerLabel.text = defaultText
        
        //        table.tableHeaderView = gameHeaderUIView
        table.delegate = self
        table.dataSource = self
        
        //        view.addSubview(headerLabel)
        view.addSubview(loginView)
        loginView.addSubview(emailInputField)
        loginView.addSubview(passwordInputField)
        loginView.addSubview(loginButton)
        
        setUpConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
    }
    
    private func setUpConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        //        constraints.append(headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20))
        //        constraints.append(headerLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20))
        //        constraints.append(headerLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20))
        
        constraints.append(loginView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20))
        constraints.append(loginView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20))
        constraints.append(loginView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20))
        constraints.append(loginView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor))
        
        constraints.append(emailInputField.topAnchor.constraint(equalTo: loginView.safeAreaLayoutGuide.topAnchor))
        constraints.append(emailInputField.leadingAnchor.constraint(equalTo: loginView.safeAreaLayoutGuide.leadingAnchor))
        constraints.append(emailInputField.trailingAnchor.constraint(equalTo: loginView.safeAreaLayoutGuide.trailingAnchor))
        
        constraints.append(passwordInputField.topAnchor.constraint(equalTo: emailInputField.topAnchor, constant: 60))
        constraints.append(passwordInputField.leadingAnchor.constraint(equalTo: loginView.safeAreaLayoutGuide.leadingAnchor))
        constraints.append(passwordInputField.trailingAnchor.constraint(equalTo: loginView.safeAreaLayoutGuide.trailingAnchor))
        
        constraints.append(loginButton.topAnchor.constraint(equalTo: passwordInputField.topAnchor, constant: 80))
        constraints.append(loginButton.leadingAnchor.constraint(equalTo: loginView.safeAreaLayoutGuide.leadingAnchor))
        constraints.append(loginButton.trailingAnchor.constraint(equalTo: loginView.safeAreaLayoutGuide.trailingAnchor))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc private func onLoginClick(_: AnyObject) {
        auth.signIn(withEmail: emailInputField.text!, password: passwordInputField.text!) { [weak self] authResult, error in
            if (error != nil) {
                print(error)
            } else {
                print(authResult!.user)
                if let viewToDelete = self!.view.viewWithTag(1) {
                    viewToDelete.removeFromSuperview()
                }
                self?.title = "Profile"
                self?.headerLabel.text = authResult!.user.email
                self?.leftNavigationButton.isEnabled = true
                self?.rightNavigationButton.isEnabled = true
                self?.getGames()
                //                self?.view.addSubview(self!.table)
                print("logged in")
            }
        }
    }
    
    @objc private func onLogoutClick(_: AnyObject) {
        do {
            try auth.signOut()
            self.title = "Login"
            self.headerLabel.text = defaultText
            leftNavigationButton.isEnabled = false
            rightNavigationButton.isEnabled = false
            view.addSubview(loginView)
            setUpConstraints()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    private func getGames() {
        //        activityIndicator.startAnimating()
        //        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        let gamesRef = db.collection("games")
        gamesRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                guard let documents = querySnapshot?.documents else {
                    return
                }
                if (documents.count == 0) {
                    print("no documents")
                    //                    self.activityIndicator.stopAnimating()
                    return
                }
                for document in documents {
                    let game: GameModel = try! document.data(as: GameModel.self)
                    if (game.users.contains(self.auth.currentUser!.uid)) {
                        self.games.append(game)
                    }
                }
                self.view.addSubview(self.table)
                self.table.reloadData()
                //                self.activityIndicator.stopAnimating()
                //                self.navigationItem.leftBarButtonItem = self.leftNavigationButton
                //                self.configureMenu()
            }
        }
    }
}

extension ProfileViewController: AddGameViewControllerDelegate {
    @objc private func addGameModal(_: UIBarButtonItem) {
        let vc = AddGameViewController()
        vc.addGameViewControllerDelegate = self
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .popover
        nc.sheetPresentationController?.detents = [.medium(), .large()]
        nc.sheetPresentationController?.prefersGrabberVisible = true
        navigationController?.present(nc, animated: true)
    }
    
    func onGameSaved() {
        print("game saved")
    }
}

extension ProfileViewController: GameViewControllerDelegate {
    func tbd() {
        print("game saved")
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GameTableViewCell.identifier, for: indexPath) as? GameTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(g: games[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = GameViewController()
        vc.gameViewControllerDelegate = self
        vc.configure(g: games[indexPath.row])
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .pageSheet
        nc.sheetPresentationController?.detents = [.medium()]
        nc.sheetPresentationController?.prefersGrabberVisible = true
        nc.setNavigationBarHidden(true, animated: true)
        navigationController?.present(nc, animated: true)
    }
}

