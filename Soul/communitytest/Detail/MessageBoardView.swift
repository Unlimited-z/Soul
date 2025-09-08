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
    private var image : [String] = ["avatar1","avatar2","avatar3"]
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let messagesTableView = UITableView()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        loadMessages()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
        loadMessages()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        backgroundColor = .white
        
        // 标题设置
        titleLabel.text = "我的留言板"
        titleLabel.font = .systemFont(ofSize: 24, weight: .medium)
        titleLabel.textAlignment = .center
        
        // TableView设置
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        messagesTableView.register(MessageTableViewCell.self, forCellReuseIdentifier: "MessageTableViewCell")
        messagesTableView.backgroundColor = .clear
        messagesTableView.isScrollEnabled = false
        messagesTableView.separatorStyle = .none
        messagesTableView.estimatedRowHeight = 80
        messagesTableView.rowHeight = UITableView.automaticDimension
        
        // 添加子视图
        addSubview(titleLabel)
        addSubview(messagesTableView)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        messagesTableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(200) // 设置初始高度
        }
    }
    
    // MARK: - Public Methods
    func loadMessages() {
        messages = dataManager.getAllMessages()
        messagesTableView.reloadData()
        updateTableViewHeight()
    }
    
    // MARK: - Private Methods
    private func updateTableViewHeight() {
        DispatchQueue.main.async {
            self.messagesTableView.layoutIfNeeded()
            let contentHeight = self.messagesTableView.contentSize.height
            self.messagesTableView.snp.updateConstraints { make in
                make.height.equalTo(max(contentHeight, 200))
            }
            self.delegate?.messageBoardViewDidUpdateHeight(self)
        }
    }
}

// MARK: - UITableViewDataSource & Delegate
extension MessageBoardView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as! MessageTableViewCell
        let message = indexPath.row < messages.count ? messages[indexPath.row] : Message(id: "default", senderId: "user", content: "示例留言 \(indexPath.row + 1)", timestamp: Date())
        cell.configure(with: message, currentUserId: dataManager.currentUser.id, avatarImageName: image[indexPath.row])
        return cell
    }
}

// MARK: - MessageTableViewCell
class MessageTableViewCell: UITableViewCell {
    private let containerView = UIView()
    private let messageLabel = UILabel()
    private let avatarImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // 容器视图设置
        containerView.backgroundColor = AppTheme.Colors.primaryYellow
        containerView.layer.cornerRadius = 20
        
        // 消息标签设置
        messageLabel.font = .systemFont(ofSize: 16, weight: .medium)
        messageLabel.textColor = .gray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .left
        
        // 头像设置
        avatarImageView.image = UIImage(named: "avatar1") // 使用默认头像
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.clipsToBounds = true
        
        // 添加子视图
        contentView.addSubview(containerView)
        containerView.addSubview(messageLabel)
        containerView.addSubview(avatarImageView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(-16)
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(messageLabel.snp.bottom).offset(16)
            make.width.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    func configure(with message: Message, currentUserId: String, avatarImageName: String) {
        messageLabel.text = message.content
        
        // 使用传入的头像名称
        avatarImageView.image = UIImage(named: avatarImageName)
    }
}
