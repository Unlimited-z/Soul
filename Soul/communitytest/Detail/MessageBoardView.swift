//
//  MessageBoardView.swift
//  Soul
//
//  Created by Assistant on 2024/01/01.
//

import UIKit
import SnapKit

// MARK: - MessageBoardViewDelegate
protocol MessageBoardViewDelegate: AnyObject {
    func messageBoardView(_ view: MessageBoardView, didSendMessage message: Message)
    func messageBoardViewDidUpdateHeight(_ view: MessageBoardView)
}

// MARK: - MessageBoardView
class MessageBoardView: UIView {
    
    // MARK: - Properties
    weak var delegate: MessageBoardViewDelegate?
    private let dataManager = CommunityTestDataManager.shared
    private var messages: [Message] = []
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let messagesCollectionView: UICollectionView
    private let messageInputView = UIView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        messagesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        loadMessages()
    }
    
    required init?(coder: NSCoder) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        messagesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(coder: coder)
        setupUI()
        setupConstraints()
        loadMessages()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        backgroundColor = .clear
        
        // 标题设置
        titleLabel.text = "📝 我的留言板"
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        
        // CollectionView设置
        messagesCollectionView.delegate = self
        messagesCollectionView.dataSource = self
        messagesCollectionView.register(MessageCollectionCell.self, forCellWithReuseIdentifier: "MessageCollectionCell")
        messagesCollectionView.backgroundColor = .clear
        messagesCollectionView.isScrollEnabled = false
        
        // 输入区域设置
        messageInputView.backgroundColor = .systemGray6
        messageInputView.layer.cornerRadius = 12
        messageInputView.isUserInteractionEnabled = true
        
        messageTextField.placeholder = "在留言板上留言..."
        messageTextField.borderStyle = .none
        messageTextField.backgroundColor = .white
        messageTextField.layer.cornerRadius = 8
        messageTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        messageTextField.leftViewMode = .always
        messageTextField.isUserInteractionEnabled = true
        messageTextField.isEnabled = true
        messageTextField.returnKeyType = .send
        messageTextField.delegate = self
        
        sendButton.setTitle("发送", for: .normal)
        sendButton.backgroundColor = .systemBlue
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.layer.cornerRadius = 8
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        
        // 添加子视图
        addSubview(titleLabel)
        addSubview(messagesCollectionView)
        addSubview(messageInputView)
        messageInputView.addSubview(messageTextField)
        messageInputView.addSubview(sendButton)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        messagesCollectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(200) // 设置初始高度
        }
        
        messageInputView.snp.makeConstraints { make in
            make.top.equalTo(messagesCollectionView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(56)
        }
        
        messageTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(sendButton.snp.leading).offset(-12)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
        }
        
        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(70)
            make.height.equalTo(40)
        }
    }
    
    // MARK: - Public Methods
    func loadMessages() {
        messages = dataManager.getAllMessages()
        messagesCollectionView.reloadData()
        updateCollectionViewHeight()
    }
    
    func getMessageTextField() -> UITextField {
        return messageTextField
    }
    
    // MARK: - Private Methods
    private func updateCollectionViewHeight() {
        DispatchQueue.main.async {
            self.messagesCollectionView.layoutIfNeeded()
            let contentHeight = self.messagesCollectionView.contentSize.height
            self.messagesCollectionView.snp.updateConstraints { make in
                make.height.equalTo(max(contentHeight, 200))
            }
            self.delegate?.messageBoardViewDidUpdateHeight(self)
        }
    }
    
    // MARK: - Actions
    @objc private func sendButtonTapped() {
        guard let text = messageTextField.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        // 创建新消息
        let newMessage = Message(
            id: UUID().uuidString,
            senderId: dataManager.currentUser.id,
            content: text,
            timestamp: Date()
        )
        
        // 添加消息到留言板
        dataManager.addMessage(newMessage)
        
        // 通知代理
        delegate?.messageBoardView(self, didSendMessage: newMessage)
        
        // 重新加载数据
        loadMessages()
        
        // 清空输入框
        messageTextField.text = ""
        
        // 滚动到底部
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let lastItem = self.messages.count - 1
            if lastItem >= 0 {
                let indexPath = IndexPath(item: lastItem, section: 0)
                self.messagesCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension MessageBoardView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == messageTextField {
            sendButtonTapped()
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("留言板文本框开始编辑")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("留言板文本框结束编辑")
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension MessageBoardView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageCollectionCell", for: indexPath) as! MessageCollectionCell
        let message = messages[indexPath.item]
        cell.configure(with: message, currentUserId: dataManager.currentUser.id)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 8 * 3 // 左右边距 + 中间间距
        let availableWidth = collectionView.frame.width - padding
        let cellWidth = availableWidth / 2 // 一行两个cell
        return CGSize(width: cellWidth, height: cellWidth) // 正方形
    }
}

// MARK: - MessageCollectionCell
class MessageCollectionCell: UICollectionViewCell {
    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        bubbleView.backgroundColor = .systemBlue
        bubbleView.layer.cornerRadius = 12
        
        messageLabel.font = .systemFont(ofSize: 14, weight: .medium)
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        timeLabel.font = .systemFont(ofSize: 10)
        timeLabel.textColor = .systemGray
        timeLabel.textAlignment = .center
        
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        contentView.addSubview(timeLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        bubbleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.trailing.equalToSuperview().inset(4)
            make.bottom.equalTo(timeLabel.snp.top).offset(-4)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.height.equalTo(12)
        }
    }
    
    func configure(with message: Message, currentUserId: String) {
        messageLabel.text = message.content
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        timeLabel.text = formatter.string(from: message.timestamp)
        
        // 所有消息都使用相同的样式，因为只显示用户自己的留言
        bubbleView.backgroundColor = .systemBlue
        messageLabel.textColor = .white
    }
}