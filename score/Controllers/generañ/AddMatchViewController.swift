//
//  AddMatchViewController.swift
//  score
//
//  Created by Matias Kupfer on 03.04.22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class AddMatchViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    var gameUsers: [UserModel]!
    var game: GameModel!
    
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
        button.action = #selector(onSaveMatch(_:))
        button.tintColor = .systemBlue
        return button
    }()
    
    let table: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
        table.isEditing = true
        return table
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "New Match"
        view.backgroundColor = .systemBackground
        leftBarButtonItem.target = self
        rightBarButtonItem.target = self
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        view.addSubview(table)
        table.delegate = self
        table.dataSource = self
        table.frame = view.bounds
        
        setUpConstraints()
    }
    
    @objc private func onCancel(_: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func onSaveMatch(_: UIBarButtonItem) {
        let usersIds: [String] = gameUsers.compactMap { user -> String in
            return user.id
        }
        let match = MatchModel(id: "null", date: NSDate().timeIntervalSince1970, order: usersIds)
        let matchRef = db.collection("games").document(game.id).collection("matches")
        do {
            let matchRef: DocumentReference = try matchRef.addDocument(from: match)
            matchRef.updateData(["id": matchRef.documentID]) { (error: Error?) in
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
    
    private func setUpConstraints() {
        
    }
    
}

extension AddMatchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UserTableViewCell()
        cell.configure(with: gameUsers[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = gameUsers[sourceIndexPath.row]
        gameUsers.remove(at: sourceIndexPath.row)
        gameUsers.insert(itemToMove, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete", handler: {(action, view, completionHandler) in
            self.gameUsers.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic);
            completionHandler(true)
        })
        delete.image = UIImage(systemName: "trash")
        
        let swipe = UISwipeActionsConfiguration(actions: [delete])
        return swipe
    }
    
    // sections
    //    func numberOfSections(in tableView: UITableView) -> Int {
    //        return 2
    //    }
    //
    //    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //        return 40
    //    }
    //
    //    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return sectionTitles[section]
    //    }
}
