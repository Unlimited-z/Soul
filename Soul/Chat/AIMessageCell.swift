//
//  AIMessageCell.swift
//  Soul
//
//  Created by Ricard.li on 2025/7/16.
//

import UIKit
import SnapKit

class AIMessageCell: UITableViewCell {
    
    // MARK: - UI Components
    private lazy var avatarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.6, green: 0.616, blue: 0.949, alpha: 1.0)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var avatarLabel: UILabel = {
        let label = UILabel()
        label.text = "AI"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.label
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private lazy var timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.systemGray
        label.textAlignment = .left
        return label
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.text = nil
        timestampLabel.text = nil
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        contentView.addSubview(avatarView)
        avatarView.addSubview(avatarLabel)
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        contentView.addSubview(timestampLabel)
    }
    
    private func setupConstraints() {
        // AI 头像
        avatarView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(16)
            make.width.height.equalTo(32)
        }
        
        avatarLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // 气泡视图 - 左对齐
        bubbleView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.bottom.equalTo(timestampLabel.snp.top).offset(-4)
            make.leading.equalTo(avatarView.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualToSuperview().inset(60)
            make.width.lessThanOrEqualTo(250)
        }
        
        // 消息文本
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        // 时间戳 - 左对齐
        timestampLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(8)
            make.leading.equalTo(bubbleView.snp.leading)
            make.height.equalTo(16)
        }
    }
    
    // MARK: - Configuration
    func configure(with message: ChatMessage) {
        messageLabel.text = message.content
        
        // 格式化时间戳
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        timestampLabel.text = formatter.string(from: message.timestamp)
    }
} 
