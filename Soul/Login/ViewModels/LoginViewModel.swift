//
//  LoginViewModel.swift
//  Soul
//
//  Created by Assistant on 2025-01-25.
//

import Foundation
import RxSwift
import RxCocoa
import SoulNetwork

// MARK: - LoginViewModel Protocol
protocol LoginViewModelProtocol {
    // Inputs
    var username: BehaviorRelay<String> { get }
    var password: BehaviorRelay<String> { get }
    var loginTrigger: PublishRelay<Void> { get }
    
    // Outputs
    var isLoading: Driver<Bool> { get }
    var isLoginEnabled: Driver<Bool> { get }
    var loginResult: Driver<LoginResult> { get }
    var errorMessage: Driver<String?> { get }
}

// MARK: - Login Result
enum LoginResult {
    case success(String?)
    case failure(String)
}

// MARK: - LoginViewModel Implementation
class LoginViewModel: LoginViewModelProtocol {
    
    // MARK: - Inputs
    let username = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")
    let loginTrigger = PublishRelay<Void>()
    
    // MARK: - Outputs
    let isLoading: Driver<Bool>
    let isLoginEnabled: Driver<Bool>
    let loginResult: Driver<LoginResult>
    let errorMessage: Driver<String?>
    
    // MARK: - Private Properties
    private let disposeBag = DisposeBag()
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let loginResultRelay = PublishRelay<LoginResult>()
    private let errorRelay = BehaviorRelay<String?>(value: nil)
    
    // MARK: - Initialization
    init() {
        // 设置 isLoading
        isLoading = loadingRelay.asDriver()
        
        // 设置 isLoginEnabled - 用户名和密码都不为空时启用
        isLoginEnabled = Observable.combineLatest(
            username.asObservable(),
            password.asObservable(),
            loadingRelay.asObservable()
        )
        .map { username, password, isLoading in
            return !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                   !password.isEmpty &&
                   !isLoading
        }
        .asDriver(onErrorJustReturn: false)
        
        // 设置 loginResult
        loginResult = loginResultRelay.asDriver(onErrorJustReturn: .failure("未知错误"))
        
        // 设置 errorMessage
        errorMessage = errorRelay.asDriver()
        
        // 处理登录触发
        loginTrigger
            .withLatestFrom(Observable.combineLatest(username.asObservable(), password.asObservable()))
            .subscribe(onNext: { [weak self] username, password in
                self?.performLogin(username: username, password: password)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    private func performLogin(username: String, password: String) {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedUsername.isEmpty, !password.isEmpty else {
            errorRelay.accept("请填写完整的用户名和密码")
            return
        }
        
        loadingRelay.accept(true)
        errorRelay.accept(nil)
        
        AuthServiceManager.shared.login(
            username: trimmedUsername,
            password: password
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingRelay.accept(false)
                
                switch result {
                case .success(let response):
                    // HTTP 200成功，发送登录成功通知
                    NotificationCenter.default.post(name: .userDidLogin, object: nil)
                    let successMessage = response.msg ?? "登录成功"
                    self?.loginResultRelay.accept(.success(successMessage))
                case .failure(let error):
                    let errorMessage = "网络错误：\(error.localizedDescription)"
                    self?.loginResultRelay.accept(.failure(errorMessage))
                    self?.errorRelay.accept(errorMessage)
                }
            }
        }
    }
}


