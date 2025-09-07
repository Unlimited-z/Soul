//
//  AppTheme.swift
//  Soul
//
//  Created by Soul Team on 2024/01/24.
//  Copyright © 2024 Soul. All rights reserved.
//

import UIKit

/// Soul 应用主题配置
/// 统一管理应用的颜色、字体、间距等设计规范
struct AppTheme {
    
    // MARK: - Colors 颜色系统
    struct Colors {
        // 主色调 - 紫色渐变
        static let primaryPurple = UIColor(red: 139/255, green: 92/255, blue: 246/255, alpha: 1.0) // #8B5CF6
        static let secondaryPurple = UIColor(red: 168/255, green: 85/255, blue: 247/255, alpha: 1.0) // #A855F7
        static let lightPurple = UIColor(red: 220/255, green: 222/255, blue: 255/255, alpha: 1.0) // rgba(220, 222, 255, 1)
        
        
        // 辅助颜色
        static let accent = UIColor(red: 236/255, green: 72/255, blue: 153/255, alpha: 1.0) // #EC4899
        static let warning = UIColor(red: 245/255, green: 158/255, blue: 11/255, alpha: 1.0) // #F59E0B
        static let success = UIColor(red: 34/255, green: 197/255, blue: 94/255, alpha: 1.0) // #22C55E
        static let error = UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0) // #EF4444
        
        // 文本颜色
        static let primaryText = UIColor.label
        static let secondaryText = UIColor.secondaryLabel
        static let tertiaryText = UIColor.tertiaryLabel
        static let placeholderText = UIColor.placeholderText
        
        // 背景颜色
        static let primaryBackground = UIColor.systemBackground
        static let secondaryBackground = UIColor.secondarySystemBackground
        static let tertiaryBackground = UIColor.tertiarySystemBackground
        
        // 分割线和边框
        static let separator = UIColor.separator
        static let border = UIColor.systemGray4
        
        // 状态颜色
        static let online = success
        static let offline = UIColor.systemGray
        static let busy = warning
    }
    
    // MARK: - Typography 字体系统
    struct Typography {
        // 标题字体
        static let largeTitle = UIFont.systemFont(ofSize: 34, weight: .bold)
        static let title1 = UIFont.systemFont(ofSize: 28, weight: .bold)
        static let title2 = UIFont.systemFont(ofSize: 22, weight: .bold)
        static let title3 = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        // 正文字体
        static let headline = UIFont.systemFont(ofSize: 17, weight: .semibold)
        static let body = UIFont.systemFont(ofSize: 17, weight: .regular)
        static let callout = UIFont.systemFont(ofSize: 16, weight: .regular)
        static let subheadline = UIFont.systemFont(ofSize: 15, weight: .regular)
        static let footnote = UIFont.systemFont(ofSize: 13, weight: .regular)
        static let caption1 = UIFont.systemFont(ofSize: 12, weight: .regular)
        static let caption2 = UIFont.systemFont(ofSize: 11, weight: .regular)
        
        // 按钮字体
        static let buttonLarge = UIFont.systemFont(ofSize: 18, weight: .semibold)
        static let buttonMedium = UIFont.systemFont(ofSize: 16, weight: .medium)
        static let buttonSmall = UIFont.systemFont(ofSize: 14, weight: .medium)
    }
    
    // MARK: - Spacing 间距系统
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        
        // 特定用途间距
        static let buttonHeight: CGFloat = 50
        static let textFieldHeight: CGFloat = 44
        static let cardPadding: CGFloat = 16
        static let sectionSpacing: CGFloat = 24
    }
    
    // MARK: - Corner Radius 圆角系统
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
        
        // 特定组件圆角
        static let button: CGFloat = 12
        static let textField: CGFloat = 10
        static let card: CGFloat = 16
    }
    
    // MARK: - Shadow 阴影系统
    struct Shadow {
        static let small = ShadowStyle(offset: CGSize(width: 0, height: 1), radius: 2, opacity: 0.1)
        static let medium = ShadowStyle(offset: CGSize(width: 0, height: 2), radius: 4, opacity: 0.15)
        static let large = ShadowStyle(offset: CGSize(width: 0, height: 4), radius: 8, opacity: 0.2)
    }
    
    struct ShadowStyle {
        let offset: CGSize
        let radius: CGFloat
        let opacity: Float
        let color: UIColor
        
        init(offset: CGSize, radius: CGFloat, opacity: Float, color: UIColor = .black) {
            self.offset = offset
            self.radius = radius
            self.opacity = opacity
            self.color = color
        }
    }
}

// MARK: - UIView Extensions
extension UIView {
    
    /// 应用阴影样式
    func applyShadow(_ shadowStyle: AppTheme.ShadowStyle) {
        layer.shadowColor = shadowStyle.color.cgColor
        layer.shadowOffset = shadowStyle.offset
        layer.shadowRadius = shadowStyle.radius
        layer.shadowOpacity = shadowStyle.opacity
        layer.masksToBounds = false
    }
    
    /// 应用圆角
    func applyCornerRadius(_ radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
    
    /// 应用边框
    func applyBorder(width: CGFloat = 1, color: UIColor = AppTheme.Colors.border) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }
}

// MARK: - UIButton Extensions
extension UIButton {
    
    /// 应用主按钮样式（紫色渐变背景）
    func applyPrimaryButtonStyle() {
        titleLabel?.font = AppTheme.Typography.buttonLarge
        setTitleColor(.white, for: .normal)
        backgroundColor = AppTheme.Colors.primaryPurple
        applyCornerRadius(AppTheme.CornerRadius.button)
        applyShadow(AppTheme.Shadow.medium)
    }
    
    /// 应用次要按钮样式（透明背景，紫色边框）
    func applySecondaryButtonStyle() {
        titleLabel?.font = AppTheme.Typography.buttonLarge
        setTitleColor(AppTheme.Colors.primaryPurple, for: .normal)
        backgroundColor = .clear
        applyCornerRadius(AppTheme.CornerRadius.button)
        applyBorder(width: 2, color: AppTheme.Colors.primaryPurple)
    }
    
    /// 应用文本按钮样式（无背景，紫色文字）
    func applyTextButtonStyle() {
        titleLabel?.font = AppTheme.Typography.buttonMedium
        setTitleColor(AppTheme.Colors.primaryPurple, for: .normal)
        backgroundColor = .clear
    }
    
    /// 应用渐变背景
    func applyGradientBackground() {
        // 移除现有的渐变层
        layer.sublayers?.removeAll { $0 is CAGradientLayer }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            AppTheme.Colors.primaryPurple.cgColor,
            AppTheme.Colors.secondaryPurple.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = AppTheme.CornerRadius.button
        gradientLayer.frame = bounds
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    /// 应用禁用状态样式
    func applyDisabledStyle() {
        backgroundColor = AppTheme.Colors.border
        setTitleColor(AppTheme.Colors.tertiaryText, for: .normal)
        isEnabled = false
    }
    
    /// 恢复启用状态样式
    func applyEnabledStyle() {
        applyPrimaryButtonStyle()
        isEnabled = true
    }
}

// MARK: - UITextField Extensions
extension UITextField {
    
    /// 应用主题文本框样式
    func applyThemeStyle() {
        font = AppTheme.Typography.body
        textColor = AppTheme.Colors.primaryText
        backgroundColor = AppTheme.Colors.secondaryBackground
        applyCornerRadius(AppTheme.CornerRadius.textField)
        applyBorder(width: 1, color: AppTheme.Colors.border)
        
        // 设置内边距
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: AppTheme.Spacing.md, height: frame.height))
        leftViewMode = .always
        rightView = UIView(frame: CGRect(x: 0, y: 0, width: AppTheme.Spacing.md, height: frame.height))
        rightViewMode = .always
        
        // 占位符颜色
        attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [NSAttributedString.Key.foregroundColor: AppTheme.Colors.placeholderText]
        )
    }
    
    /// 应用焦点状态样式
    func applyFocusedStyle() {
        applyBorder(width: 2, color: AppTheme.Colors.primaryPurple)
    }
    
    /// 应用错误状态样式
    func applyErrorStyle() {
        applyBorder(width: 2, color: AppTheme.Colors.error)
    }
    
    /// 恢复正常状态样式
    func applyNormalStyle() {
        applyBorder(width: 1, color: AppTheme.Colors.border)
    }
}

// MARK: - UILabel Extensions
extension UILabel {
    
    /// 应用主标题样式
    func applyPrimaryTitleStyle() {
        font = AppTheme.Typography.title1
        textColor = AppTheme.Colors.primaryText
    }
    
    /// 应用副标题样式
    func applySubtitleStyle() {
        font = AppTheme.Typography.callout
        textColor = AppTheme.Colors.secondaryText
    }
    
    /// 应用正文样式
    func applyBodyStyle() {
        font = AppTheme.Typography.body
        textColor = AppTheme.Colors.primaryText
    }
    
    /// 应用说明文字样式
    func applyCaptionStyle() {
        font = AppTheme.Typography.caption1
        textColor = AppTheme.Colors.secondaryText
    }
}
