//
//  SectionHeaderUIView.swift
//  score
//
//  Created by Matias Kupfer on 29.08.22.
//

import UIKit
import SwiftUI

protocol SectionHeaderUIViewControllerDelegate: AnyObject {
    func onMatchTap(match: MatchModel)
}

class SectionHeaderUIView: UIView {
    
    public weak var sectionHeaderUIViewControllerDelegate: SectionHeaderUIViewControllerDelegate?
    
    public var match: MatchModel!
    
    let titleLable: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let editLable: UILabel = {
        let label = UILabel()
        label.text = "Edit"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .yellow
        return label
    }()
    
    let editIcon: UIImage = {
        let image = UIImage(systemName: "ellipsis")
        return image ?? UIImage()
    }()
    
    let editButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onEdit(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
        addSubview(titleLable)
        addSubview(editButton)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public func configure(m: MatchModel, game: GameModel) {
        match = m
        
        let c: GameColorModel = game.color
        let color = UIColor(red: c.red, green: c.green, blue: c.blue, alpha: c.alpha)
        titleLable.textColor = color
        editButton.tintColor = color
        editButton.setImage(editIcon, for: .normal)
        
        let myTimeInterval = TimeInterval(m.date)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        titleLable.text = formatter.string(from: NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval)) as Date) + " " + m.id
    }
    
    private func setUpConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(titleLable.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 20))
        constraints.append(titleLable.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor))
        constraints.append(titleLable.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor))
        
        constraints.append(editButton.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -20))
        constraints.append(editButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor))
        constraints.append(editButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc private func onEdit(_: UIBarButtonItem) {
        self.sectionHeaderUIViewControllerDelegate?.onMatchTap(match: match)
    }
}
