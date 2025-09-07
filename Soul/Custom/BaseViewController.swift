//
//  BaseViewController.swift
//  Soul
//
//  Created by Ricard.li on 2025/7/18.
//

import UIKit
import SnapKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .red
        setupUI()
        setupconstraint()
    }
    
    func setupUI() {
        // 先添加渐变背景，只到安全区底部
        let bg = GradientBackgroundView()
        view.addSubview(bg)
        bg.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
    }
    
    func setupconstraint() {
        
    }
    
}
