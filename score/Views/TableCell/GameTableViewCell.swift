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
    var usersInfo: [UserModelInfo] = [UserModelInfo]()
    var game: GameModel!
    var winnersCount: Int?;
    var color: UIColor!;
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
//        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .horizontal
//        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
//        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.backgroundColor = .systemPink
        collectionView.register(GameUsersCollectionViewCell.self, forCellWithReuseIdentifier: GameUsersCollectionViewCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let height = CGFloat(100) // height of the collection view
        let width = contentView.frame.size.width
        return CGSize(width: width, height: height)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(self.titleLabel)
        contentView.addSubview(self.descriptionLabel)
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
        collectionView.frame = contentView.bounds
    }
    
    public func configure(g: GameModel) {
        self.game = g
        self.titleLabel.text = g.name
        let c: GameColorModel = g.color
        self.color = UIColor(red: c.red, green: c.green, blue: c.blue, alpha: c.alpha)
        self.titleLabel.textColor = self.color
        self.descriptionLabel.text = g.description
        
        getMatches()
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: collectionView.topAnchor),

            collectionView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func getMatches() {
        let matchesRef = db.collection("games").document(game.id).collection("matches").order(by: "date", descending: true)
        matchesRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                guard let documents = querySnapshot?.documents else {
                    return
                }
                if (documents.count == 0) {
                    print("no documents game table view cell")
                    return
                }
                var matches: [MatchModel] = []
                matches.append(contentsOf: documents.compactMap { queryDocumentSnapshot -> MatchModel? in
                    return try! queryDocumentSnapshot.data(as: MatchModel.self)
                })
                self.countMatchWinners(matches: matches)
            }
        }
    }
    
    private func countMatchWinners(matches: [MatchModel]) {
        var winnersIds: [String] = []
        for match in matches {
            winnersIds.append(match.order[0])
        }
        let winnersDictionary = Dictionary(winnersIds.map{ ($0, 1)}, uniquingKeysWith: +)
        self.winnersCount = winnersDictionary.count
        for winner in winnersDictionary {
            searchUser(userId: winner.key, wins: winner.value)
        }
    }
    
    private func searchUser(userId: String, wins: Int){
        let usersRef = db.collection("users").document(userId)
        usersRef.getDocument { [self] (document, error) in
            if let document = document, document.exists {
                self.usersInfo.append(UserModelInfo(user: try! document.data(as: UserModel.self), wins: wins))
                if (self.winnersCount == self.usersInfo.count) {
                    self.collectionView.reloadData()
                }
            } else {
                print("User not found")
            }
        }
    }
}

extension GameTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return usersInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GameUsersCollectionViewCell.identifier, for: indexPath) as? GameUsersCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(u: self.usersInfo[indexPath.row], c: self.color)
        return cell
    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.frame.width/5, height: 150)
//    }
}
