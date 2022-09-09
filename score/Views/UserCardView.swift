//
//  UserCardView.swift
//  score
//
//  Created by Matias Kupfer on 31.03.22.
//

import UIKit

class UserCardView: UIView {
    
    var users: [UserModel] = [UserModel]()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
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
        users.append(user)
        nameLabel.text = nameLabel.text! + "@" + user.username + ", "
    }
    
    

}
