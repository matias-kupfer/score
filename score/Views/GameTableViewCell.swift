//
//  GameTableViewCell.swift
//  score
//
//  Created by Matias Kupfer on 29.03.22.
//

import UIKit

class GameTableViewCell: UITableViewCell {
    
    static let identifier = "GameTableViewCell"


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public func configure() {
        
    }

}
