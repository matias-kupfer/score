//
//  HomeViewController.swift
//  score
//
//  Created by Matias Kupfer on 28.03.22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift


class HomeViewController: UIViewController {
    let db = Firestore.firestore()
    
    var games = [GameModel]()
    
    let leftBarButton: UIBarButtonItem = {
        var button = UIBarButtonItem()
        button.image = UIImage(systemName: "plus")
        button.style = UIBarButtonItem.Style.plain
        button.action = #selector(gameSelector(_:))
        return button
    }()
    
    let gamePicker: UIPickerView = {
        var picker = UIPickerView()
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getGames()
                
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Scores"
        navigationItem.leftBarButtonItem = leftBarButton
        
        gamePicker.dataSource = self
        gamePicker.delegate = self
        self.view.addSubview(gamePicker)
        gamePicker.center = self.view.center
        
    }
    
    @objc func gameSelector(_: UIBarButtonItem) {
        
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
                    print(queryDocumentSnapshot.data())
                    return try! queryDocumentSnapshot.data(as: GameModel.self)
                }
            }
        }
    }


}

extension HomeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return games.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let row = games[row]
        return row.name
    }
}

