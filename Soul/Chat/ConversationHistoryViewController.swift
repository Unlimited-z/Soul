//
//  ConversationHistoryViewController.swift
//  Soul
//
//  Created by Ricard.li on 2025/1/13.
//

import UIKit
import SnapKit

class ConversationHistoryViewController: BaseViewController {
    
    // MARK: - Data
    private var conversationHistory: [ConversationSession] = []
    
    // MARK: - UI Components
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "对话记录"
        label.font = UIFont(name: "SuezOne-Regular", size: 28)
        label.textColor = UIColor(red: 0.855, green: 0.949, blue: 0.714, alpha: 1.0)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = UIColor(red: 0.855, green: 0.949, blue: 0.714, alpha: 1.0)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = UIColor.clear
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
        table.register(ConversationHistoryCell.self, forCellReuseIdentifier: "ConversationHistoryCell")
        table.layer.cornerRadius = 20
        table.clipsToBounds = true
        return table
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "message.circle")
        imageView.tintColor = UIColor(red: 0.855, green: 0.949, blue: 0.714, alpha: 0.6)
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = "暂无对话记录"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor(red: 0.855, green: 0.949, blue: 0.714, alpha: 0.8)
        label.textAlignment = .center
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-30)
            make.width.height.equalTo(80)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadConversationHistory()
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
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
    }
    
    override func setupconstraint() {
        super.setupconstraint()
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalToSuperview().inset(20)
            make.width.height.equalTo(30)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        emptyStateView.snp.makeConstraints { make in
            make.center.equalTo(tableView)
            make.width.equalTo(200)
            make.height.equalTo(150)
        }
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Data Loading
    private func loadConversationHistory() {
        conversationHistory = ChatDataManager.shared.getConversationHistory()
        updateUI()
    }
    
    private func updateUI() {
        tableView.reloadData()
        emptyStateView.isHidden = !conversationHistory.isEmpty
        tableView.isHidden = conversationHistory.isEmpty
    }
    
    // MARK: - Helper Methods
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "今天 HH:mm"
        } else if calendar.isDateInYesterday(date) {
            formatter.dateFormat = "昨天 HH:mm"
        } else {
            formatter.dateFormat = "MM月dd日 HH:mm"
        }
        
        return formatter.string(from: date)
    }
}

// MARK: - UITableViewDataSource
extension ConversationHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversationHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationHistoryCell", for: indexPath) as! ConversationHistoryCell
        let conversation = conversationHistory[indexPath.row]
        
        cell.configure(
            title: conversation.title,
            time: formatDate(conversation.createdAt),
            messageCount: conversation.messages.count
        )
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ConversationHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let conversation = conversationHistory[indexPath.row]
        showConversationDetail(conversation)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // MARK: - Conversation Detail
    private func showConversationDetail(_ conversation: ConversationSession) {
        let detailVC = ConversationDetailViewController(conversation: conversation)
        let navController = UINavigationController(rootViewController: detailVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
}