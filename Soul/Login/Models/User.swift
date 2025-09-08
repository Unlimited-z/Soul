//
//  User.swift
//  Soul
//
//  Created by Assistant on 2025-01-25.
//

import Foundation
import FirebaseAuth

// MARK: - User Model
struct User {
    let uid: String
    let email: String
    let displayName: String?
    let photoURL: URL?
    let createdAt: Date
    let lastLoginAt: Date?
    
    init(uid: String, email: String, displayName: String? = nil, photoURL: URL? = nil, createdAt: Date = Date(), lastLoginAt: Date? = nil) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
    }
    
    // 从 Firebase User 创建
    init(from firebaseUser: FirebaseAuth.User) {
        self.uid = firebaseUser.uid
        self.email = firebaseUser.email ?? ""
        self.displayName = firebaseUser.displayName
        self.photoURL = firebaseUser.photoURL
        self.createdAt = firebaseUser.metadata.creationDate ?? Date()
        self.lastLoginAt = firebaseUser.metadata.lastSignInDate
    }
}

// MARK: - User Extensions
extension User {
    var isAnonymous: Bool {
        return email.isEmpty
    }
    
    var initials: String {
        guard let displayName = displayName, !displayName.isEmpty else {
            return String(email.prefix(2)).uppercased()
        }
        
        let components = displayName.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return String(initials).uppercased()
    }
}

// MARK: - Codable Support
extension User: Codable {
    enum CodingKeys: String, CodingKey {
        case uid
        case email
        case displayName
        case photoURL
        case createdAt
        case lastLoginAt
    }
}

// MARK: - Equatable Support
extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid
    }
}

// MARK: - Hashable Support
extension User: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
}