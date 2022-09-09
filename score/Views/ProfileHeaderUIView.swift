//
//  ProfileHeaderUIView.swift
//  score
//
//  Created by Matias Kupfer on 08.09.22.
//

import UIKit

class ProfileHeaderUIView: UIView {

    let text: UILabel = {
        let label = UILabel()
        label.text = "your profile."
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(text)
    }
    
    public func configure(g: [GameModel]) {
        text.text = "You have a total of " + String(g.count) + " games."
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

}
