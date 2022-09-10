//
//  GameTableViewCell.swift
//  score
//
//  Created by Matias Kupfer on 01.09.22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift
import Promises

class GameTableViewCell: UITableViewCell {

    static let identifier = "GameTableViewCell"
    
    let db: Firebase.Firestore = Firestore.firestore()
    var users: [UserModel] = [UserModel]()
    var game: GameModel!
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 5
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(GameUsersCollectionViewCell.self, forCellWithReuseIdentifier: GameUsersCollectionViewCell.identifier)
        return collectionView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        
        contentView.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public func configure(g: GameModel) {
        self.game = g
        self.titleLabel.text = g.name
        let c: GameColorModel = g.color
        self.titleLabel.textColor = UIColor(red: c.red, green: c.green, blue: c.blue, alpha: c.alpha)
        self.descriptionLabel.text = g.description
    }
    
    private func setUpConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        //        constraints.append(dateLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20))
        constraints.append(titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 10))
        titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        constraints.append(descriptionLabel.topAnchor.constraint(equalTo: titleLabel.safeAreaLayoutGuide.topAnchor, constant: 40))
        constraints.append(descriptionLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20))
        constraints.append(descriptionLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20))
        constraints.append(descriptionLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -40))

        NSLayoutConstraint.activate(constraints)
    }
    
    private func getUsers() {
        for userId in game.users {
            searchUser(userId: userId).then{(user: UserModel) in
                self.users.append(user)
            }.catch{(err: Error) in
                print(err)
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
}

extension GameTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return game.users.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GameUsersCollectionViewCell.identifier, for: indexPath) as? GameUsersCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        return cell
    }
    
    
}
