//
//  UserProfileView.swift
//  Soul
//
//  Created by Assistant on 2024/01/01.
//

import UIKit
import SnapKit

class UserProfileView: UIView {
    
    // MARK: - UI Components
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let intimacyLabel = UILabel()
    private let personalityLabel = UILabel()
    
    // MARK: - Properties
    var avatarImageName: String? {
        didSet {
            updateAvatarImage()
        }
    }
    
    var userName: String? {
        didSet {
            updateUserName()
        }
    }
    
    var intimacyLevel: String? {
        didSet {
            updateIntimacyLevel()
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        backgroundColor = .clear
        
        // 配置头像
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 45
        
        // 配置用户名
        nameLabel.font = .systemFont(ofSize: 24, weight: .medium)
        nameLabel.textColor = AppTheme.Colors.secondaryPurple
        
        // 配置亲密度
//        intimacyLabel.font = .systemFont(ofSize: 14, weight: .regular)
//        intimacyLabel.textColor = .systemGray
        
        intimacyLabel.font = .systemFont(ofSize: 14)
        intimacyLabel.textAlignment = .center
        intimacyLabel.textColor = .white
        intimacyLabel.backgroundColor = AppTheme.Colors.secondaryPurple
        intimacyLabel.layer.cornerRadius = 12
        intimacyLabel.clipsToBounds = true
        
        
        // 配置性格介绍
        personalityLabel.font = .systemFont(ofSize: 36, weight: .medium)
        personalityLabel.textColor = AppTheme.Colors.secondaryYellow
        personalityLabel.text = "ENTP"
        
        // 添加子视图
        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(intimacyLabel)
        addSubview(personalityLabel)
    }
    
    private func setupConstraints() {
        // 头像在右边
        avatarImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(90)
        }
        
        // 性格介绍在最左边
        personalityLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(40)
            make.centerY.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
//            make.leading.equalTo(personalityLabel.snp.trailing).offset(16)
            make.top.equalTo(avatarImageView.snp.top).offset(20)
            make.trailing.equalTo(avatarImageView.snp.leading).offset(-16)

        }
        
        // 亲密度在用户名下面
        intimacyLabel.snp.makeConstraints { make in
//            make.leading.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.trailing.equalTo(avatarImageView.snp.leading).offset(-16)
            make.height.equalTo(22)
            make.width.equalTo(77)
//            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    // MARK: - Public Methods
    func configure(avatarImageName: String?, userName: String?, intimacyLevel: String? = nil) {
        self.avatarImageName = avatarImageName
        self.userName = userName
        self.intimacyLevel = intimacyLevel
        
        if intimacyLevel != nil {
            intimacyLabel.isHidden = false
        } else {
            intimacyLabel.isHidden = true
        }
    }
    
    // MARK: - Private Methods
    private func updateAvatarImage() {
        if let imageName = avatarImageName, let image = UIImage(named: imageName) {
            avatarImageView.image = image
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
            avatarImageView.tintColor = .systemBlue
        }
    }
    
    private func updateUserName() {
        nameLabel.text = userName ?? "好友"
    }
    
    private func updateIntimacyLevel() {
        intimacyLabel.text = intimacyLevel ?? "亲密度: 未知"
    }
}
