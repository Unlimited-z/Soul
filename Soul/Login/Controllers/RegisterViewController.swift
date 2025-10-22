//
//  RegisterViewController.swift
//  Soul
//
//  Created by Assistant on 2025-01-25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class RegisterViewController: BaseViewController {
    
    // MARK: - Properties
    private let viewModel: RegisterViewModelProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "创建账号"
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textColor = UIColor.label
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "加入 Soul，开始你的心灵之旅"
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.textColor = UIColor.secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private lazy var usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "用户名"
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor.systemBackground
        textField.textColor = UIColor.label
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "密码（至少6位）"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor.systemBackground
        textField.textColor = UIColor.label
        return textField
    }()
    
    private lazy var nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "昵称"
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor.systemBackground
        textField.textColor = UIColor.label
        return textField
    }()
    

    
    private lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("注册", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        return button
    }()
    

    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("已有账号？立即登录", for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.backgroundColor = UIColor.clear
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Initialization
    init(viewModel: RegisterViewModelProtocol = RegisterViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = RegisterViewModel()
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupKeyboardHandling()
        setupTextFieldDelegates()
        setupNavigationBar()
        setupBindings()
        
//        // 设置注册按钮渐变背景
//        DispatchQueue.main.async {
//            self.registerButton.applyGradientBackground()
//        }
    }
    
    // MARK: - UI Setup
    override func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(usernameTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(nicknameTextField)
        contentView.addSubview(registerButton)
        contentView.addSubview(loginButton)
        contentView.addSubview(loadingIndicator)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // 使用 UIScrollView 的 contentLayoutGuide / frameLayoutGuide，避免布局冲突导致崩溃
        contentView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide.snp.top)
            make.leading.equalTo(scrollView.contentLayoutGuide.snp.leading)
            make.trailing.equalTo(scrollView.contentLayoutGuide.snp.trailing)
            make.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        usernameTextField.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(usernameTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }
        
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }
        
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(registerButton.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            // 将内容视图的底部与最后一个元素关联，正确计算滚动内容高度
            make.bottom.equalTo(contentView.snp.bottom).offset(-40)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(registerButton)
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "注册"
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .systemPink
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] notification in
                self?.handleKeyboardShow(notification)
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { [weak self] notification in
                self?.handleKeyboardHide(notification)
            })
            .disposed(by: disposeBag)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupTextFieldDelegates() {
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        nicknameTextField.delegate = self
    }
    
    private func setupBindings() {
        // 输入绑定
        usernameTextField.rx.text.orEmpty
            .bind(to: viewModel.username)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        
        nicknameTextField.rx.text.orEmpty
            .bind(to: viewModel.nickname)
            .disposed(by: disposeBag)
        
        registerButton.rx.tap
            .bind(to: viewModel.registerTrigger)
            .disposed(by: disposeBag)
        
        loginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        // 输出绑定
        viewModel.isLoading
            .drive(onNext: { [weak self] isLoading in
                self?.setLoading(isLoading)
            })
            .disposed(by: disposeBag)
        
        viewModel.isRegisterEnabled
            .drive(registerButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.registerResult
            .drive(onNext: { [weak self] result in
                self?.handleRegisterResult(result)
            })
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .drive(onNext: { [weak self] error in
                if let error = error {
                    self?.showAlert(title: "注册失败", message: error)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    

    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Private Methods
    private func handleRegisterResult(_ result: RegisterResult) {
        switch result {
        case .success:
            // 发送注册成功通知
            NotificationCenter.default.post(name: .userDidLogin, object: nil)
            
            // 显示成功消息
            let alert = UIAlertController(title: "注册成功", message: "欢迎加入 Soul！", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
                // 返回到登录页面或主页面
                self.navigationController?.popViewController(animated: true)
            })
            present(alert, animated: true)
            
        case .failure(let error):
            showAlert(title: "注册失败", message: error)
        }
    }
    

    

    
    private func setLoading(_ isLoading: Bool) {
        registerButton.setTitle(isLoading ? "" : "注册", for: .normal)
        
        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
        
        usernameTextField.isEnabled = !isLoading
        passwordTextField.isEnabled = !isLoading
        nicknameTextField.isEnabled = !isLoading
//        termsCheckbox.isEnabled = !isLoading
        loginButton.isEnabled = !isLoading
    }
    

    

    
    private func handleKeyboardShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: duration) {
            self.scrollView.contentInset.bottom = keyboardHeight
            self.scrollView.scrollIndicatorInsets.bottom = keyboardHeight
        }
    }
    
    private func handleKeyboardHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        UIView.animate(withDuration: duration) {
            self.scrollView.contentInset.bottom = 0
            self.scrollView.scrollIndicatorInsets.bottom = 0
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            nicknameTextField.becomeFirstResponder()
        case nicknameTextField:
            textField.resignFirstResponder()
            viewModel.registerTrigger.accept(())
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}


