//
//  PromptView.swift
//  Soul
//
//  Created by Assistant on 2024.
//

import UIKit
import SnapKit

class PromptView: UIView {
    
    // MARK: - UI Components
    private let avatarImageView = UIImageView()
    private let speechBubbleView = UIView()
    private let textLabel = UILabel()
    private let triangleView = UIView()
    
    // MARK: - Initialization
    init(frame: CGRect = .zero, avatarImage: UIImage? = nil) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        
        // 设置自定义头像
        if let avatarImage = avatarImage {
            updateAvatar(image: avatarImage)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        backgroundColor = UIColor.clear
        
        // 配置头像
        avatarImageView.backgroundColor = UIColor.systemBlue
        avatarImageView.layer.cornerRadius = 25
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        
        // 设置默认头像图片（可以是系统图标或自定义图片）
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        avatarImageView.image = UIImage(systemName: "person.circle.fill", withConfiguration: config)
        avatarImageView.tintColor = UIColor.white
        
        // 配置对话框背景
        speechBubbleView.backgroundColor = UIColor.systemBackground
        speechBubbleView.layer.cornerRadius = 12
        speechBubbleView.layer.shadowColor = UIColor.black.cgColor
        speechBubbleView.layer.shadowOffset = CGSize(width: 0, height: 2)
        speechBubbleView.layer.shadowOpacity = 0.1
        speechBubbleView.layer.shadowRadius = 4
        
        // 配置文本标签
        textLabel.text = "今日提示词\n点击生成你的专属卡片"
        textLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        textLabel.textColor = UIColor.label
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .left
        
        // 配置三角形指示器
        triangleView.backgroundColor = UIColor.clear
        
        // 添加子视图
        addSubview(avatarImageView)
        addSubview(speechBubbleView)
        addSubview(triangleView)
        speechBubbleView.addSubview(textLabel)
    }
    
    private func setupConstraints() {
        // 头像约束
        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        // 对话框约束
        speechBubbleView.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(8)
            make.height.greaterThanOrEqualTo(60)
        }
        
        // 三角形指示器约束
        triangleView.snp.makeConstraints { make in
            make.trailing.equalTo(speechBubbleView.snp.leading)
            make.centerY.equalTo(speechBubbleView)
            make.width.height.equalTo(12)
        }
        
        // 文本标签约束
        textLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawTriangle()
    }
    
    // MARK: - Drawing Methods
    private func drawTriangle() {
        triangleView.layer.sublayers?.removeAll()
        
        let triangleLayer = CAShapeLayer()
        let trianglePath = UIBezierPath()
        
        let triangleHeight: CGFloat = 12
        let triangleWidth: CGFloat = 12
        
        // 绘制指向左侧的三角形
        trianglePath.move(to: CGPoint(x: triangleWidth, y: 0))
        trianglePath.addLine(to: CGPoint(x: 0, y: triangleHeight / 2))
        trianglePath.addLine(to: CGPoint(x: triangleWidth, y: triangleHeight))
        trianglePath.close()
        
        triangleLayer.path = trianglePath.cgPath
        triangleLayer.fillColor = UIColor.systemBackground.cgColor
        
        triangleView.layer.addSublayer(triangleLayer)
    }
    
    // MARK: - Public Methods
    func updateContent(text: String) {
        textLabel.text = text
    }
    
    func updateAvatar(image: UIImage?) {
        avatarImageView.image = image
    }
    
    func updateAvatarColor(_ color: UIColor) {
        avatarImageView.backgroundColor = color
    }
}