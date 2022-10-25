//
//  GameCollectionViewCell.swift
//  score
//
//  Created by Matias Kupfer on 31.08.22.
//

import UIKit

class GameUsersCollectionViewCell: UICollectionViewCell {
    static let identifier = "GameUsersCollectionViewCell"
    
    let winner: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(winner)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        winner.frame = contentView.bounds
    }
    public func configure(u: UserModelInfo, c: UIColor) {
        winner.text = u.user.name + " x" + String(u.wins)
        winner.textColor = c
    }
    
    let padding: CGFloat = 5
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
        
        ])
    }
}
