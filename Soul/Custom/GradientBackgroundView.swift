//
//  GradientBackgroundView.swift
//  Soul
//
//  Created by Ricard.li on 2025/7/18.
//


import UIKit

class GradientBackgroundView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }

    private func setupGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds

        gradientLayer.colors = [
            UIColor(red: 187/255.0, green: 189/255.0, blue: 239/255.0, alpha: 1.0).cgColor,
            UIColor(red: 236/255.0, green: 237/255.0, blue: 255/255.0, alpha: 1.0).cgColor
        ]

        // 设置渐变方向（从上到下）
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // 顶部中间
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)   // 底部中间

        layer.insertSublayer(gradientLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.sublayers?.first?.frame = bounds // 确保渐变层跟随布局更新
    }
}
