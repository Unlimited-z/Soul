//
//  ViewController.swift
//  Soul
//
//  Created by Ricard.li on 2025/7/16.
//

import UIKit
import SnapKit

class ViewController: BaseViewController {
    
    lazy var menuButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "menu_icon"), for: .normal)
        button.backgroundColor = UIColor(red: 0.855, green: 0.949, blue: 0.714, alpha: 1.0)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        return button
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SuezOne-Regular", size: 36)
        label.textColor = UIColor(red: 0.855, green: 0.949, blue: 0.714, alpha: 1.0)
        label.text = "SoulScapes"
        label.textAlignment = .center
        return label
    }()
    
    lazy var cloudButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cloud_icon"), for: .normal)
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: #selector(cloudButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var topContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var chatView: ChatView = {
        let chat = ChatView()
        return chat
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func setupUI() {
        super.setupUI()
        view.addSubview(topContainer)
        view.addSubview(chatView)
        
        
        // 再添加底部安全区背景色（在渐变背景之后添加，确保在上层）
        let safeAreaBottomView = UIView()
        safeAreaBottomView.backgroundColor = UIColor(red: 110/255.0, green: 60/255.0, blue: 241/255.0, alpha: 1.0)
        view.addSubview(safeAreaBottomView)
        safeAreaBottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        topContainer.addSubview(menuButton)
        topContainer.addSubview(titleLabel)
        topContainer.addSubview(cloudButton)
    }
    
    override func setupconstraint() {
        super.setupconstraint()
        topContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(53)
        }
        
        chatView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(topContainer.snp.bottom).offset(30)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
        }
        
        menuButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.height.equalTo(cloudButton)
            make.width.equalTo(menuButton.snp.height)
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(menuButton.snp.right).offset(10)
            make.right.equalTo(cloudButton.snp.left).offset(-10)
            make.centerY.equalToSuperview()
            
        }
        cloudButton.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Actions
    @objc private func menuButtonTapped() {
        let menuVC = MenuViewController()
        menuVC.modalPresentationStyle = .fullScreen
        present(menuVC, animated: true)
    }
    
    @objc private func cloudButtonTapped() {
        // 使用新的清除当前对话方法（会自动保存到历史）
        ChatDataManager.shared.clearCurrentConversation()
        
        // 清空聊天界面并显示提示
        chatView.clearConversation()
        showSaveSuccessAlert()
    }
    
    private func showSaveSuccessAlert() {
        let alert = UIAlertController(title: "保存成功", message: "当前对话已保存到历史记录，开始新的对话", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    

}

