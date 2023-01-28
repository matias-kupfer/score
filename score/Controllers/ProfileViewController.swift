//
//  ProfileViewController.swift
//  score
//
//  Created by Matias Kupfer on 28.03.22.
//

import UIKit

class ProfileViewController: UIViewController {
    
    var games = [GameModel]()
    var user: UserModel!
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
        let table = UITableView.init(frame: .zero)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.rowHeight = UITableView.automaticDimension
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
        
        
        if let data = UserDefaults.standard.data(forKey: "user"),
           let userModel = try? JSONDecoder().decode(UserModel.self, from: data) {
            user = userModel
            getGames()
        }
        
        table.tableHeaderView = profileHeaderUIView
        table.delegate = self
        table.dataSource = self
        table.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
    }
    
    private func setUpConstraints() {
        let margins = view.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            //            profileHeaderUIView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            //            profileHeaderUIView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            
            table.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    
    private func getGames() {
        //        activityIndicator.startAnimating()
        //        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        FirebaseService.shared.getGamesByUserId(userId: user.id) { games in
            self.games = games
            self.view.addSubview(self.table)
            self.setUpConstraints()
            self.profileHeaderUIView.configure(g: self.games, u: self.user)
            self.table.reloadData()
        }
    }
    
    @objc private func onLogoutClick() {
        AuthService.shared.signOut { error in
            if let error = error {
                print("error on sign out: \(error)")
            } else {
                UserDefaults.standard.removeObject(forKey: "user")
                print("user logged out")
            }
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
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    //
    //    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //        cell.layoutIfNeeded()
    //    }
    //
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

