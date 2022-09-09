//
//  ProfileViewController.swift
//  score
//
//  Created by Matias Kupfer on 28.03.22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

class ProfileViewController: UIViewController {
    
    let auth = FirebaseAuth.Auth.auth()
    let db: Firebase.Firestore = Firestore.firestore()
    var games = [GameModel]()
    private var profileHeaderUIView: ProfileHeaderUIView!
    
    let leftNavigationButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "plus")
        button.style = UIBarButtonItem.Style.plain
        button.action = #selector(ProfileViewController.addGameModal)
        return button
    }()
    
    let rightNavigationButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
        button.style = UIBarButtonItem.Style.plain
        button.action = #selector(ProfileViewController.onLogoutClick)
        return button
    }()
    
    let table: UITableView = {
        let table = UITableView()
        table.register(GameTableViewCell.self, forCellReuseIdentifier: GameTableViewCell.identifier)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad ProfileViewController")
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Profile"
        leftNavigationButton.target = self
        rightNavigationButton.target = self
        self.navigationItem.leftBarButtonItem = leftNavigationButton
        self.navigationItem.rightBarButtonItem = rightNavigationButton
        
        profileHeaderUIView = ProfileHeaderUIView()
        profileHeaderUIView.translatesAutoresizingMaskIntoConstraints = false
        
        table.tableHeaderView = profileHeaderUIView
        table.delegate = self
        table.dataSource = self
        
        getGames()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
    }
    
    private func setUpConstraints() {
        var constraints = [NSLayoutConstraint]()
        let margins = view.layoutMarginsGuide
        
        constraints.append(profileHeaderUIView.leadingAnchor.constraint(equalTo: margins.leadingAnchor))
        constraints.append(profileHeaderUIView.trailingAnchor.constraint(equalTo: margins.trailingAnchor))
        
        NSLayoutConstraint.activate(constraints)
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
                self.setUpConstraints()
                self.profileHeaderUIView.configure(g: self.games)
                self.table.reloadData()
                //                self.activityIndicator.stopAnimating()
                //                self.navigationItem.leftBarButtonItem = self.leftNavigationButton
                //                self.configureMenu()
            }
        }
    }
    
    @objc private func onLogoutClick() {
        print("onlogoutclick")
        do {
            try auth.signOut()
            print("user logged out")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

extension ProfileViewController: AddGameViewControllerDelegate {
    @objc private func addGameModal() {
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return profileHeaderUIView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GameTableViewCell.identifier, for: indexPath) as? GameTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(g: games[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
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

