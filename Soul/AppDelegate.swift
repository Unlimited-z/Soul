//
//  AppDelegate.swift
//  Soul
//
//  Created by Ricard.li on 2025/7/16.
//
//test sourcetree
import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 初始化Firebase
        FirebaseApp.configure()
        
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        // 设置根视图控制器
        setupRootViewController()
        
        // 监听认证状态变化
        setupAuthStateListener()
        
        return true
    }
    
    // MARK: - Private Methods
    private func setupRootViewController() {
//        let authService = AuthService.shared
//        
//        if authService.isAuthenticated {
//            // 用户已登录，显示主界面
//            showMainInterface()
//        } else {
//            // 用户未登录，显示登录界面
//            showLoginInterface()
//        }
        showMainInterface()
    }
    
    private func setupAuthStateListener() {
        // 监听用户登录通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidLogin),
            name: .userDidLogin,
            object: nil
        )
        
        // 监听用户登出通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidLogout),
            name: .userDidLogout,
            object: nil
        )
    }
    
    @objc private func userDidLogin() {
        DispatchQueue.main.async {
            self.showMainInterface()
        }
    }
    
    @objc private func userDidLogout() {
        DispatchQueue.main.async {
            self.showLoginInterface()
        }
    }
    
    private func showMainInterface() {
        let mainController = MainTabBarController()
        window?.rootViewController = mainController
    }
    
    private func showLoginInterface() {
        let loginController = LoginViewController()
        let navigationController = UINavigationController(rootViewController: loginController)
        navigationController.modalPresentationStyle = .fullScreen
        window?.rootViewController = navigationController
    }
}

