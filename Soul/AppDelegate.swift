//
//  AppDelegate.swift
//  Soul
//
//  Created by Ricard.li on 2025/7/16.
//
//test sourcetree
import UIKit
import SoulNetwork

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        // 校验token有效性
        validateTokenOnLaunch()
        
        // 设置根视图控制器
        setupRootViewController()
        
        // 监听token过期通知
        setupTokenExpiryNotification()
        
        return true
    }
    
    // MARK: - Application Lifecycle
    func applicationDidBecomeActive(_ application: UIApplication) {
        // 应用进入前台时校验token
        validateTokenOnForeground()
    }
    
    // MARK: - Private Methods
    private func setupRootViewController() {
        showMainInterface()
    }
    
    private func showMainInterface() {
        let mainController = MainTabBarController()
        window?.rootViewController = mainController
    }
    
    // MARK: - Token Validation
    
    /// 应用启动时校验token
    private func validateTokenOnLaunch() {
        print("🚀 应用启动，开始校验token...")
        
        // 校验当前token是否有效
        let isValid = AuthServiceManager.shared.validateCurrentToken()
        
        if !isValid {
            print("⚠️ Token无效或已过期，需要重新登录")
        } else {
            print("✅ Token有效")
            
            // 检查是否即将过期（24小时内）
            if AuthServiceManager.shared.isTokenExpiringSoon(within: 24 * 60) {
                if let remainingTime = AuthServiceManager.shared.getTokenRemainingTime() {
                    let hours = Int(remainingTime / 3600)
                    let minutes = Int((remainingTime.truncatingRemainder(dividingBy: 3600)) / 60)
                    print("⏰ Token将在 \(hours)小时\(minutes)分钟后过期")
                }
            }
        }
    }
    
    /// 应用进入前台时校验token
    private func validateTokenOnForeground() {
        print("📱 应用进入前台，校验token...")
        
        // 校验当前token是否有效
        let isValid = AuthServiceManager.shared.validateCurrentToken()
        
        if !isValid {
            print("⚠️ Token在后台期间已过期")
        }
    }
    
    /// 设置token过期通知监听
    private func setupTokenExpiryNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTokenExpiry),
            name: .tokenDidExpire,
            object: nil
        )
    }
    
    /// 处理token过期通知
    @objc private func handleTokenExpiry() {
        print("🔒 收到token过期通知，跳转到登录页面")
        
        DispatchQueue.main.async { [weak self] in
            self?.navigateToLogin()
        }
    }
    
    /// 跳转到登录页面（纯代码）
    private func navigateToLogin() {
        let loginVC = LoginViewController()
        let navigationController = UINavigationController(rootViewController: loginVC)
        
        // 优先使用 AppDelegate 的 window，其次使用 keyWindow
        let targetWindow = self.window ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        
        if let window = targetWindow {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = navigationController
            }, completion: nil)
            print("✅ 已跳转到登录页面（纯代码）")
        } else {
            print("❌ 无法获取窗口进行跳转")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

