//
//  ChatViewController.swift
//  Soul
//
//  Created by Ricard.li on 2025/7/16.
//

import UIKit
import SnapKit
import SoulNetwork

class ChatView: UIView {
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor.clear
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
        table.register(UserMessageCell.self, forCellReuseIdentifier: "UserMessageCell")
        table.register(AIMessageCell.self, forCellReuseIdentifier: "AIMessageCell")
        table.register(LoadingMessageCell.self, forCellReuseIdentifier: "LoadingMessageCell")
        table.register(WelcomeMessageCell.self, forCellReuseIdentifier: "WelcomeMessageCell")
        table.layer.cornerRadius = 20
        table.clipsToBounds = true
        return table
    }()
    
    private lazy var inputContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 25
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.1
        view.isHidden = true // 初始隐藏
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
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        textView.returnKeyType = .send
        return textView
    }()
    
    private lazy var inputControlView: InputControlView = {
        let view = InputControlView()
        view.onVoiceInputTapped = { [weak self] in
            self?.handleVoiceInput()
        }
        view.onTextInputTapped = { [weak self] in
            self?.showTextInput()
        }
        return view
    }()
    

    
    // MARK: - Data
    private var messages: [ChatMessage] = []
    private var isFirstAIMessage = true // 标识是否是第一条AI消息
    private var shouldClearOnNextForeground = false // 标识是否需要在下次进入前台时清空对话
    
    // 系统消息配置
    private let systemMessage = """
    你是使用者友善，智能的朋友。你的任务是：
    1. 与用户进行自然、有趣的对话
    2. 根据用户的需求提供帮助和建议
    3. 保持积极、耐心的态度
    4. 用简洁明了的语言回答问题
    
    请主动开始对话，并且询问用户你最近有没有什么喜欢的东西？。
    """
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        addObservers()
        // 标记需要在下次进入前台时清空对话（应用启动时）
        shouldClearOnNextForeground = true
        initializeConversationIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
        addObservers()
        // 标记需要在下次进入前台时清空对话（应用启动时）
        shouldClearOnNextForeground = true
        initializeConversationIfNeeded()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        backgroundColor = UIColor.clear
        addSubview(tableView)
        addSubview(inputContainer)
        addSubview(inputControlView)
        inputContainer.addSubview(textInputView)
        
        // 添加点击手势来隐藏键盘
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints() {
        // 消息列表填充大部分区域
        tableView.snp.makeConstraints { make in
//            make.top.left.right.equalToSuperview()
//            make.bottom.equalTo(inputControlView.snp.top).offset(-16)
            make.edges.equalToSuperview()
        }
        
        // 自定义输入控件固定在底部
        inputControlView.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.bottom.equalToSuperview()
        }
        
        // 输入区域固定在底部（初始隐藏）
        inputContainer.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(50)
        }
        
        // 文本输入框
        textInputView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Conversation Initialization
    private func initializeConversationIfNeeded() {
        // 先加载历史消息
        messages = ChatDataManager.shared.loadMessages()
        
        // 如果没有消息历史，让AI先发起对话
        if messages.isEmpty {
            isFirstAIMessage = true
            initiateAIConversation()
        } else {
            // 如果有历史消息，第一条AI消息已经存在
            isFirstAIMessage = false
            // 刷新表格并滚动到最后
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
                
                // 第一条AI消息已添加，更新标识
                self.isFirstAIMessage = false
                
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
    
    // MARK: - Observers
    private func addObservers() {
        // 键盘通知
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
        
        // 应用生命周期通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        // 计算键盘高度，需要考虑到父视图控制器约束中预留的TabBar高度
        // 当键盘弹出时，整个视图控制器被向上推，我们需要确保输入框在键盘上方
        let tabBarHeight: CGFloat = 80 // CustomTabBar的高度
        let keyboardHeight = keyboardFrame.height - tabBarHeight
        
        inputContainer.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(-keyboardHeight)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.superview?.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        inputContainer.snp.updateConstraints { make in
            make.bottom.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.superview?.layoutIfNeeded()
        }
    }
    
    // MARK: - App Lifecycle Handling
    @objc private func appDidEnterBackground() {
        // 应用进入后台时，不需要做任何操作
        // 用户希望只在应用完整启动时清空对话，而不是每次从后台切换回前台
    }
    
    @objc private func appWillEnterForeground() {
        // 应用即将进入前台时，检查是否需要清空对话（仅在应用启动时）
        if shouldClearOnNextForeground {
            clearConversationAndRestart()
            shouldClearOnNextForeground = false
        }
    }
    
    private func clearConversationAndRestart() {
        // 清空所有数据
        ChatDataManager.shared.clearAllData()
        messages.removeAll()
        isFirstAIMessage = true
        
        // 刷新界面
        tableView.reloadData()
        
        // 重新开始对话
        initiateAIConversation()
    }
    
    // MARK: - Actions
    @objc private func dismissKeyboard() {
        hideTextInput()
    }
    
    // MARK: - Input Control Methods
    private func handleVoiceInput() {
        // TODO: 实现语音输入功能
        print("语音输入功能待实现")
    }
    
    private func showTextInput() {
        // 隐藏自定义控件
        inputControlView.isHidden = true
        
        // 显示文本输入框
        inputContainer.isHidden = false
        
        // 重新设置tableView约束
        tableView.snp.remakeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(inputContainer.snp.top).offset(-16)
        }
        
        // 动画显示并聚焦
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        } completion: { _ in
            self.textInputView.becomeFirstResponder()
        }
    }
    
    private func hideTextInput() {
        // 收起键盘
        textInputView.resignFirstResponder()
        
        // 隐藏文本输入框
        inputContainer.isHidden = true
        
        // 显示自定义控件
        inputControlView.isHidden = false
        
        // 重新设置tableView约束
        tableView.snp.remakeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(inputControlView.snp.top).offset(-16)
        }
        
        // 动画隐藏
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    private func sendMessage() {
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
        
        // 保存用户消息
        ChatDataManager.shared.saveMessage(userMessage)
        
        // 隐藏文本输入框
        hideTextInput()
        
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
    

    
    private func scrollToLastMessage() {
        guard !messages.isEmpty else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    // MARK: - Public Methods
    func clearConversation() {
        // 只清除当前消息数据，不删除历史记录
        ChatDataManager.shared.clearCurrentMessages()
        messages.removeAll()
        
        // 重置第一条消息标识
        isFirstAIMessage = true
        
        // 刷新界面
        tableView.reloadData()
        
        // 重新初始化对话
        initiateAIConversation()
    }
}

// MARK: - UITableViewDataSource
extension ChatView: UITableViewDataSource {
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
            // 检查是否是第一条AI消息
            if indexPath.row == 0 && !message.isFromUser && message.id != "loading" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "WelcomeMessageCell", for: indexPath) as! WelcomeMessageCell
                cell.configure(with: message)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AIMessageCell", for: indexPath) as! AIMessageCell
                cell.configure(with: message)
                return cell
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension ChatView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = messages[indexPath.row]
        
        // 为第一条AI欢迎消息返回固定高度
        if indexPath.row == 0 && !message.isFromUser && message.id != "loading" {
            return WelcomeMessageCell.cellHeight()
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = messages[indexPath.row]
        
        // 为第一条AI欢迎消息返回预估高度
        if indexPath.row == 0 && !message.isFromUser && message.id != "loading" {
            return WelcomeMessageCell.cellHeight()
        }
        
        return 60
    }
}

// MARK: - UITextViewDelegate
extension ChatView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 检测回车键
        if text == "\n" {
            sendMessage()
            return false // 阻止换行
        }
        return true
    }
}
