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
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(nameLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    public func configure(with user: UserModel) {
        users.append(user)
        var label: UILabel = UILabel()
        label.text = "@" + user.username
        label.frame = bounds
        addSubview(label)
    }
    
    

}
