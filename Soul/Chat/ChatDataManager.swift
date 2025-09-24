//
//  ChatDataManager.swift
//  Soul
//
//  Created by Ricard.li on 2025/7/16.
//

import Foundation
import SoulNetwork

// MARK: - Persistent Chat Message Model
struct PersistentChatMessage: Codable {
    let id: String
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    
    // 从 ChatMessage 转换
    init(from chatMessage: ChatMessage) {
        self.id = chatMessage.id
        self.content = chatMessage.content
        self.isFromUser = chatMessage.isFromUser
        self.timestamp = chatMessage.timestamp
    }
}

// MARK: - Conversation Session Model
struct ConversationSession: Codable {
    let id: String
    let messages: [PersistentChatMessage]
    let createdAt: Date
    let title: String // 对话标题，可以是第一条用户消息的摘要
}

// MARK: - Chat Data Manager
class ChatDataManager {
    static let shared = ChatDataManager()
    
    private let userDefaults = UserDefaults.standard
    private let messagesKey = "SavedChatMessages"
    private let conversationHistoryKey = "ConversationHistory"
    private let maxConversationCount = 10
    
    private init() {}
    
    // MARK: - Message Management
    
    /// 保存单条消息
    func saveMessage(_ message: ChatMessage) {
        // 跳过加载消息
        guard message.id != "loading" else { return }
        
        let persistentMessage = PersistentChatMessage(from: message)
        var allMessages = getAllMessages()
        allMessages.append(persistentMessage)
        
        saveAllMessages(allMessages)
        
        print("💾 保存消息: \(message.content.prefix(50))...")
    }
    
    /// 加载历史消息
    func loadMessages() -> [ChatMessage] {
        let persistentMessages = getAllMessages()
        return persistentMessages.map { persistentMessage in
            ChatMessage(
                id: persistentMessage.id,
                content: persistentMessage.content,
                isFromUser: persistentMessage.isFromUser,
                timestamp: persistentMessage.timestamp
            )
        }
    }
    
    /// 获取所有消息
    private func getAllMessages() -> [PersistentChatMessage] {
        guard let data = userDefaults.data(forKey: messagesKey),
              let messages = try? JSONDecoder().decode([PersistentChatMessage].self, from: data) else {
            return []
        }
        return messages
    }
    
    /// 保存所有消息
    private func saveAllMessages(_ messages: [PersistentChatMessage]) {
        if let data = try? JSONEncoder().encode(messages) {
            userDefaults.set(data, forKey: messagesKey)
            userDefaults.synchronize() // 立即同步到磁盘
        }
    }
    
    // MARK: - Conversation History Management
    
    /// 保存当前对话到历史记录
    func saveCurrentConversationToHistory() {
        let currentMessages = getAllMessages()
        guard !currentMessages.isEmpty else {
            print("📝 当前对话为空，无需保存")
            return
        }
        
        // 生成对话标题（使用第一条用户消息的前20个字符）
        let title = generateConversationTitle(from: currentMessages)
        
        let conversation = ConversationSession(
            id: UUID().uuidString,
            messages: currentMessages,
            createdAt: Date(),
            title: title
        )
        
        var history = getConversationHistory()
        history.append(conversation)
        
        // 限制最多保存10轮对话
        if history.count > maxConversationCount {
            history.removeFirst(history.count - maxConversationCount)
        }
        
        saveConversationHistory(history)
        print("💾 已保存对话到历史记录，标题: \(title)")
    }
    
    /// 获取对话历史
    func getConversationHistory() -> [ConversationSession] {
        guard let data = userDefaults.data(forKey: conversationHistoryKey),
              let history = try? JSONDecoder().decode([ConversationSession].self, from: data) else {
            return []
        }
        return history
    }
    
    /// 保存对话历史
    private func saveConversationHistory(_ history: [ConversationSession]) {
        if let data = try? JSONEncoder().encode(history) {
            userDefaults.set(data, forKey: conversationHistoryKey)
            userDefaults.synchronize()
        }
    }
    
    /// 生成对话标题
    private func generateConversationTitle(from messages: [PersistentChatMessage]) -> String {
        // 找到第一条用户消息
        if let firstUserMessage = messages.first(where: { $0.isFromUser }) {
            let content = firstUserMessage.content.trimmingCharacters(in: .whitespacesAndNewlines)
            if content.count > 20 {
                return String(content.prefix(20)) + "..."
            } else {
                return content.isEmpty ? "新对话" : content
            }
        }
        return "新对话"
    }
    
    // MARK: - Data Management
    
    /// 清除当前对话数据（保存到历史后清空）
    func clearCurrentConversation() {
        // 先保存当前对话到历史
        saveCurrentConversationToHistory()
        
        // 清空当前对话的持久化数据
        userDefaults.removeObject(forKey: messagesKey)
        userDefaults.synchronize()
        
        print("🗑️ 已清除当前对话数据")
    }
    
    /// 只清除当前消息数据（不保存到历史）
    /// 注意：这个方法不删除UserDefaults中的数据，只是为了配合UI清除
    func clearCurrentMessages() {
        // 不删除UserDefaults中的数据，因为我们需要保持历史记录
        // 实际的数据清除由saveCurrentConversationToHistory完成
        print("🗑️ 准备清除当前对话数据（仅UI层面）")
    }
    
    /// 清除所有数据（包括历史对话）
    func clearAllData() {
        userDefaults.removeObject(forKey: messagesKey)
        userDefaults.removeObject(forKey: conversationHistoryKey)
        userDefaults.synchronize()
        
        print("🗑️ 清除所有聊天数据")
    }
    
    /// 获取数据统计信息
    func getTotalMessageCount() -> Int {
        return getAllMessages().count
    }
    
    /// 获取所有用户输入的消息内容（用于图片生成提示词）
    func getUserInputTexts() -> [String] {
        let allMessages = getAllMessages()
        return allMessages
            .filter { $0.isFromUser }
            .map { $0.content }
            .reversed() // 最新的在前面
    }
}
