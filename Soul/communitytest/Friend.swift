//
//  Friend.swift
//  Soul
//
//  Created by Assistant on 2024/01/01.
//

import Foundation

enum relationship {
    case hot
    case normal
    case defaulted
}


// MARK: - 好友数据模型
struct Friend {
    let id: String
    let name: String
    let avatar: String
    let relation: relationship
    let lastSeen: Date?
    
    init(id: String, name: String, avatar: String, relation: relationship = .defaulted, lastSeen: Date? = nil) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.relation = relation
        self.lastSeen = lastSeen
    }
}

// MARK: - 留言数据模型
struct Message {
    let id: String
    let senderId: String
    let content: String
    let timestamp: Date
    
    init(id: String, senderId: String, content: String, timestamp: Date = Date()) {
        self.id = id
        self.senderId = senderId
        self.content = content
        self.timestamp = timestamp
    }
}

// MARK: - 模拟数据管理器
class CommunityTestDataManager {
    static let shared = CommunityTestDataManager()
    
    // 当前用户
    let currentUser = Friend(
        id: "user_001",
        name: "我",
        avatar: "👤",
//        isOnline: true
    )
    
    // 好友
    let friend = Friend(
        id: "user_002",
        name: "小明",
        avatar: "👨‍💻",
//        isOnline: true,
        lastSeen: Date()
    )
    
    // 留言列表
    private var messages: [Message] = []
    
    private init() {
        // 初始化一些示例留言
        setupInitialMessages()
    }
    
    private func setupInitialMessages() {
        let initialMessages = [
            Message(
                id: "msg_001",
                senderId: currentUser.id,
                content: "欢迎来到我的留言板！😊",
                timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
            ),
            Message(
                id: "msg_002",
                senderId: currentUser.id,
                content: "今天天气真不错呢！☀️",
                timestamp: Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date()
            ),
            Message(
                id: "msg_003",
                senderId: currentUser.id,
                content: "分享一些生活中的美好时刻～✨",
                timestamp: Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date()
            )
        ]
        
        messages.append(contentsOf: initialMessages)
    }
    
    // MARK: - 公共方法
    
    func getAllMessages() -> [Message] {
        return messages.sorted { $0.timestamp < $1.timestamp }
    }
    
    func getMessagesForUser(_ userId: String) -> [Message] {
        return messages.sorted { $0.timestamp < $1.timestamp }
    }
    
    func addMessage(_ content: String, senderId: String) {
        let newMessage = Message(
            id: "msg_\(UUID().uuidString.prefix(8))",
            senderId: senderId,
            content: content,
            timestamp: Date()
        )
        messages.append(newMessage)
    }
    
    func addMessage(_ message: Message) {
        messages.append(message)
    }
    
    func deleteMessage(_ messageId: String) {
        messages.removeAll { $0.id == messageId }
    }
}
