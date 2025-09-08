//
//  RegisterViewController.swift
//  Soul
//
//  Created by Assistant on 2025-01-25.
//

import UIKit
import Combine
import SnapKit

class RegisterViewController: BaseViewController {
    
    // MARK: - Properties
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
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
    
    private lazy var displayNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "昵称（可选）"
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .no
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor.systemBackground
        textField.textColor = UIColor.label
        return textField
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "邮箱地址"
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
//        textField.applyThemeStyle()
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "密码（至少6位）"
        textField.isSecureTextEntry = true
//        textField.applyThemeStyle()
        return textField
    }()
    
    private lazy var confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "确认密码"
        textField.isSecureTextEntry = true
//        textField.applyThemeStyle()
        return textField
    }()
    
    private lazy var passwordStrengthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = UIColor.secondaryLabel
        label.text = "密码强度："
        return label
    }()
    
    private lazy var passwordStrengthIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 2
        return view
    }()
    
    private lazy var termsCheckbox: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        button.tintColor = UIColor.systemPurple
        button.addTarget(self, action: #selector(termsCheckboxTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var termsLabel: UILabel = {
        let label = UILabel()
        label.text = "我同意《用户协议》和《隐私政策》"
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = UIColor.secondaryLabel
        label.numberOfLines = 0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(termsLabelTapped))
        label.addGestureRecognizer(tapGesture)
        label.isUserInteractionEnabled = true
        
        return label
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("注册", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("已有账号？立即登录", for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.backgroundColor = UIColor.clear
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Initialization
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.authService = AuthService.shared
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
        contentView.addSubview(displayNameTextField)
        contentView.addSubview(emailTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(confirmPasswordTextField)
        contentView.addSubview(passwordStrengthLabel)
        contentView.addSubview(passwordStrengthIndicator)
        contentView.addSubview(termsCheckbox)
        contentView.addSubview(termsLabel)
        contentView.addSubview(registerButton)
        contentView.addSubview(loginButton)
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
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        displayNameTextField.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(displayNameTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }
        
        passwordStrengthLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(32)
        }
        
        passwordStrengthIndicator.snp.makeConstraints { make in
            make.centerY.equalTo(passwordStrengthLabel)
            make.leading.equalTo(passwordStrengthLabel.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(32)
            make.height.equalTo(4)
        }
        
        confirmPasswordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordStrengthLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }
        
        termsCheckbox.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordTextField.snp.bottom).offset(24)
            make.leading.equalToSuperview().inset(32)
            make.width.height.equalTo(24)
        }
        
        termsLabel.snp.makeConstraints { make in
            make.centerY.equalTo(termsCheckbox)
            make.leading.equalTo(termsCheckbox.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(32)
        }
        
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(termsLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(50)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(registerButton.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
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
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] notification in
                self?.handleKeyboardShow(notification)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] notification in
                self?.handleKeyboardHide(notification)
            }
            .store(in: &cancellables)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupTextFieldDelegates() {
        displayNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        passwordTextField.addTarget(self, action: #selector(passwordDidChange), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    // MARK: - Actions
    @objc private func registerButtonTapped() {
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text else {
            showAlert(title: "错误", message: "请填写完整信息")
            return
        }
        
        guard termsCheckbox.isSelected else {
            showAlert(title: "提示", message: "请同意用户协议和隐私政策")
            return
        }
        
        let displayName = displayNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let credentials = RegisterCredentials(
            email: email,
            password: password,
            confirmPassword: confirmPassword,
            displayName: displayName?.isEmpty == true ? nil : displayName
        )
        
        performRegistration(with: credentials)
    }
    
    @objc private func loginButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func termsCheckboxTapped() {
        termsCheckbox.isSelected.toggle()
        updateRegisterButtonState()
    }
    
    @objc private func termsLabelTapped() {
        // 显示用户协议和隐私政策
        showTermsAndPrivacy()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func passwordDidChange() {
        updatePasswordStrength()
        updateRegisterButtonState()
    }
    
    @objc private func textFieldDidChange() {
        updateRegisterButtonState()
    }
    
    // MARK: - Private Methods
    private func performRegistration(with credentials: RegisterCredentials) {
        setLoading(true)
        
        Task {
            do {
                let result = try await authService.signUp(with: credentials)
                await MainActor.run {
                    setLoading(false)
                    handleRegistrationSuccess(result)
                }
            } catch {
                await MainActor.run {
                    setLoading(false)
                    handleRegistrationError(error)
                }
            }
        }
    }
    
    private func handleRegistrationSuccess(_ result: AuthResult) {
        // 注册成功，通知代理或发送通知
        NotificationCenter.default.post(name: .userDidLogin, object: result.user)
        
        // 显示欢迎消息
        let alert = UIAlertController(title: "注册成功", message: "欢迎加入 Soul！", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "开始使用", style: .default) { _ in
            // 返回到主界面
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                // 这里应该设置主界面的根视图控制器
                // 暂时先dismiss当前界面
                self.dismiss(animated: true)
            }
        })
        present(alert, animated: true)
    }
    
    private func handleRegistrationError(_ error: Error) {
        let authError = error as? AuthError ?? .unknown(error.localizedDescription)
        showAlert(title: "注册失败", message: authError.localizedDescription ?? "未知错误")
    }
    
    private func setLoading(_ isLoading: Bool) {
        registerButton.isEnabled = !isLoading
        registerButton.setTitle(isLoading ? "" : "注册", for: .normal)
        
        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
        
        displayNameTextField.isEnabled = !isLoading
        emailTextField.isEnabled = !isLoading
        passwordTextField.isEnabled = !isLoading
        confirmPasswordTextField.isEnabled = !isLoading
        termsCheckbox.isEnabled = !isLoading
        loginButton.isEnabled = !isLoading
    }
    
    private func updatePasswordStrength() {
        guard let password = passwordTextField.text else {
            passwordStrengthLabel.text = "密码强度："
            passwordStrengthIndicator.backgroundColor = .systemGray5
            return
        }
        
        let strength = calculatePasswordStrength(password)
        
        switch strength {
        case 0:
            passwordStrengthLabel.text = "密码强度："
            passwordStrengthIndicator.backgroundColor = .systemGray5
        case 1:
            passwordStrengthLabel.text = "密码强度：弱"
            passwordStrengthIndicator.backgroundColor = .systemRed
        case 2:
            passwordStrengthLabel.text = "密码强度：中"
            passwordStrengthIndicator.backgroundColor = .systemOrange
        case 3:
            passwordStrengthLabel.text = "密码强度：强"
            passwordStrengthIndicator.backgroundColor = .systemGreen
        default:
            passwordStrengthLabel.text = "密码强度："
            passwordStrengthIndicator.backgroundColor = .systemGray5
        }
    }
    
    private func calculatePasswordStrength(_ password: String) -> Int {
        if password.isEmpty { return 0 }
        
        var strength = 0
        
        // 长度检查
        if password.count >= 6 { strength += 1 }
        
        // 包含数字
        if password.rangeOfCharacter(from: .decimalDigits) != nil { strength += 1 }
        
        // 包含字母
        if password.rangeOfCharacter(from: .letters) != nil { strength += 1 }
        
        // 包含特殊字符或长度超过8位
        if password.count >= 8 || password.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
            strength = min(strength + 1, 3)
        }
        
        return strength
    }
    
    private func updateRegisterButtonState() {
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""
        let confirmPassword = confirmPasswordTextField.text ?? ""
        
        let isValid = !email.isEmpty && 
                     !password.isEmpty && 
                     !confirmPassword.isEmpty && 
                     termsCheckbox.isSelected
        
        registerButton.alpha = isValid ? 1.0 : 0.6
    }
    
    private func showTermsAndPrivacy() {
        let alert = UIAlertController(title: "用户协议和隐私政策", message: "这里应该显示完整的用户协议和隐私政策内容。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
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
        case displayNameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField:
            textField.resignFirstResponder()
            if registerButton.alpha == 1.0 {
                registerButtonTapped()
            }
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
