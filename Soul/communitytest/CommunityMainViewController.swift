//
//  CommunityMainViewController.swift
//  Soul
//
//  Created by Assistant on 2024/01/01.
//

import UIKit
import SnapKit
import BetterSegmentedControl

class CommunityMainViewController: BaseViewController {
    
    // MARK: - UI Components
    
    // 顶部空白区域
    private let topSpacerView = UIView()
    
    // Segment Control
    private let segmentControl: BetterSegmentedControl = {
        let segments = LabelSegment.segments(withTitles: ["动态", "联系人"],
                                           normalFont: UIFont.systemFont(ofSize: 16),
                                           normalTextColor: UIColor.white,
                                           selectedFont: UIFont.systemFont(ofSize: 16, weight: .medium),
                                           selectedTextColor: AppTheme.Colors.secondaryPurple)
        
        let control = BetterSegmentedControl(
            frame: .zero,
            segments: segments,
            index: 0,
            options: [
                .backgroundColor(AppTheme.Colors.secondaryPurple),
                .indicatorViewBackgroundColor(UIColor.white),
                .cornerRadius(30),
                .indicatorViewInset(8),
                .animationDuration(0.3),
                .animationSpringDamping(0.8)
            ]
        )
        
        return control
    }()
    
    // 内容容器
    private let contentContainerView = UIView()
    
    // 动态页面
    private let momentsView = MomentsView()
    
    // 联系人页面
    private let contactsView = ContactsView()
    
    // MARK: - Data
    private var currentSelectedIndex = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()
        loadFriends()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFriends()
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        title = "社区"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // 添加关闭按钮
        let closeButton = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(closeButtonTapped))
        navigationItem.leftBarButtonItem = closeButton
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    override func setupUI() {
        super.setupUI()
        
        // 顶部空白区域
        topSpacerView.backgroundColor = .clear
        
        // Segment Control
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        // 内容容器
        contentContainerView.backgroundColor = .clear
        
        // 动态页面
        momentsView.backgroundColor = .clear
        momentsView.momentsDelegate = self
        
        // 联系人页面
        contactsView.backgroundColor = .clear
        contactsView.isHidden = true
        contactsView.delegate = self
        
        // 添加所有子视图
        view.addSubview(topSpacerView)
        view.addSubview(segmentControl)
        view.addSubview(contentContainerView)
        
        // 动态页面
        contentContainerView.addSubview(momentsView)
        
        // 联系人页面
        contentContainerView.addSubview(contactsView)
    }
    
    private func setupConstraints() {
        // 顶部空白区域
        topSpacerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
        }
        
        // Segment Control
        segmentControl.snp.makeConstraints { make in
            make.top.equalTo(topSpacerView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(90)
            make.height.equalTo(60)
        }
        
        // 内容容器
        contentContainerView.snp.makeConstraints { make in
            make.top.equalTo(segmentControl.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        // 动态页面
        momentsView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // 联系人页面
        contactsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Data Methods
    private func loadFriends() {
        // 联系人数据现在由ContactsView管理
        contactsView.reloadData()
    }
    
    private func switchToPage(index: Int) {
        currentSelectedIndex = index
        
        if index == 0 {
            // 显示动态页面
            momentsView.isHidden = false
            contactsView.isHidden = true
        } else {
            // 显示联系人页面
            momentsView.isHidden = true
            contactsView.isHidden = false
        }
    }
    
    // MARK: - Actions
    @objc private func segmentChanged() {
        switchToPage(index: segmentControl.index)
    }
}



// MARK: - MomentsViewDelegate
extension CommunityMainViewController: MomentsViewDelegate {
    func momentsView(_ momentsView: MomentsView, didSelectMomentAt index: Int) {
        // 动态页面的点击事件可以在这里添加
        print("选中了第\(index + 1)条动态")
    }
}

// MARK: - ContactsViewDelegate
extension CommunityMainViewController: ContactsViewDelegate {
    func contactsView(_ contactsView: ContactsView, didSelectFriend friend: Friend) {
        // 跳转到好友的个人资料页面（即之前的 CommunityTestViewController）
        let profileVC = CommunityTestViewController()
        profileVC.title = friend.name
        profileVC.friendImageName = friend.avatar // 传递图片名称
        let navController = UINavigationController(rootViewController: profileVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
}
