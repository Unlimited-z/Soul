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
    
    // 输入控件
    private let inputControlView = InputControlView()
    
    // 文本输入相关组件
    private lazy var inputContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 25
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.1
        view.isHidden = true // 初始隐藏
        return view
    }()
    
    private lazy var textInputView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.clear
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = UIColor.label
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        textView.returnKeyType = .send
        return textView
    }()
    
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
        setupUI()
        setupConstraints()
        setupMessageBoardDelegate()
        setupNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        
        // 配置 inputControlView
        inputControlView.onTextInputTapped = { [weak self] in
            self?.showTextInput()
        }
        inputControlView.onVoiceInputTapped = { [weak self] in
            print("语音输入功能暂未实现")
        }
        
        // 添加所有子视图
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 添加好友个人资料栏
        contentView.addSubview(userProfileView)
        
        // 添加主图片
        contentView.addSubview(mainImageView)
        
        // 添加留言板
        contentView.addSubview(messageBoardView)
        
        // 添加输入控件到contentView中
        contentView.addSubview(inputControlView)
        view.addSubview(inputContainer)
        
        // 配置文本输入容器
        inputContainer.addSubview(textInputView)
        
        // 添加点击空白区域收起键盘的手势
        let tapGestureToHideKeyboard = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardOnTap))
        tapGestureToHideKeyboard.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureToHideKeyboard)
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
            make.height.greaterThanOrEqualTo(400)
        }
        
        // InputControlView 约束 - 在留言板下方
        inputControlView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(messageBoardView.snp.bottom).offset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        // 文本输入容器约束 - 初始位置在屏幕底部
        inputContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.height.greaterThanOrEqualTo(50)
        }
        
        // 文本输入框约束
        textInputView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        // 调整输入容器位置
        inputContainer.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-keyboardHeight)
            make.height.greaterThanOrEqualTo(50)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        UIView.animate(withDuration: duration) {
            self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        }
    }
    
    

    
    // MARK: - Helper Methods
    
    // 显示文本输入
    private func showTextInput() {
        inputControlView.isHidden = true
        inputContainer.isHidden = false
        textInputView.becomeFirstResponder()
    }
    
    // 隐藏文本输入
    private func hideTextInput() {
        inputControlView.isHidden = false
        inputContainer.isHidden = true
        textInputView.resignFirstResponder()
        textInputView.text = ""
    }
    
    // 发送消息
    private func sendMessage() {
        guard let text = textInputView.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        // 创建新消息
        let newMessage = Message(
            id: UUID().uuidString,
            senderId: dataManager.currentUser.id,
            content: text,
            timestamp: Date()
        )
        
        // 保存消息到数据管理器
        dataManager.addMessage(newMessage)
        
        // 通过delegate通知消息发送
        messageBoardView.delegate?.messageBoardView(messageBoardView, didSendMessage: newMessage)
        
        // 重新加载留言板数据
        messageBoardView.loadMessages()
        
        // 清空输入框
        textInputView.text = ""
        
        // 隐藏输入界面
        hideTextInput()
    }
    
    // 点击空白区域隐藏键盘
    @objc private func hideKeyboardOnTap() {
        if !inputContainer.isHidden {
            hideTextInput()
        }
    }
    
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

// MARK: - UITextViewDelegate
extension CommunityDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            // 按下回车键发送消息
//            sendMessage()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // 动态调整输入框高度
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        let newHeight = max(50, min(120, size.height))
        
        inputContainer.snp.updateConstraints { make in
            make.height.greaterThanOrEqualTo(newHeight)
        }
        
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
}
