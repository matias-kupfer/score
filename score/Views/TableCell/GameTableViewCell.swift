//
//  GameTableViewCell.swift
//  score
//
//  Created by Matias Kupfer on 01.09.22.
//

import UIKit

class GameTableViewCell: UITableViewCell {

    static let identifier = "GameTableViewCell"
    
    private let gameTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(gameTitleLabel)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public func configure(g: GameModel) {
        self.gameTitleLabel.text = g.name
        let c: GameColorModel = g.color
        self.backgroundColor = UIColor(red: c.red, green: c.green, blue: c.blue, alpha: c.alpha)
    }
    
    private func setUpConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        //        constraints.append(dateLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20))
        constraints.append(gameTitleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20))
        gameTitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        NSLayoutConstraint.activate(constraints)
    }
}
