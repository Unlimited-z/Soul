//
//  AuthResult.swift
//  Soul
//
//  Created by Assistant on 2025-01-25.
//

import Foundation

// MARK: - Authentication Result
struct AuthResult {
    let user: User
    let isNewUser: Bool
    
    init(user: User, isNewUser: Bool = false) {
        self.user = user
        self.isNewUser = isNewUser
    }
}

// MARK: - Authentication Error
enum AuthError: Error, LocalizedError {
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case userNotFound
    case wrongPassword
    case networkError
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "邮箱格式不正确"
        case .weakPassword:
            return "密码强度不够，请使用至少6位字符"
        case .emailAlreadyInUse:
            return "该邮箱已被注册"
        case .userNotFound:
            return "用户不存在"
        case .wrongPassword:
            return "密码错误"
        case .networkError:
            return "网络连接失败，请检查网络设置"
        case .unknown(let message):
            return "未知错误: \(message)"
        }
    }
}

// MARK: - Login Credentials
struct LoginCredentials {
    let email: String
    let password: String
    
    var isValid: Bool {
        return !email.isEmpty && !password.isEmpty && isValidEmail
    }
    
    private var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

// MARK: - Registration Credentials
struct RegisterCredentials {
    let email: String
    let password: String
    let confirmPassword: String
    let displayName: String?
    
    var isValid: Bool {
        return !email.isEmpty && 
               !password.isEmpty && 
               password == confirmPassword && 
               password.count >= 6 && 
               isValidEmail
    }
    
    private var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    var validationError: AuthError? {
        if !isValidEmail {
            return .invalidEmail
        }
        if password.count < 6 {
            return .weakPassword
        }
        if password != confirmPassword {
            return .unknown("两次输入的密码不一致")
        }
        return nil
    }
}