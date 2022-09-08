//
//  TabBarViewController.swift
//  score
//
//  Created by Matias Kupfer on 28.03.22.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.backgroundColor = .systemBackground
        
        let vc1 = UINavigationController(rootViewController: HomeViewController())
        let vc2 = UINavigationController(rootViewController: ProfileViewController())
        
        vc1.tabBarItem.image = UIImage(systemName: "list.number")
        vc2.tabBarItem.image = UIImage(systemName: "person")
        
        vc1.title = "Scores"
        vc2.title = "Profile"
        
        setViewControllers([vc1, vc2], animated: true)
    }

}
