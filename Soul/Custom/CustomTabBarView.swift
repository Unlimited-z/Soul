import UIKit
import SnapKit

protocol CustomTabBarViewDelegate: AnyObject {
    func tabBarView(_ tabBarView: CustomTabBarView, didSelectIndex index: Int)
}

class CustomTabBarView: UIView {
    
    weak var delegate: CustomTabBarViewDelegate?
    
    private var selectedIndex: Int = 0 {
        didSet {
            updateSelection()
        }
    }
    
    // UI 组件
    private let containerView = UIView()
    private let homeButton = UIButton()
    private let chatButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    private func setupUI() {
        // 设置主容器
        backgroundColor = UIColor(red: 110/255.0, green: 60/255.0, blue: 241/255.0, alpha: 1.0)
        
        // 添加阴影
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.1
        
        // 设置首页按钮 - 使用图片，大小自适应
        homeButton.setImage(UIImage(named: "selectedhome"), for: .normal)
        homeButton.tintColor = UIColor(red: 110/255.0, green: 60/255.0, blue: 241/255.0, alpha: 1.0)
        homeButton.tag = 0
        homeButton.contentMode = .scaleAspectFit
        homeButton.imageView?.contentMode = .scaleAspectFit
        
        // 设置聊天按钮 - 使用系统图标（未选中状态），大小自适应
        chatButton.setImage(UIImage(named: "card_icon"), for: .normal)
        chatButton.tintColor = UIColor.white.withAlphaComponent(0.8)
        chatButton.tag = 1
        chatButton.contentMode = .scaleAspectFit
        chatButton.imageView?.contentMode = .scaleAspectFit
        
        // 添加子视图
        addSubview(containerView)
        containerView.addSubview(homeButton)
        containerView.addSubview(chatButton)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 首页按钮 - 根据图片大小自适应，左侧定位
        homeButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(70)
            make.centerY.equalToSuperview()
        }
        
        // 聊天按钮 - 根据图片大小自适应，右侧定位
        chatButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-70)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupActions() {
        homeButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        chatButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        let newIndex = sender.tag
        guard newIndex != selectedIndex else { return }
        
        selectedIndex = newIndex
        delegate?.tabBarView(self, didSelectIndex: newIndex)
    }
    
    private func updateSelection() {
        let selectedButton = selectedIndex == 0 ? homeButton : chatButton
        let unselectedButton = selectedIndex == 0 ? chatButton : homeButton
        
        // 动画：选中按钮向上移动
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            selectedButton.snp.updateConstraints { make in
                make.centerY.equalToSuperview().offset(-40)
            }
            unselectedButton.snp.updateConstraints { make in
                make.centerY.equalToSuperview().offset(0)
            }
            self.layoutIfNeeded()
        }
        
        // 更新按钮颜色和图标
        UIView.animate(withDuration: 0.2) {
            selectedButton.tintColor = UIColor(red: 110/255.0, green: 60/255.0, blue: 241/255.0, alpha: 1.0)
            unselectedButton.tintColor = UIColor.white.withAlphaComponent(0.8)
        }
        
        // 更新图标状态 - 使用自定义图片
        if selectedIndex == 0 {
            // 首页选中：使用 selectedhome 图片
            homeButton.setImage(UIImage(named: "selectedhome"), for: .normal)
            // 聊天未选中：使用系统图标
            chatButton.setImage(UIImage(named: "card_icon"), for: .normal)
        } else {
            // 首页未选中：使用系统图标
            homeButton.setImage(UIImage(named: "home_icon"), for: .normal)
            // 聊天选中：使用 selectedcard 图片
            chatButton.setImage(UIImage(named: "selectedcard"), for: .normal)
        }
    }
    
    // 公开方法，用于外部设置选中状态
    func setSelectedIndex(_ index: Int, animated: Bool = true) {
        selectedIndex = index
    }
} 
