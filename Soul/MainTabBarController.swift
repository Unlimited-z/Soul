import UIKit
import SnapKit
import SoulNetwork

class MainTabBarController: UIViewController {
    
    // 页面控制器
    private let homeViewController = ViewController()
    private let chatViewController = CardViewController()
    private var currentViewController: UIViewController!
    
    // 自定义 TabBar
    private let customTabBarView = CustomTabBarView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupInitialViewController()
        setupTokenExpiryNotification()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // 设置自定义 TabBar 代理
        customTabBarView.delegate = self
        
        // 添加子视图
        view.addSubview(customTabBarView)
        
        // 隐藏导航栏
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupConstraints() {   
        customTabBarView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(80)
        }
    }
    
    private func setupInitialViewController() {
        // 默认显示首页
        showViewController(homeViewController, at: 0)
    }
    
    // MARK: - Token Expiry Handling
    
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
        print("🔒 MainTabBarController收到token过期通知")
        
        DispatchQueue.main.async { [weak self] in
            self?.navigateToLogin()
        }
    }
    
    /// 跳转到登录页面（纯代码）
    private func navigateToLogin() {
        let loginVC = LoginViewController()
        let navigationController = UINavigationController(rootViewController: loginVC)
        
        // 获取当前窗口（优先使用当前视图所在的窗口，其次使用 keyWindow）
        if let window = view.window {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = navigationController
            }, completion: nil)
            print("✅ MainTabBarController已跳转到登录页面（纯代码）")
        } else if let window = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .flatMap({ $0.windows })
                    .first(where: { $0.isKeyWindow }) {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = navigationController
            }, completion: nil)
            print("✅ MainTabBarController已跳转到登录页面（纯代码，使用keyWindow）")
        } else {
            print("❌ MainTabBarController无法获取窗口进行跳转")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func showViewController(_ viewController: UIViewController, at index: Int) {
        // 移除当前视图控制器
        if let current = currentViewController {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }
        
        // 添加新的视图控制器
        addChild(viewController)
        view.insertSubview(viewController.view, belowSubview: customTabBarView)
        
        // 设置约束
        viewController.view.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(customTabBarView.snp.top)
        }
        
        viewController.didMove(toParent: self)
        currentViewController = viewController
        
        // 更新 TabBar 选中状态
        customTabBarView.setSelectedIndex(index)
    }
}

// MARK: - CustomTabBarViewDelegate
extension MainTabBarController: CustomTabBarViewDelegate {
    func tabBarView(_ tabBarView: CustomTabBarView, didSelectIndex index: Int) {
        switch index {
        case 0:
            showViewController(homeViewController, at: 0)
        case 1:
            showViewController(chatViewController, at: 1)
        default:
            break
        }
    }
}
