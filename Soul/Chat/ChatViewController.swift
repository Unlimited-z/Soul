//
//  ChatViewController.swift
//  Soul
//
//  Created by Ricard.li on 2025/7/16.
//

import UIKit
import SnapKit

struct ChatMessage {
    let id: String
    let content: String
    let isFromUser: Bool
    let timestamp: Date
}

class ChatViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor.systemBackground
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
        table.register(UserMessageCell.self, forCellReuseIdentifier: "UserMessageCell")
        table.register(AIMessageCell.self, forCellReuseIdentifier: "AIMessageCell")
        table.register(LoadingMessageCell.self, forCellReuseIdentifier: "LoadingMessageCell")
        return table
    }()
    
    private lazy var inputContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var textInputView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.clear
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = UIColor.label
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.textContainer.lineBreakMode = .byWordWrapping
        return textView
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("发送", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 20
        button.isEnabled = false
        button.alpha = 0.5
        button.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Data
    private var messages: [ChatMessage] = []
    
    // 系统消息配置
    private let systemMessage = """
    你是使用者友善、智能的朋友。你的任务是：
    1. 与用户进行自然、有趣的对话
    2. 根据用户的需求提供帮助和建议
    3. 保持积极、耐心的态度
    4. 用简洁明了的语言回答问题
    
    请主动开始对话，并且询问用户你最近有没有什么喜欢的东西？。
    """
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupNavigationBar()
        addKeyboardObservers()
        
        // 检查是否需要初始化对话
        initializeConversationIfNeeded()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        view.addSubview(tableView)
        view.addSubview(inputContainer)
        inputContainer.addSubview(textInputView)
        inputContainer.addSubview(sendButton)
    }
    
    private func setupConstraints() {
        // 消息列表填充大部分区域
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputContainer.snp.top).offset(-16)
        }
        
        // 输入区域固定在底部
        inputContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.greaterThanOrEqualTo(50)
        }
        
        // 文本输入框
        textInputView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(12)
            make.trailing.equalTo(sendButton.snp.leading).offset(-8)
        }
        
        // 发送按钮
        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
            make.width.height.equalTo(40)
        }
    }
    
    private func setupNavigationBar() {
        title = "AI 助手"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // 添加清除对话按钮
        let clearButton = UIBarButtonItem(
            title: "清除",
            style: .plain,
            target: self,
            action: #selector(clearConversationTapped)
        )
        navigationItem.rightBarButtonItem = clearButton
    }
    
    @objc private func clearConversationTapped() {
        let alert = UIAlertController(
            title: "清除对话",
            message: "确定要清除所有对话记录吗？这个操作无法撤销。",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "清除", style: .destructive) { [weak self] _ in
            self?.clearConversation()
        })
        
        present(alert, animated: true)
    }
    
    private func clearConversation() {
        // 清除数据
        ChatDataManager.shared.clearAllData()
        messages.removeAll()
        
        // 刷新界面
        tableView.reloadData()
        
        // 重新初始化对话
        initiateAIConversation()
    }
    
    // MARK: - Conversation Initialization
    private func initializeConversationIfNeeded() {
        // 先加载历史消息
        messages = ChatDataManager.shared.loadMessages()
        
        // 如果没有消息历史，让AI先发起对话
        if messages.isEmpty {
            initiateAIConversation()
        } else {
            // 如果有历史消息，刷新表格并滚动到最后
            tableView.reloadData()
            scrollToLastMessage()
        }
    }
    
    private func initiateAIConversation() {
        // 添加正在输入指示器
        let loadingMessage = ChatMessage(
            id: "loading",
            content: "正在初始化对话...",
            isFromUser: false,
            timestamp: Date()
        )
        
        messages.append(loadingMessage)
        tableView.reloadData()
        scrollToLastMessage()
        
        DoubaoAIService.shared.initiateConversation(systemMessage: systemMessage) { [weak self] result in
            guard let self = self else { return }
            
            // 移除加载消息
            if let lastMessage = self.messages.last, lastMessage.id == "loading" {
                self.messages.removeLast()
            }
            
            switch result {
            case .success(let aiResponse):
                let aiMessage = ChatMessage(
                    id: UUID().uuidString,
                    content: aiResponse,
                    isFromUser: false,
                    timestamp: Date()
                )
                self.messages.append(aiMessage)
                
                // 保存 AI 消息
                ChatDataManager.shared.saveMessage(aiMessage)
                
            case .failure(let error):
                let errorMessage = ChatMessage(
                    id: UUID().uuidString,
                    content: "抱歉，初始化对话时遇到了问题：\(error.localizedDescription)",
                    isFromUser: false,
                    timestamp: Date()
                )
                self.messages.append(errorMessage)
                
                // 保存错误消息
                ChatDataManager.shared.saveMessage(errorMessage)
            }
            
            self.tableView.reloadData()
            self.scrollToLastMessage()
        }
    }
    
    // MARK: - Keyboard Handling
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        inputContainer.snp.updateConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-keyboardFrame.height + view.safeAreaInsets.bottom)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        inputContainer.snp.updateConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Actions
    @objc private func sendButtonTapped() {
        guard !textInputView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let messageText = textInputView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let userMessage = ChatMessage(
            id: UUID().uuidString,
            content: messageText,
            isFromUser: true,
            timestamp: Date()
        )
        
        messages.append(userMessage)
        textInputView.text = ""
        updateSendButtonState()
        
        // 保存用户消息
        ChatDataManager.shared.saveMessage(userMessage)
        
        tableView.reloadData()
        scrollToLastMessage()
        
        // 发送到 AI 服务
        sendToAI(userMessage: messageText)
    }
    
    private func sendToAI(userMessage: String) {
        // 添加正在输入指示器
        let loadingMessage = ChatMessage(
            id: "loading",
            content: "正在思考中...",
            isFromUser: false,
            timestamp: Date()
        )
        
        messages.append(loadingMessage)
        tableView.reloadData()
        scrollToLastMessage()
        
        // 获取对话历史（排除当前加载消息）
        let conversationHistory = messages.dropLast().map { $0 }
        
        DoubaoAIService.shared.sendMessage(
            userMessage, 
            systemMessage: systemMessage,
            conversationHistory: Array(conversationHistory)
        ) { [weak self] result in
            guard let self = self else { return }
            
            // 移除加载消息
            if let lastMessage = self.messages.last, lastMessage.id == "loading" {
                self.messages.removeLast()
            }
            
            switch result {
            case .success(let aiResponse):
                let aiMessage = ChatMessage(
                    id: UUID().uuidString,
                    content: aiResponse,
                    isFromUser: false,
                    timestamp: Date()
                )
                                 self.messages.append(aiMessage)
                 
                 // 保存 AI 消息
                 ChatDataManager.shared.saveMessage(aiMessage)
                 
             case .failure(let error):
                 let errorMessage = ChatMessage(
                     id: UUID().uuidString,
                     content: "抱歉，我遇到了一些问题：\(error.localizedDescription)",
                     isFromUser: false,
                     timestamp: Date()
                 )
                 self.messages.append(errorMessage)
                 
                 // 保存错误消息
                 ChatDataManager.shared.saveMessage(errorMessage)
            }
            
            self.tableView.reloadData()
            self.scrollToLastMessage()
        }
    }
    
    private func updateSendButtonState() {
        let hasText = !textInputView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        sendButton.isEnabled = hasText
        sendButton.alpha = hasText ? 1.0 : 0.5
    }
    
    private func scrollToLastMessage() {
        guard !messages.isEmpty else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        if message.isFromUser {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserMessageCell", for: indexPath) as! UserMessageCell
            cell.configure(with: message)
            return cell
        } else if message.id == "loading" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingMessageCell", for: indexPath) as! LoadingMessageCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AIMessageCell", for: indexPath) as! AIMessageCell
            cell.configure(with: message)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - UITextViewDelegate
extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateSendButtonState()
    }
}
