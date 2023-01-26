//
//  UserModel.swift
//  score
//
//  Created by Matias Kupfer on 31.03.22.
//

import Foundation

struct UserModel: Codable {
    let id: String;
    let email: String;
    let username: String
}

struct UserModelInfo: Codable {
    let user: UserModel
    let wins: Int
}
