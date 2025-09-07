//
//  MenuViewController.swift
//  Soul
//
//  Created by Ricard.li on 2025/7/16.
//

import UIKit
import SnapKit

class MenuViewController: BaseViewController {
    
    // MARK: - Data
    private var menuItems: [MenuItemModel] {
        var items = [
            MenuItemModel(title: "社区", icon: "person.3.fill", type: .community),
            MenuItemModel(title: "个人中心", icon: "person.circle.fill", type: .profile),
            MenuItemModel(title: "聊天记录", icon: "message.fill", type: .chatHistory),
            MenuItemModel(title: "清除当前聊天记录", icon: "trash.fill", type: .clearChat),
            MenuItemModel(title: "设置", icon: "gearshape.fill", type: .settings)
        ]
        
        // 如果用户已登录，添加退出登录按钮
        if AuthService.shared.isAuthenticated {
            items.append(MenuItemModel(title: "退出登录", icon: "rectangle.portrait.and.arrow.right", type: .logout))
        }
        
        return items
    }
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = UIColor.clear
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
        table.register(MenuTableViewCell.self, forCellReuseIdentifier: "MenuTableViewCell")
        table.layer.cornerRadius = 20
        table.clipsToBounds = true
        return table
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "菜单"
        label.font = UIFont(name: "SuezOne-Regular", size: 28)
        label.textColor = UIColor(red: 0.855, green: 0.949, blue: 0.714, alpha: 1.0)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = UIColor(red: 0.855, green: 0.949, blue: 0.714, alpha: 1.0)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 刷新菜单项以反映最新的登录状态
        tableView.reloadData()
    }
    
    override func setupUI() {
        // 只添加渐变背景，不设置底部安全区颜色
        let bg = GradientBackgroundView()
        view.addSubview(bg)
        bg.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(tableView)
    }
    
    override func setupconstraint() {
        super.setupconstraint()
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalToSuperview().inset(20)
            make.width.height.equalTo(30)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    private func handleMenuItemTap(_ type: MenuItemType) {
        switch type {
        case .community:
            // 显示社区主页面
            let communityVC = CommunityMainViewController()
            let navController = UINavigationController(rootViewController: communityVC)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        case .profile:
            showComingSoonAlert(for: "个人中心")
        case .chatHistory:
            let conversationHistoryVC = ConversationHistoryViewController()
            let navController = UINavigationController(rootViewController: conversationHistoryVC)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        case .clearChat:
            showClearChatConfirmation()
        case .settings:
            showSettingsOptions()
        case .logout:
            showLogoutConfirmation()
        }
    }
    
    private func showSettingsOptions() {
        let alert = UIAlertController(
            title: "设置",
            message: "暂无其他设置选项",
            preferredStyle: .actionSheet
        )
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alert.addAction(cancelAction)
        
        // 适配iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func showClearChatConfirmation() {
        let alert = UIAlertController(
            title: "清除聊天记录",
            message: "确定要删除所有聊天记录吗？此操作无法撤销。",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
            self?.clearChatHistory()
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func clearChatHistory() {
        // 清除聊天数据
        ChatDataManager.shared.clearAllData()
        
        // 显示成功提示
        let successAlert = UIAlertController(
            title: "删除成功",
            message: "聊天记录已清除，AI 将重新开始对话。",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "好的", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        successAlert.addAction(okAction)
        
        present(successAlert, animated: true)
    }
    
    private func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "退出登录",
            message: "确定要退出登录吗？",
            preferredStyle: .alert
        )
        
        let logoutAction = UIAlertAction(title: "退出", style: .destructive) { [weak self] _ in
            self?.performLogout()
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        do {
            try AuthService.shared.signOut()
            
            // 退出登录成功，刷新菜单项
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
                self?.dismiss(animated: true)
            }
        } catch {
            // 显示错误提示
            let errorAlert = UIAlertController(
                title: "退出失败",
                message: "退出登录时发生错误，请重试。",
                preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(title: "好的", style: .default)
            errorAlert.addAction(okAction)
            
            present(errorAlert, animated: true)
        }
    }
    
    private func showComingSoonAlert(for feature: String) {
        let alert = UIAlertController(
            title: "敬请期待",
            message: "\(feature)功能正在开发中，敬请期待！",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "好的", style: .default)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as! MenuTableViewCell
        cell.configure(with: menuItems[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let menuItem = menuItems[indexPath.row]
        handleMenuItemTap(menuItem.type)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

// MARK: - Menu Models
struct MenuItemModel {
    let title: String
    let icon: String
    let type: MenuItemType
}

enum MenuItemType {
    case community
    case profile
    case chatHistory
    case clearChat
    case settings
    case logout
}
