//
//  ConversationHistoryCell.swift
//  Soul
//
//  Created by Ricard.li on 2025/1/13.
//

import UIKit
import SnapKit

class ConversationHistoryCell: UITableViewCell {
    
    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1)
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 0.855, green: 0.949, blue: 0.714, alpha: 0.3).cgColor
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "message.circle.fill")
        imageView.tintColor = UIColor(red: 0.855, green: 0.949, blue: 0.714, alpha: 1.0)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(red: 0.855, green: 0.949, blue: 0.714, alpha: 1.0)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(red: 0.855, green: 0.949, blue: 0.714, alpha: 0.7)
        return label
    }()
    
    private lazy var messageCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(red: 0.855, green: 0.949, blue: 0.714, alpha: 0.7)
        return label
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = UIColor(red: 0.855, green: 0.949, blue: 0.714, alpha: 0.5)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(messageCountLabel)
        containerView.addSubview(arrowImageView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(5)
            make.left.right.equalToSuperview().inset(10)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(12)
            make.top.equalToSuperview().offset(12)
            make.right.equalTo(arrowImageView.snp.left).offset(-10)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        messageCountLabel.snp.makeConstraints { make in
            make.right.equalTo(arrowImageView.snp.left).offset(-10)
            make.centerY.equalTo(timeLabel)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
    }
    
    // MARK: - Configuration
    func configure(title: String, time: String, messageCount: Int) {
        titleLabel.text = title
        timeLabel.text = time
        messageCountLabel.text = "\(messageCount)条消息"
    }
    
    // MARK: - Cell Lifecycle
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.1) {
            self.containerView.alpha = highlighted ? 0.7 : 1.0
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }
}