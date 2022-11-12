//
//  GameHeaderUIView.swift
//  score
//
//  Created by Matias Kupfer on 02.04.22.
//

import UIKit
import FirebaseAuth

class GameHeaderUIView: UIView {
    
    let auth = FirebaseAuth.Auth.auth()

    let usersLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome! Select a game to see more."
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(usersLabel)
    }
    
    public func configure(game: GameModel, users: [UserModel]) {
        usersLabel.text = (users.compactMap { user -> String in
            return user.username
        }).joined(separator:", ")
        let c = game.color
        backgroundColor = UIColor(red: c.red, green: c.green, blue: c.blue, alpha: c.alpha)
        
        setUpConstraints()
    }
    
    private func setUpConstraints() {
        let margins = layoutMarginsGuide
        var constraints = [NSLayoutConstraint]()
        
        //        constraints.append(x.topAnchor.constraint(equalTo: usersLabel.bottomAnchor, constant: 20))
        
        
        NSLayoutConstraint.activate(constraints)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}
