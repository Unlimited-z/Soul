//
//  InputControlView.swift
//  Soul
//
//  Created by AI Assistant
//

import UIKit
import SnapKit

class InputControlView: UIView {
    
    // MARK: - UI Components
    private let voiceInputButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "talk_icon"), for: .normal)
        button.tintColor = .gray
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.1
        return button
    }()
    
    private let textInputButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "message_icon"), for: .normal)
        button.tintColor = UIColor.systemGray
        button.backgroundColor = AppTheme.Colors.lightPurple
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 4
        return button
    }()
    
    // MARK: - Callbacks
    var onVoiceInputTapped: (() -> Void)?
    var onTextInputTapped: (() -> Void)?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupActions()
        
        // 设置胶囊状背景
        self.backgroundColor = AppTheme.Colors.secondaryPurple
        self.layer.cornerRadius = 30 // 高度78的一半
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 8
        self.layer.shadowOpacity = 0.1
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        addSubview(voiceInputButton)
        addSubview(textInputButton)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 150, height: 60)
    }
    
    private func setupConstraints() {
        // 设置自身尺寸约束
        self.snp.makeConstraints { make in
            make.width.equalTo(150)
            make.height.equalTo(60)
        }
        
        voiceInputButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        textInputButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
    }
    
    // MARK: - Actions
    private func setupActions() {
        voiceInputButton.addTarget(self, action: #selector(voiceInputButtonTapped), for: .touchUpInside)
        textInputButton.addTarget(self, action: #selector(textInputButtonTapped), for: .touchUpInside)
    }
    
    @objc private func voiceInputButtonTapped() {
        onVoiceInputTapped?()
    }
    
    @objc private func textInputButtonTapped() {
        onTextInputTapped?()
    }
    
    // MARK: - Public Methods
    func setVoiceButtonEnabled(_ enabled: Bool) {
        voiceInputButton.isEnabled = enabled
        voiceInputButton.alpha = enabled ? 1.0 : 0.6
    }
    
    func setTextButtonEnabled(_ enabled: Bool) {
        textInputButton.isEnabled = enabled
        textInputButton.alpha = enabled ? 1.0 : 0.6
    }
    
    func updateButtonStyles(voiceColor: UIColor? = nil, textColor: UIColor? = nil) {
        if let voiceColor = voiceColor {
            voiceInputButton.backgroundColor = voiceColor
        }
        if let textColor = textColor {
            textInputButton.backgroundColor = textColor
        }
    }
}
