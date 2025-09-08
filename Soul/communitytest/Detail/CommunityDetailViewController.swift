//
//  CommunityTestViewController.swift
//  Soul
//
//  Created by Assistant on 2024/01/01.
//

import UIKit
import SnapKit

class CommunityDetailViewController: BaseViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // 好友个人资料栏
    private let userProfileView = UserProfileView()
    
    // 图片区域 (400px高度)
    private let mainImageView = UIImageView()
    
    // MARK: - Properties
    var friendImageName: String?
    var friendName: String?
    var intimacyLevel: relationship?
    var mainImageName: String? // 主图片名称 (image1-image6)
    
    // 留言板区域
    private let messageBoardView = MessageBoardView()
    
    // MARK: - Initialization
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Data
    private let dataManager = CommunityTestDataManager.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupConstraints()
        setupMessageBoardDelegate()
        setupNotifications()
    }
    
    private func setupNavigationBar() {
        // 创建黑色箭头图标
        let backImage = UIImage(systemName: "arrow.left")
        let blackBackImage = backImage?.withTintColor(.black, renderingMode: .alwaysOriginal)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: blackBackImage,
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messageBoardView.loadMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Setup Methods
    override func setupUI() {
//        view.backgroundColor = .systemBackground
        super.setupUI()
        // 滚动视图
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isUserInteractionEnabled = true
        scrollView.contentInsetAdjustmentBehavior = .never
        contentView.isUserInteractionEnabled = true
        
        // 配置好友个人资料栏
        let intimacyText = getIntimacyText(from: intimacyLevel)
        userProfileView.configure(avatarImageName: friendImageName, userName: friendName, intimacyLevel: intimacyText)
        
        // 配置主图片 (400px高度)
        mainImageView.contentMode = .scaleAspectFill
        mainImageView.clipsToBounds = true
        mainImageView.layer.cornerRadius = 20
        if let imageName = mainImageName, let image = UIImage(named: imageName) {
            mainImageView.image = image
        } else {
            mainImageView.image = UIImage(systemName: "photo")
            mainImageView.tintColor = .systemGray3
        }
        
        // 留言板区域
        messageBoardView.backgroundColor = .clear
        
        // 添加所有子视图
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 添加好友个人资料栏
        contentView.addSubview(userProfileView)
        
        // 添加主图片
        contentView.addSubview(mainImageView)
        
        // 添加留言板
        contentView.addSubview(messageBoardView)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // 好友个人资料栏约束
        userProfileView.snp.makeConstraints { make in
            make.top.equalTo(44)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(120)
        }
        
        // 主图片约束 (400px高度)
        mainImageView.snp.makeConstraints { make in
            make.top.equalTo(userProfileView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(400)
        }
        
        messageBoardView.snp.makeConstraints { make in
            make.top.equalTo(mainImageView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
            make.height.greaterThanOrEqualTo(400)
        }
    }
    
    private func setupMessageBoardDelegate() {
        messageBoardView.delegate = self
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: - Actions
    // MARK: - Keyboard Handling
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        let keyboardHeight = keyboardFrame.height
        
        // 计算文本框在屏幕中的位置
        let messageTextField = messageBoardView.getMessageTextField()
        let textFieldFrame = messageTextField.convert(messageTextField.bounds, to: view)
        let textFieldBottom = textFieldFrame.maxY
        
        // 计算可用高度（屏幕高度减去键盘高度和安全区域）
        let safeAreaTop = view.safeAreaInsets.top
        let safeAreaBottom = view.safeAreaInsets.bottom
        let availableHeight = view.frame.height - keyboardHeight + safeAreaBottom
        
        // 如果文本框被键盘遮挡，则向上滚动
        if textFieldBottom > availableHeight {
            let scrollOffset = textFieldBottom - availableHeight + 40 // 额外40点间距确保完全可见
            
            UIView.animate(withDuration: duration) {
                self.scrollView.contentOffset = CGPoint(x: 0, y: scrollOffset)
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        UIView.animate(withDuration: duration) {
            self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Helper Methods
    private func getIntimacyText(from relationship: relationship?) -> String? {
        guard let relationship = relationship else { return nil }
        
        switch relationship {
        case .hot:
            return "至交好友"
        case .normal:
            return "普通好友"
        case .defaulted:
            return nil // 对于defaulted关系，不显示亲密度文本
        }
    }
}

// MARK: - MessageBoardViewDelegate
extension CommunityDetailViewController: MessageBoardViewDelegate {
    func messageBoardView(_ view: MessageBoardView, didSendMessage message: Message) {
        // 可以在这里处理消息发送后的逻辑，比如统计、通知等
        print("消息已发送: \(message.content)")
    }
    
    func messageBoardViewDidUpdateHeight(_ view: MessageBoardView) {
        // 留言板高度更新时的处理
        view.layoutIfNeeded()
    }
}
