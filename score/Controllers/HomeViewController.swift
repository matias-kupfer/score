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
        return button
    }()
    
    let leftBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "list.bullet")
        button.style = UIBarButtonItem.Style.plain
        return button
    }()
    
    let loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView()
        loader.startAnimating()
        return loader
    }()
    
    let selectGameButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .yellow
        button.setTitle("Choose game...", for: .normal)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        selectGameButton.showsMenuAsPrimaryAction = true
        
        view.addSubview(loader)
        loader.center = self.view.center
        
        getGames()
        
        title = "Score"
        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationItem.titleView = selectGameButton
        leftBarButton.target = self
        navigationItem.leftBarButtonItem = leftBarButton
        rightBarButton.target = self
        navigationItem.rightBarButtonItem = rightBarButton
        
    }
    
    private func getGames() {
        let gamesRef = db.collection("games")
        gamesRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                guard let documents = querySnapshot?.documents else {
                    print("no documents")
                    return
                }
                self.games = documents.compactMap { queryDocumentSnapshot -> GameModel? in
                    return try! queryDocumentSnapshot.data(as: GameModel.self)
                }
                self.configureMenu()
                self.loader.stopAnimating()
            }
        }
    }
    
    private func configureMenu() {
        self.title = self.games[0].name
        self.navigationItem.rightBarButtonItem = rightBarButton
        let actions: [UIAction] = games.map {
            return UIAction(title: $0.name, image: UIImage(systemName: "plus"), handler: { (action: UIAction) in
                self.selectGame(uiActionEvent: action)
            })
        }
        let menu: UIMenu = UIMenu(title: "Menu title", subtitle: "subtitle", image: UIImage(systemName: "plus"), children: actions)
        self.selectGameButton.menu = menu
        self.leftBarButton.menu = menu
    }
    
    private func selectGame(uiActionEvent: UIAction) {
        self.title = uiActionEvent.title
        self.selectedGame = games.first(where: {$0.name == uiActionEvent.title})!
    }
}

//extension HomeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
//    func numberOfComponents(in pickerVi2ew: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return games.count
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        let row = games[row]
//        return row.name
//    }
//}

