//
//  GameModel.swift
//  score
//
//  Created by Matias Kupfer on 28.03.22.
//

import Foundation
import UIKit

struct GameModel: Codable {
    var name: String
    var users: [String]
    var color: GameColorModel
}

struct GameColorModel: Codable {
    var red: CGFloat
    var blue: CGFloat
    var green: CGFloat
    var alpha:CGFloat
}
