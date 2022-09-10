//
//  UserCollectionViewCell.swift
//  score
//
//  Created by Matias Kupfer on 03.04.22.
//

import UIKit

class MatchUsersCollectionViewCell: UICollectionViewCell {
    static let identifier = "UserCollectionViewCell"
    
    
    let label: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let button: UIButton = {
        let button = UIButton()
        button.contentMode = .scaleToFill
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(button)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = contentView.bounds
        
    }
    
    public func configure(with user: UserModel, position: Int) {
        switch position {
        case 0:
            button.backgroundColor = .systemYellow
            
        case 1:
            button.backgroundColor = .systemGray
            
        case 2:
            button.backgroundColor = .systemBrown
            
        default:
            button.backgroundColor = .systemBlue
        }
        button.setTitle(user.name, for: .normal)
    }
    
}
