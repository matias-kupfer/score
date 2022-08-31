//
//  GameTableViewCell.swift
//  score
//
//  Created by Matias Kupfer on 31.08.22.
//

import UIKit

class GameTableViewCell: UITableViewCell {
    
    static let identifier = "GameTableViewCell"
    
    var games: [GameModel]!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public func configure(g: [GameModel]) {
        
    }

}
