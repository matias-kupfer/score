//
//  FirestoreService.swift
//  score
//
//  Created by Matias Kupfer on 26.01.23.
//

import Foundation
import Firebase

class FirebaseService {
    let db: Firebase.Firestore = Firestore.firestore()
    
    static let shared = FirebaseService()
    private init() {}
    
    func getGamesByUserId(userId: String, completion: @escaping ([GameModel]) -> Void) {
        let gamesRef = db.collection("games").whereField("players", arrayContains: userId)
        gamesRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching games: \(error)")
                completion([])
                return
            }
            let decoder = JSONDecoder()
            let games = querySnapshot?.documents.compactMap { (document) -> GameModel? in
                do {
                    let data = document.data()
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    return try decoder.decode(GameModel.self, from: jsonData)
                } catch {
                    print("Error decoding game: \(error)")
                    return nil
                }
            }
            completion(games ?? [])
        }
    }
    
    func getMatches(gameId: String, completion: @escaping ([MatchModel]) -> Void) {
        let matchesRef = db.collection("games").document(gameId).collection("matches").order(by: "date", descending: true)
        matchesRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching matches: \(error)")
                completion([])
                return
            }
            let decoder = JSONDecoder()
            let match = querySnapshot?.documents.compactMap { (document) -> MatchModel? in
                do {
                    let data = document.data()
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    return try decoder.decode(MatchModel.self, from: jsonData)
                } catch {
                    print("Error decoding match: \(error)")
                    return nil
                }
            }
            completion(match ?? [])
        }
    }
    
    func getGameUsers(usersIds: [String], completion: @escaping ([UserModel]) -> Void) {
        var gameUsers = [UserModel]()
        let group = DispatchGroup()
        for userId in usersIds {
            group.enter()
            getUserById(userId: userId) { user in
                if let user {
                    gameUsers.append(user)
                } else {
                    print("user not found")
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion(gameUsers ?? [])
        }
    }
    
    func getUserById(userId: String, completion: @escaping (UserModel?) -> Void) {
        let gamesRef = db.collection("users").document(userId)
        gamesRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching user: \(error)")
                completion(nil)
                return
            }
            let decoder = JSONDecoder()
            if let document = document, document.exists {
                do {
                    let data = document.data()
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    let user = try decoder.decode(UserModel.self, from: jsonData)
                    completion(user)
                } catch {
                    print("Error decoding game: \(error)")
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    
    func searchUserByUsername(username: String, completion: @escaping (UserModel?, Error?) -> Void) {
        let userRef = db.collection("users").whereField("username", isEqualTo: username).limit(to: 1)
        userRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                if let snapshot = querySnapshot, !snapshot.isEmpty {
                    let user: UserModel = try! snapshot.documents[0].data(as: UserModel.self)
                    completion(user, nil)
                } else {
                    completion(nil, nil)
                }
            }
        }
    }
    
    func saveMatch(gameId: String, match: MatchModel, completion: @escaping (_ error: Error?, _ documentRef: DocumentReference?) -> Void) {
        do {
            let matchRef = try db.collection("games").document(gameId).collection(gameId).addDocument(from: match)
            matchRef.updateData(["id": matchRef.documentID]) { (error: Error?) in
                if let error = error {
                    completion(error, nil)
                } else {
                    completion(nil, matchRef)
                }
            }
        } catch let error {
            completion(error, nil)
        }
    }
    
    func saveGame(game: GameModel, completion: @escaping (_ error: Error?, _ documentRef: DocumentReference?) -> Void) {
        do {
            let gameRef = try db.collection("games").addDocument(from: game)
            gameRef.updateData(["id": gameRef.documentID]) { (error: Error?) in
                if let error = error {
                    completion(error, nil)
                } else {
                    completion(nil, gameRef)
                }
            }
        } catch let error {
            completion(error, nil)
        }
    }
    
    func deleteMatch(gameId: String, matchId: String, completion: @escaping (_ error: Error?) -> Void) {
        let matchRef = db.collection("games").document(gameId).collection("matches").document(matchId)
        matchRef.delete() { (error: Error?) in
            if let error = error {
                completion(error)
                print("Error getting documents: \(error)")
            } else {
                completion(nil)
            }
        }
    }
    
    func saveUser(user: UserModel, completion: @escaping(_ error: Error?) -> Void) {
        do {
            try db.collection("users").document(user.id).setData(from: user) { error in
                if let error = error {
                    completion(error)
                    print("Error setting data: \(error)")
                } else {
                    completion(nil)
                }
            }
        } catch let error {
            completion(error)
        }
    }
    
}
