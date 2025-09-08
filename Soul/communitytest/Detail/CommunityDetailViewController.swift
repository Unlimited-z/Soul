//
//  CommunityTestViewController.swift
//  Soul
//
//  Created by Assistant on 2024/01/01.
//

import UIKit
import SnapKit

class CommunityDetailViewController: BaseViewController, UITextFieldDelegate {
    
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
    private let messageboardSectionView = UIView()
    private let messageboardTitleLabel = UILabel()
    private let messagesCollectionView: UICollectionView
    private let messageInputView = UIView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    
    // MARK: - Initialization
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        messagesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        messagesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(coder: coder)
    }
    
    // MARK: - Data
    private let dataManager = CommunityTestDataManager.shared
    private var messages: [Message] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
//        setupUI()
        setupConstraints()
        loadMessages()
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
        loadMessages()
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
        messageboardSectionView.backgroundColor = .clear
        
        messageboardTitleLabel.text = "📝 我的留言板"
        messageboardTitleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        
        messagesCollectionView.delegate = self
        messagesCollectionView.dataSource = self
        messagesCollectionView.register(MessageCollectionCell.self, forCellWithReuseIdentifier: "MessageCollectionCell")
        messagesCollectionView.backgroundColor = .clear
        messagesCollectionView.isScrollEnabled = false
        
        // 输入区域
        messageInputView.backgroundColor = .systemGray6
        messageInputView.layer.cornerRadius = 12
        messageInputView.isUserInteractionEnabled = true
        
        messageTextField.placeholder = "在留言板上留言..."
        messageTextField.borderStyle = .none
        messageTextField.backgroundColor = .white
        messageTextField.layer.cornerRadius = 8
        messageTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        messageTextField.leftViewMode = .always
        messageTextField.isUserInteractionEnabled = true
        messageTextField.isEnabled = true
        messageTextField.returnKeyType = .send
        messageTextField.delegate = self
        
        // 确保文本框可以成为第一响应者
//        messageTextField.canResignFirstResponder = true
        
        sendButton.setTitle("发送", for: .normal)
        sendButton.backgroundColor = .systemBlue
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.layer.cornerRadius = 8
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        
        // UITextField 本身应该可以响应点击
        
        // 添加所有子视图
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 添加好友个人资料栏
        contentView.addSubview(userProfileView)
        
        // 添加主图片
        contentView.addSubview(mainImageView)
        
        // 添加留言板
        contentView.addSubview(messageboardSectionView)
        messageboardSectionView.addSubview(messageboardTitleLabel)
        messageboardSectionView.addSubview(messagesCollectionView)
        messageboardSectionView.addSubview(messageInputView)
        messageInputView.addSubview(messageTextField)
        messageInputView.addSubview(sendButton)
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
        
        messageboardSectionView.snp.makeConstraints { make in
            make.top.equalTo(mainImageView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
            make.height.greaterThanOrEqualTo(400)
        }
        
        messageboardTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        messagesCollectionView.snp.makeConstraints { make in
            make.top.equalTo(messageboardTitleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(200) // 设置初始高度
        }
        
        messageInputView.snp.makeConstraints { make in
            make.top.equalTo(messagesCollectionView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(56)
        }
        
        messageTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(sendButton.snp.leading).offset(-12)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
        }
        
        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(70)
            make.height.equalTo(40)
        }
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
    
    // MARK: - Data Methods
    private func loadMessages() {
        messages = dataManager.getAllMessages()
        messagesCollectionView.reloadData()
        updateCollectionViewHeight()
    }
    
    private func updateCollectionViewHeight() {
        DispatchQueue.main.async {
            self.messagesCollectionView.layoutIfNeeded()
            let contentHeight = self.messagesCollectionView.contentSize.height
            self.messagesCollectionView.snp.updateConstraints { make in
                make.height.equalTo(max(contentHeight, 200))
            }
        }
    }
    
    // MARK: - Actions
    

    
    @objc private func sendButtonTapped() {
        guard let text = messageTextField.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        // 创建新消息
        let newMessage = Message(
            id: UUID().uuidString,
            senderId: dataManager.currentUser.id,
            content: text,
            timestamp: Date()
        )
        
        // 添加消息到留言板
        dataManager.addMessage(newMessage)
        
        // 重新加载数据
        loadMessages()
        
        // 清空输入框
        messageTextField.text = ""
        
        // 滚动到底部
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let lastItem = self.messages.count - 1
            if lastItem >= 0 {
                let indexPath = IndexPath(item: lastItem, section: 0)
                self.messagesCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    

    
    // MARK: - Keyboard Handling
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        let keyboardHeight = keyboardFrame.height
        
        // 计算文本框在屏幕中的位置
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

// MARK: - UITextFieldDelegate
extension CommunityDetailViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == messageTextField {
            sendButtonTapped()
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("文本框开始编辑")
        // 确保文本框可见
        DispatchQueue.main.async {
            let textFieldFrame = textField.convert(textField.bounds, to: self.scrollView)
            self.scrollView.scrollRectToVisible(textFieldFrame, animated: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("文本框结束编辑")
    }
}

// MARK: - CollectionView DataSource & Delegate
extension CommunityDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageCollectionCell", for: indexPath) as! MessageCollectionCell
        let message = messages[indexPath.item]
        cell.configure(with: message, currentUserId: dataManager.currentUser.id)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 8 * 3 // 左右边距 + 中间间距
        let availableWidth = collectionView.frame.width - padding
        let cellWidth = availableWidth / 2 // 一行两个cell
        return CGSize(width: cellWidth, height: cellWidth) // 正方形
    }
}

// MARK: - MessageCollectionCell
class MessageCollectionCell: UICollectionViewCell {
    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        bubbleView.backgroundColor = .systemBlue
        bubbleView.layer.cornerRadius = 12
        
        messageLabel.font = .systemFont(ofSize: 14, weight: .medium)
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        timeLabel.font = .systemFont(ofSize: 10)
        timeLabel.textColor = .systemGray
        timeLabel.textAlignment = .center
        
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        contentView.addSubview(timeLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        bubbleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.trailing.equalToSuperview().inset(4)
            make.bottom.equalTo(timeLabel.snp.top).offset(-4)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.height.equalTo(12)
        }
    }
    
    func configure(with message: Message, currentUserId: String) {
        messageLabel.text = message.content
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        timeLabel.text = formatter.string(from: message.timestamp)
        
        // 所有消息都使用相同的样式，因为只显示用户自己的留言
        bubbleView.backgroundColor = .systemBlue
        messageLabel.textColor = .white
    }
}

// MARK: - Extension for CommunityTestDataManager
extension CommunityTestDataManager {
    fileprivate var messages: [Message] {
        get { getAllMessages() }
        set { /* 这里可以实现设置逻辑，目前为演示版本 */ }
    }
}
