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


class HomeViewController: UIViewController {
    let db = Firestore.firestore()
    
    var games = [GameModel]()
    var selectedGame: GameModel!
    
    
    let rightBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "plus")
        button.style = UIBarButtonItem.Style.plain
        button.action = #selector(HomeViewController.addGameModal(_:))
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
        table.register(GameTableViewCell.self, forCellReuseIdentifier: GameTableViewCell.identifier)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Score"
        //        navigationItem.titleView = selectGameButton
        leftBarButton.target = self
        rightBarButton.target = self
        navigationItem.rightBarButtonItem = rightBarButton
        
        activityIndicator.center = self.view.center
        view.addSubview(activityIndicator)
        
//        table.tableHeaderView =
        table.delegate = self
        table.dataSource = self
        view.addSubview(table)
        
        getGames()
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
        self.title = uiActionEvent.title
        self.selectedGame = games.first(where: {$0.name == uiActionEvent.title})!
        changeColor()
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
        return 20
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GameTableViewCell.identifier, for: indexPath) as? GameTableViewCell else {
            return UITableViewCell()
        }
        cell.configure()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped row")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else {return}
        header.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textLabel?.frame = CGRect(x: header.bounds.origin.x + 20, y: header.bounds.origin.y, width: 100, height: header.bounds.height)
        header.textLabel?.textColor = .white
        header.textLabel?.text = "exmaple"
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "jkldhfjksdhjk"
    }
}

extension HomeViewController: AddGameViewControllerDelegate {
    @objc private func addGameModal(_: UIBarButtonItem) {
        let vc = AddGameViewController()
        vc.addGameViewControllerDelegate = self
        let nc = UINavigationController(rootViewController: vc)
        nc.sheetPresentationController?.detents = [.medium(), .large()]
        nc.sheetPresentationController?.prefersGrabberVisible = true
        navigationController?.present(nc, animated: true)
    }
    
    func onGameSaved() {
        print("game saved")
    }
}
