//
//  LoadingMessageCell.swift
//  Soul
//
//  Created by Ricard.li on 2025/7/16.
//

import UIKit
import SnapKit

class LoadingMessageCell: UITableViewCell {
    
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
    
    private lazy var loadingStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }()
    
    private lazy var dot1: UIView = {
        return createDot()
    }()
    
    private lazy var dot2: UIView = {
        return createDot()
    }()
    
    private lazy var dot3: UIView = {
        return createDot()
    }()
    
    private lazy var thinkingLabel: UILabel = {
        let label = UILabel()
        label.text = "正在思考中"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.label
        return label
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
        startAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        startAnimation()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        contentView.addSubview(avatarView)
        avatarView.addSubview(avatarLabel)
        contentView.addSubview(bubbleView)
        
        loadingStackView.addArrangedSubview(thinkingLabel)
        loadingStackView.addArrangedSubview(dot1)
        loadingStackView.addArrangedSubview(dot2)
        loadingStackView.addArrangedSubview(dot3)
        
        bubbleView.addSubview(loadingStackView)
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
        
        // 气泡视图
        bubbleView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
            make.leading.equalTo(avatarView.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualToSuperview().inset(60)
        }
        
        // 加载内容
        loadingStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        // 点的大小
        [dot1, dot2, dot3].forEach { dot in
            dot.snp.makeConstraints { make in
                make.width.height.equalTo(6)
            }
        }
    }
    
    private func createDot() -> UIView {
        let dot = UIView()
        dot.backgroundColor = UIColor.systemGray
        dot.layer.cornerRadius = 3
        return dot
    }
    
    private func startAnimation() {
        let dots = [dot1, dot2, dot3]
        
        for (index, dot) in dots.enumerated() {
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 0.3
            animation.toValue = 1.0
            animation.duration = 0.6
            animation.repeatCount = .infinity
            animation.autoreverses = true
            animation.beginTime = CACurrentMediaTime() + Double(index) * 0.2
            
            dot.layer.add(animation, forKey: "loading")
        }
    }
} 
