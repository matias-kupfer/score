//
//  MatchTableViewCell.swift
//  score
//
//  Created by Matias Kupfer on 03.04.22.
//

import UIKit

class MatchTableViewCell: UITableViewCell {
    
    static let identifier = "MatchTableViewCell"
    
    var match: MatchModel!
    var users: [UserModel] = [UserModel]()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MatchUsersCollectionViewCell.self, forCellWithReuseIdentifier: MatchUsersCollectionViewCell.identifier)
        return collectionView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.bounds
    }
    
    public func configure(m: MatchModel, u: [UserModel]) {
        match = m
        users = u
        orderUsers()
        collectionView.reloadData()
    }
    
    private func orderUsers() {
        var orderedGameUsers: [UserModel] = []
        for userId in match.order {
            if let user = users.first(where: {$0.id == userId}) {
                orderedGameUsers.append(user)
            }
        }
        users = orderedGameUsers
    }
}

extension MatchTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MatchUsersCollectionViewCell.identifier, for: indexPath) as? MatchUsersCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: users[indexPath.row], position: indexPath.row)
        return cell
    }
    
    
}
