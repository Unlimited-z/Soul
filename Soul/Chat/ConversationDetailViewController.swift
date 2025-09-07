//
//  ConversationDetailViewController.swift
//  Soul
//
//  Created by Ricard.li on 2025/1/13.
//

import UIKit
import SnapKit

class ConversationDetailViewController: BaseViewController {
    
    // MARK: - Data
    private let conversation: ConversationSession
    private var messages: [ChatMessage] = []
    
    // MARK: - UI Components
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = conversation.title
        label.font = UIFont(name: "SuezOne-Regular", size: 20)
        label.textColor = UIColor(red: 0.855, green: 0.949, blue: 0.714, alpha: 1.0)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = UIColor(red: 0.855, green: 0.949, blue: 0.714, alpha: 1.0)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(red: 0.855, green: 0.949, blue: 0.714, alpha: 0.7)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = UIColor.clear
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
        table.showsVerticalScrollIndicator = false
        table.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
        
        // 注册消息cell
        table.register(UserMessageCell.self, forCellReuseIdentifier: "UserMessageCell")
        table.register(AIMessageCell.self, forCellReuseIdentifier: "AIMessageCell")
        
        return table
    }()
    
    // MARK: - Initialization
    init(conversation: ConversationSession) {
        self.conversation = conversation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMessages()
        setupTimeLabel()
    }
    
    override func setupUI() {
        // 添加渐变背景
        let bg = GradientBackgroundView()
        view.addSubview(bg)
        bg.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(timeLabel)
        view.addSubview(tableView)
    }
    
    override func setupconstraint() {
        super.setupconstraint()
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.left.right.equalToSuperview().inset(60)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalToSuperview().inset(20)
            make.width.height.equalTo(30)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Data Loading
    private func loadMessages() {
        // 将PersistentChatMessage转换为ChatMessage
        messages = conversation.messages.map { persistentMessage in
            return ChatMessage(
                id: persistentMessage.id,
                content: persistentMessage.content,
                isFromUser: persistentMessage.isFromUser,
                timestamp: persistentMessage.timestamp
            )
        }
        
        tableView.reloadData()
        
        // 滚动到底部
        DispatchQueue.main.async {
            if !self.messages.isEmpty {
                let lastIndexPath = IndexPath(row: self.messages.count - 1, section: 0)
                self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
            }
        }
    }
    
    private func setupTimeLabel() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        timeLabel.text = formatter.string(from: conversation.createdAt)
    }
}

// MARK: - UITableViewDataSource
extension ConversationDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        if message.isFromUser {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserMessageCell", for: indexPath) as! UserMessageCell
            cell.configure(with: message)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AIMessageCell", for: indexPath) as! AIMessageCell
            cell.configure(with: message)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension ConversationDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
