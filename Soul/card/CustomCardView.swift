//
//  CustomCardView.swift
//  Soul
//
//  Created by Assistant on 2024.
//

import UIKit
import SnapKit

class CustomCardView: UIView {
    
    // MARK: - UI Components
    
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
        backgroundColor = AppTheme.Colors.lightPurple
        layer.cornerRadius = 12
        clipsToBounds = true
        
        // 添加阴影效果
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 4
        layer.masksToBounds = false
    }
    
    private func setupConstraints() {
        // 在这里添加子视图的约束
    }
    
    // MARK: - Public Methods
    
}