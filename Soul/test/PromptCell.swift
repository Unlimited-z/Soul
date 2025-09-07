//
//  PromptCell.swift
//  Soul
//
//  Created by Ricard.li on 2025/7/16.
//

import UIKit
import SnapKit

class PromptCell: UITableViewCell {
    
    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.clear.cgColor
        return view
    }()
    
    private lazy var promptLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "circle")
        imageView.tintColor = UIColor.systemGray3
        imageView.contentMode = .scaleAspectFit
        return imageView
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
        promptLabel.text = nil
        setSelected(false)
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(promptLabel)
        containerView.addSubview(checkImageView)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
        
        checkImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(24)
        }
        
        promptLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalTo(checkImageView.snp.leading).offset(-12)
        }
    }
    
    // MARK: - Configuration
    func configure(with text: String, isSelected: Bool) {
        promptLabel.text = text
        setSelected(isSelected)
    }
    
    private func setSelected(_ selected: Bool) {
        if selected {
            containerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            containerView.layer.borderColor = UIColor.systemBlue.cgColor
            checkImageView.image = UIImage(systemName: "checkmark.circle.fill")
            checkImageView.tintColor = UIColor.systemBlue
        } else {
            containerView.backgroundColor = UIColor.systemGray6
            containerView.layer.borderColor = UIColor.clear.cgColor
            checkImageView.image = UIImage(systemName: "circle")
            checkImageView.tintColor = UIColor.systemGray3
        }
    }
} 