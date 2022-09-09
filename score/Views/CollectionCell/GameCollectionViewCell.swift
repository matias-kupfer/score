//
//  GameCollectionViewCell.swift
//  score
//
//  Created by Matias Kupfer on 31.08.22.
//

import UIKit

class GameCollectionViewCell: UICollectionViewCell {
    static let identifier = "GameCollectionViewCell"
    
    let title: UILabel = {
        let label = UILabel()
        label.backgroundColor = .red
        label.text = "fjkdslfs"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let button: UIButton = {
        let button = UIButton()
        button.setTitle("dsfklsdf", for: .normal)
        button.contentMode = .scaleToFill
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(title)
        contentView.addSubview(button)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        title.frame = contentView.bounds
        button.frame = contentView.bounds
    }
    public func configure(with g: GameModel) {
        title.text = g.name
    }
    
    private func setUpConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(title.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor))
        constraints.append(title.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20))
        constraints.append(title.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20))
        title.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        NSLayoutConstraint.activate(constraints)
    }
}
