//
//  MatchViewController.swift
//  score
//
//  Created by Matias Kupfer on 24.08.22.
//

import UIKit
import SwiftUI
import Firebase

protocol MatchUIViewControllerDelegate: AnyObject {
    func onDeleteMatch(match: MatchModel)
}

class MatchViewController: UIViewController {
    
    public var matchUIViewControllerDelegate: MatchUIViewControllerDelegate!
    private var match: MatchModel!
    private var game: GameModel!
    private var db: Firebase.Firestore!
    
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Match date"
        label.font = label.font.withSize(24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let winnerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .systemYellow
        return label
    }()
    
    let secondLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let thirdLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let playersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let deleteButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.buttonSize = .large
        config.baseBackgroundColor = .systemRed
        config.cornerStyle = .medium
        config.image = UIImage(systemName: "trash")
        config.imagePadding = 5
        config.imagePlacement = .trailing
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
        
        let button = UIButton(configuration: config, primaryAction: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Delete Match", for: .normal)
        
        button.addTarget(self, action: #selector(onDeleteMatch), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(dateLabel)
        view.addSubview(winnerLabel)
        view.addSubview(secondLabel)
        view.addSubview(thirdLabel)
        view.addSubview(playersLabel)
        view.addSubview(deleteButton)
        setUpConstraints()
    }
    
    public func configure(g: GameModel, m: MatchModel, users: [UserModel], db: Firebase.Firestore) {
        let myTimeInterval = TimeInterval(m.date)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        dateLabel.text = formatter.string(from: NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval)) as Date)
        
        game = g
        match = m
        self.db = db
        
        orderUsers(m: m, u: users)
    }
    
    private func orderUsers(m: MatchModel, u: [UserModel]) {
        var orderedGameUsers: [UserModel] = []
        for userId in m.order {
            if let user = u.first(where: {$0.id == userId}) {
                orderedGameUsers.append(user)
            }
        }
        // set winner names
        winnerLabel.text = orderedGameUsers[0].name.uppercased()
        secondLabel.text = orderedGameUsers[1].name.uppercased()
        thirdLabel.text = orderedGameUsers[2].name.uppercased()
        
        if (orderedGameUsers.count > 3) {
            for i in 3...(orderedGameUsers.count - 1) {
                playersLabel.text = playersLabel.text ?? "" + " - " + orderedGameUsers[i].name
            }
        }
    }
    
    private func setUpConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        //        constraints.append(dateLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20))
        constraints.append(dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20))
        dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        constraints.append(winnerLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 40))
        winnerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        constraints.append(secondLabel.topAnchor.constraint(equalTo: winnerLabel.bottomAnchor, constant: 40))
        constraints.append(secondLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20))
        
        constraints.append(thirdLabel.topAnchor.constraint(equalTo: winnerLabel.bottomAnchor, constant: 40))
        constraints.append(thirdLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20))
        
        constraints.append(playersLabel.topAnchor.constraint(equalTo: secondLabel.bottomAnchor, constant: 70))
        constraints.append(playersLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20))
        
        constraints.append(deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor))
        constraints.append(deleteButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20))
        constraints.append(deleteButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20))
        deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc private func onCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func onDeleteMatch() {
        let matchRef = db.collection("games").document(game.id).collection("matches").document(match.id)
        matchRef.delete() { (err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.matchUIViewControllerDelegate.onDeleteMatch(match: self.match)
                self.dismiss(animated: true)
            }
        }
    }
}
