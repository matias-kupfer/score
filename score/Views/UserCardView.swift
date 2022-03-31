//
//  UserCardView.swift
//  score
//
//  Created by Matias Kupfer on 31.03.22.
//

import UIKit

class UserCardView: UIView {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .yellow
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(nameLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    public func configure(with user: UserModel) {
        self.nameLabel.text = "@" + user.username
        print(user)
    }
    
    

}
