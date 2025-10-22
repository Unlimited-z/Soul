//
//  RegisterViewModel.swift
//  Soul
//
//  Created by Assistant on 2025-01-25.
//

import Foundation
import RxSwift
import RxCocoa
import SoulNetwork

// MARK: - RegisterViewModel Protocol
protocol RegisterViewModelProtocol {
    // 输入
    var username: BehaviorRelay<String> { get }
    var password: BehaviorRelay<String> { get }
    var nickname: BehaviorRelay<String> { get }
    var registerTrigger: PublishRelay<Void> { get }
    
    // Outputs
    var isLoading: Driver<Bool> { get }
    var isRegisterEnabled: Driver<Bool> { get }
    var registerResult: Driver<RegisterResult> { get }
    var errorMessage: Driver<String?> { get }
}

// MARK: - Register Result
enum RegisterResult {
    case success(String?)
    case failure(String)
}

// MARK: - RegisterViewModel Implementation
class RegisterViewModel: RegisterViewModelProtocol {
    // MARK: - Input Properties
    let username = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")
    let nickname = BehaviorRelay<String>(value: "")
    let registerTrigger = PublishRelay<Void>()
    
    // MARK: - Outputs
    let isLoading: Driver<Bool>
    let isRegisterEnabled: Driver<Bool>
    let registerResult: Driver<RegisterResult>
    let errorMessage: Driver<String?>
    
    // MARK: - Private Properties
    private let disposeBag = DisposeBag()
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let registerResultRelay = PublishRelay<RegisterResult>()
    private let errorRelay = BehaviorRelay<String?>(value: nil)
    
    // MARK: - Initialization
    init() {
        // 设置 isLoading
        isLoading = loadingRelay.asDriver()
        
        // 设置 isRegisterEnabled（用户名、密码、昵称必须有效，且非加载状态）
        isRegisterEnabled = Observable.combineLatest(
            username.asObservable(),
            password.asObservable(),
            nickname.asObservable(),
            loadingRelay.asObservable()
        )
        .map { username, password, nickname, isLoading in
            let usernameValid = !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            let passwordValid = password.count >= 6
            let nicknameValid = !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            return usernameValid && passwordValid && nicknameValid && !isLoading
        }
        .asDriver(onErrorJustReturn: false)
        
        // 设置 registerResult
        registerResult = registerResultRelay.asDriver(onErrorJustReturn: .failure("未知错误"))
        
        // 设置 errorMessage
        errorMessage = errorRelay.asDriver()
        
        // 处理注册触发
        registerTrigger
            .withLatestFrom(Observable.combineLatest(
                username.asObservable(),
                password.asObservable(),
                nickname.asObservable()
            ))
            .subscribe(onNext: { [weak self] username, password, nickname in
                self?.performRegistration(
                    username: username,
                    password: password,
                    nickname: nickname
                )
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    private func performRegistration(
        username: String,
        password: String,
        nickname: String
    ) {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 验证输入
        guard !trimmedUsername.isEmpty else {
            errorRelay.accept("请输入用户名")
            return
        }
        
        guard password.count >= 6 else {
            errorRelay.accept("密码至少需要6位")
            return
        }
        
        guard !trimmedNickname.isEmpty else {
            errorRelay.accept("请输入昵称")
            return
        }
        
        loadingRelay.accept(true)
        errorRelay.accept(nil)
        
        AuthServiceManager.shared.register(
            username: trimmedUsername,
            password: password,
            nickname: trimmedNickname
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingRelay.accept(false)
                
                switch result {
                case .success(let response):
                    // HTTP 200成功，使用data字段作为成功消息
                    let successMessage = response.data ?? "注册成功"
                    self?.registerResultRelay.accept(.success(successMessage))
                case .failure(let error):
                    let errorMessage = "网络错误：\(error.localizedDescription)"
                    self?.registerResultRelay.accept(.failure(errorMessage))
                    self?.errorRelay.accept(errorMessage)
                }
            }
        }
    }
}