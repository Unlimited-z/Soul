//
//  AuthService.swift
//  Soul
//
//  Created by Assistant on 2025-01-25.
//

import Foundation
import FirebaseAuth
import Combine

// MARK: - Notification Names
extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
    static let userDidLogout = Notification.Name("userDidLogout")
}

// MARK: - Authentication Service Protocol
protocol AuthServiceProtocol {
    var currentUser: User? { get }
    var isAuthenticated: Bool { get }
    var authStatePublisher: AnyPublisher<User?, Never> { get }
    
    func signIn(with credentials: LoginCredentials) async throws -> AuthResult
    func signUp(with credentials: RegisterCredentials) async throws -> AuthResult
    func signOut() throws
    func deleteAccount() async throws
    func updateProfile(displayName: String?, photoURL: URL?) async throws
    func sendPasswordReset(to email: String) async throws
}

// MARK: - Firebase Authentication Service
class AuthService: AuthServiceProtocol {
    static let shared = AuthService()
    
    private let auth = Auth.auth()
    private let authStateSubject = CurrentValueSubject<User?, Never>(nil)
    
    private init() {
        setupAuthStateListener()
    }
    
    // MARK: - Public Properties
    var currentUser: User? {
        guard let firebaseUser = auth.currentUser else { return nil }
        return User(from: firebaseUser)
    }
    
    var isAuthenticated: Bool {
        return auth.currentUser != nil
    }
    
    var authStatePublisher: AnyPublisher<User?, Never> {
        return authStateSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    private func setupAuthStateListener() {
        auth.addStateDidChangeListener { [weak self] _, firebaseUser in
            let user = firebaseUser.map { User(from: $0) }
            self?.authStateSubject.send(user)
        }
    }
    
    private func mapFirebaseError(_ error: Error) -> AuthError {
        guard let authError = error as NSError? else {
            return .unknown(error.localizedDescription)
        }
        
        switch AuthErrorCode(rawValue: authError.code) {
        case .invalidEmail:
            return .invalidEmail
        case .weakPassword:
            return .weakPassword
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .userNotFound:
            return .userNotFound
        case .wrongPassword:
            return .wrongPassword
        case .networkError:
            return .networkError
        default:
            return .unknown(authError.localizedDescription)
        }
    }
    
    // MARK: - Authentication Methods
    func signIn(with credentials: LoginCredentials) async throws -> AuthResult {
        guard credentials.isValid else {
            throw AuthError.invalidEmail
        }
        
        do {
            let authResult = try await auth.signIn(withEmail: credentials.email, password: credentials.password)
            let user = User(from: authResult.user)
            
            // 发送登录成功通知
            NotificationCenter.default.post(name: .userDidLogin, object: user)
            
            return AuthResult(user: user, isNewUser: false)
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    func signUp(with credentials: RegisterCredentials) async throws -> AuthResult {
        guard credentials.isValid else {
            if let validationError = credentials.validationError {
                throw validationError
            }
            throw AuthError.invalidEmail
        }
        
        do {
            let authResult = try await auth.createUser(withEmail: credentials.email, password: credentials.password)
            
            // 更新用户显示名称
            if let displayName = credentials.displayName, !displayName.isEmpty {
                let changeRequest = authResult.user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                try await changeRequest.commitChanges()
            }
            
            let user = User(from: authResult.user)
            
            // 发送登录成功通知（注册成功即登录）
            NotificationCenter.default.post(name: .userDidLogin, object: user)
            
            return AuthResult(user: user, isNewUser: true)
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    func signOut() throws {
        do {
            try auth.signOut()
            
            // 发送登出成功通知
            NotificationCenter.default.post(name: .userDidLogout, object: nil)
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    func deleteAccount() async throws {
        guard let user = auth.currentUser else {
            throw AuthError.userNotFound
        }
        
        do {
            try await user.delete()
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    func updateProfile(displayName: String?, photoURL: URL?) async throws {
        guard let user = auth.currentUser else {
            throw AuthError.userNotFound
        }
        
        do {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            changeRequest.photoURL = photoURL
            try await changeRequest.commitChanges()
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    func sendPasswordReset(to email: String) async throws {
        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch {
            throw mapFirebaseError(error)
        }
    }
}

// MARK: - Mock Authentication Service (for testing)
class MockAuthService: AuthServiceProtocol {
    private let authStateSubject = CurrentValueSubject<User?, Never>(nil)
    private var _currentUser: User?
    
    var currentUser: User? {
        return _currentUser
    }
    
    var isAuthenticated: Bool {
        return _currentUser != nil
    }
    
    var authStatePublisher: AnyPublisher<User?, Never> {
        return authStateSubject.eraseToAnyPublisher()
    }
    
    func signIn(with credentials: LoginCredentials) async throws -> AuthResult {
        // 模拟网络延迟
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        guard credentials.isValid else {
            throw AuthError.invalidEmail
        }
        
        // 模拟用户
        let user = User(
            uid: UUID().uuidString,
            email: credentials.email,
            displayName: "测试用户",
            photoURL: nil
        )
        
        _currentUser = user
        authStateSubject.send(user)
        
        return AuthResult(user: user, isNewUser: false)
    }
    
    func signUp(with credentials: RegisterCredentials) async throws -> AuthResult {
        // 模拟网络延迟
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        guard credentials.isValid else {
            if let validationError = credentials.validationError {
                throw validationError
            }
            throw AuthError.invalidEmail
        }
        
        // 模拟用户
        let user = User(
            uid: UUID().uuidString,
            email: credentials.email,
            displayName: credentials.displayName ?? "新用户",
            photoURL: nil
        )
        
        _currentUser = user
        authStateSubject.send(user)
        
        return AuthResult(user: user, isNewUser: true)
    }
    
    func signOut() throws {
        _currentUser = nil
        authStateSubject.send(nil)
    }
    
    func deleteAccount() async throws {
        _currentUser = nil
        authStateSubject.send(nil)
    }
    
    func updateProfile(displayName: String?, photoURL: URL?) async throws {
        guard var user = _currentUser else {
            throw AuthError.userNotFound
        }
        
        // 由于 User 是 struct，需要重新创建
        let updatedUser = User(
            uid: user.uid,
            email: user.email,
            displayName: displayName ?? user.displayName,
            photoURL: photoURL ?? user.photoURL,
            createdAt: user.createdAt,
            lastLoginAt: user.lastLoginAt
        )
        
        _currentUser = updatedUser
        authStateSubject.send(updatedUser)
    }
    
    func sendPasswordReset(to email: String) async throws {
        // 模拟网络延迟
        try await Task.sleep(nanoseconds: 500_000_000)
    }
}