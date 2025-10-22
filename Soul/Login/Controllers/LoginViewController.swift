//
//  LoginViewController.swift
//  Soul
//
//  Created by Assistant on 2025-01-25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

// MARK: - Notification Names
extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
    static let userDidLogout = Notification.Name("userDidLogout")
}

class LoginViewController: BaseViewController {
    
    // MARK: - Properties
    private let viewModel: LoginViewModelProtocol
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
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "heart.circle.fill")
        imageView.tintColor = UIColor.systemPurple
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Soul"
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textColor = UIColor.label 
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "连接心灵，分享生活"
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
        textField.placeholder = "密码"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor.systemBackground
        textField.textColor = UIColor.label
        return textField
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("登录", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        return button
    }()
    
    private lazy var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("忘记密码？", for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.backgroundColor = UIColor.clear
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
        button.addTarget(self, action: #selector(forgotPasswordButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("还没有账号？立即注册", for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.backgroundColor = UIColor.clear
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Initialization
    init(viewModel: LoginViewModelProtocol = LoginViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = LoginViewModel()
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupKeyboardHandling()
        setupTextFieldDelegates()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - UI Setup
    override func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(logoImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(usernameTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(loginButton)
        contentView.addSubview(forgotPasswordButton)
        contentView.addSubview(registerButton)
        contentView.addSubview(loadingIndicator)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        logoImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        usernameTextField.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(60)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(usernameTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }
        
        forgotPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(forgotPasswordButton.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(loginButton)
        }
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] notification in
                self?.handleKeyboardShow(notification)
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
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
    }
    
    private func setupBindings() {
        // 绑定输入
        usernameTextField.rx.text.orEmpty
            .bind(to: viewModel.username)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        
        // 绑定登录按钮点击
        loginButton.rx.tap
            .bind(to: viewModel.loginTrigger)
            .disposed(by: disposeBag)
        
        // 绑定输出
        viewModel.isLoading
            .drive(onNext: { [weak self] isLoading in
                self?.setLoading(isLoading)
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoginEnabled
            .drive(loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.isLoginEnabled
            .map { $0 ? 1.0 : 0.6 }
            .drive(loginButton.rx.alpha)
            .disposed(by: disposeBag)
        
        viewModel.loginResult
            .drive(onNext: { [weak self] result in
                self?.handleLoginResult(result)
            })
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .compactMap { $0 }
            .drive(onNext: { [weak self] errorMessage in
                self?.showAlert(title: "登录失败", message: errorMessage)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    @objc private func forgotPasswordButtonTapped() {
        // 暂时显示提示信息
        showAlert(title: "提示", message: "密码重置功能暂未实现，请联系客服")
    }
    
    @objc private func registerButtonTapped() {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Private Methods
    private func handleLoginResult(_ result: LoginResult) {
        switch result {
        case .success(let message):
            // 登录成功，发送通知
            NotificationCenter.default.post(name: .userDidLogin, object: nil)
            
            // 返回到主界面
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                // 这里应该设置主界面的根视图控制器
                // 暂时先dismiss当前界面
                dismiss(animated: true)
            }
            
            if let message = message {
                showAlert(title: "登录成功", message: message)
            }
        case .failure(let errorMessage):
            showAlert(title: "登录失败", message: errorMessage)
        }
    }
    
    private func setLoading(_ isLoading: Bool) {
        loginButton.setTitle(isLoading ? "" : "登录", for: .normal)
        
        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
        
        usernameTextField.isEnabled = !isLoading
        passwordTextField.isEnabled = !isLoading
        forgotPasswordButton.isEnabled = !isLoading
        registerButton.isEnabled = !isLoading
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
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
            // 触发登录
            viewModel.loginTrigger.accept(())
        }
        return true
    }
}
