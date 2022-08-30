//
//  HomeViewController.swift
//  score
//
//  Created by Matias Kupfer on 28.03.22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import WebKit
import Promises


class HomeViewController: UIViewController {
    let db = Firestore.firestore()
    
    var games = [GameModel]()
    var selectedGame: GameModel!
    var selectedGameUsers: [UserModel] = [UserModel]()
    var matches: [MatchModel] = [MatchModel]()
    
    private var gameHeaderUIView: GameHeaderUIView!
    
    let rightBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "plus")
        button.style = UIBarButtonItem.Style.plain
        //                button.action = #selector(HomeViewController.addGameModal(_:))
        button.action = #selector(HomeViewController.addMatchModal(_:))
        return button
    }()
    
    let leftBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "list.bullet")
        button.style = UIBarButtonItem.Style.plain
        return button
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView()
        return loader
    }()
    
    let table: UITableView = {
        let table = UITableView()
        table.register(MatchTableViewCell.self, forCellReuseIdentifier: MatchTableViewCell.identifier)
        return table
    }()
    
    let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.translatesAutoresizingMaskIntoConstraints = false
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.onRefresh(_:)), for: .valueChanged)
        table.addSubview(refreshControl)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Score"
        //        navigationItem.titleView = selectGameButton
        leftBarButton.target = self
        rightBarButton.target = self
        navigationItem.rightBarButtonItem = rightBarButton
        
        activityIndicator.center = self.view.center
        //view.addSubview(activityIndicator)
        
        gameHeaderUIView = GameHeaderUIView()
        gameHeaderUIView.translatesAutoresizingMaskIntoConstraints = false
        table.tableHeaderView = gameHeaderUIView
        table.delegate = self
        table.dataSource = self
        view.addSubview(table)
        
        getGames()
        setUpConstraints()
    }
    
    private func setUpConstraints() {
        var constraints = [NSLayoutConstraint]()
        let margins = view.layoutMarginsGuide
        
        constraints.append(gameHeaderUIView.leadingAnchor.constraint(equalTo: margins.leadingAnchor))
        constraints.append(gameHeaderUIView.trailingAnchor.constraint(equalTo: margins.trailingAnchor))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
    }
    
    private func getGames() {
        activityIndicator.startAnimating()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: activityIndicator)
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
                    self.activityIndicator.stopAnimating()
                    return
                }
                self.games = documents.compactMap { queryDocumentSnapshot -> GameModel? in
                    return try! queryDocumentSnapshot.data(as: GameModel.self)
                }
                self.activityIndicator.stopAnimating()
                self.navigationItem.leftBarButtonItem = self.leftBarButton
                self.configureMenu()
            }
        }
    }
    
    private func configureMenu() {
        let actions: [UIAction] = games.map {
            return UIAction(title: $0.name, image: UIImage(systemName: "plus"), handler: { (action: UIAction) in
                self.selectGame(uiActionEvent: action)
            })
        }
        let menu: UIMenu = UIMenu(title: "Your games", subtitle: "choose", image: UIImage(systemName: "plus"), children: actions)
        leftBarButton.menu = menu
    }
    
    private func selectGame(uiActionEvent: UIAction) {
        title = uiActionEvent.title
        selectedGame = games.first(where: {$0.name == uiActionEvent.title})!
        getGameUsers()
        getMatches()
        changeColor()
    }
    
    private func getGameUsers() {
        selectedGameUsers.removeAll()
        // loop that waits to proceed?
        for userId in selectedGame.users {
            searchUser(userId: userId).then{(user: UserModel) in
                self.selectedGameUsers.append(user)
                self.gameHeaderUIView?.configure(game: self.selectedGame, users: self.selectedGameUsers)
                self.table.reloadData()
            }.catch{(err: Error) in
                print(err)
            }
        }
    }
    
    private func getMatches() {
        let matchesRef = db.collection("games").document(selectedGame.id).collection("matches").order(by: "date", descending: true)
        matchesRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                guard let documents = querySnapshot?.documents else {
                    return
                }
                if (documents.count == 0) {
                    print("no documents")
                    return
                }
                self.matches = documents.compactMap { queryDocumentSnapshot -> MatchModel? in
                    return try! queryDocumentSnapshot.data(as: MatchModel.self)
                }
                self.table.reloadData()
            }
        }
    }
    
    private func searchUser(userId: String) -> Promise<UserModel>{
        let usersRef = db.collection("users").whereField("id", isEqualTo: userId).limit(to: 1)
        let promise = Promise<UserModel> { (resolve, reject) in
            usersRef.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    return
                } else {
                    guard let documents: [QueryDocumentSnapshot] = querySnapshot?.documents else {
                        reject(NSError(domain: "user not found", code: 404, userInfo: nil))
                        return
                    }
                    if (documents.count == 0) {
                        print("no documents")
                        return
                    }
                    resolve(try! documents.first!.data(as: UserModel.self))
                }
            }
        }
        return promise
    }
    
    private func changeColor() {
        let c: GameColorModel = selectedGame.color
        let color: UIColor = UIColor(red: c.red, green: c.green, blue: c.blue, alpha: c.alpha)
        leftBarButton.tintColor = color
        rightBarButton.tintColor = color
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderUIView = SectionHeaderUIView()
        sectionHeaderUIView.delegate = self
        sectionHeaderUIView.configure(m: matches[section], game: selectedGame)
        return sectionHeaderUIView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return matches.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let myTimeInterval = TimeInterval(matches[section].date)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval)) as Date)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MatchTableViewCell.identifier, for: indexPath) as? MatchTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(m: self.matches[indexPath.section], u: self.selectedGameUsers)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
        let vc = MatchViewController()
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .popover
        //        nc.sheetPresentationController?.detents = [.medium(), .large()]
        nc.sheetPresentationController?.prefersGrabberVisible = true
        self.navigationController?.present(nc, animated: true)
    }
    
    @objc func onRefresh(_ sender: AnyObject) {
        print("refresh table")
        getGameUsers()
        getMatches()
        refreshControl.endRefreshing()
    }
}

extension HomeViewController: AddGameViewControllerDelegate {
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

extension HomeViewController: SectionHeaderUIViewControllerDelegate {
    func onMatchTap(match: MatchModel) {
        //        db.collection("games").document(selectedGame.id).collection("matches").document(match.id).delete()
        //        getMatches()
        let vc = MatchViewController()
        vc.configure(g: selectedGame, m: match, u: selectedGameUsers)
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .pageSheet
        nc.sheetPresentationController?.detents = [.medium()]
        nc.sheetPresentationController?.prefersGrabberVisible = true
        nc.setNavigationBarHidden(true, animated: true)
        navigationController?.present(nc, animated: true)
    }
}


extension HomeViewController {
    @objc private func addMatchModal(_: UIBarButtonItem) {
        let vc = AddMatchViewController()
        vc.gameUsers = self.selectedGameUsers
        vc.game = self.selectedGame
        //        vc.addGameViewControllerDelegate = self
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .popover
        //        nc.sheetPresentationController?.detents = [.medium(), .large()]
        nc.sheetPresentationController?.prefersGrabberVisible = true
        navigationController?.present(nc, animated: true)
    }
}
