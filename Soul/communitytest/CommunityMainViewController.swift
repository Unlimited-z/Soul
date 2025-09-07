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
    private let momentsTableView = UITableView()
    
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
        momentsTableView.delegate = self
        momentsTableView.dataSource = self
        momentsTableView.register(MomentsTableViewCell.self, forCellReuseIdentifier: "MomentsTableViewCell")
        momentsTableView.backgroundColor = .clear
        momentsTableView.separatorStyle = .none
        momentsTableView.isScrollEnabled = true
        
        // 联系人页面
        contactsView.backgroundColor = .clear
        contactsView.isHidden = true
        contactsView.delegate = self
        
        // 添加所有子视图
        view.addSubview(topSpacerView)
        view.addSubview(segmentControl)
        view.addSubview(contentContainerView)
        
        // 动态页面
        contentContainerView.addSubview(momentsTableView)
        
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
        momentsTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
            momentsTableView.isHidden = false
            contactsView.isHidden = true
        } else {
            // 显示联系人页面
            momentsTableView.isHidden = true
            contactsView.isHidden = false
        }
    }
    
    // MARK: - Actions
    @objc private func segmentChanged() {
        switchToPage(index: segmentControl.index)
    }
}



// MARK: - UITableViewDataSource, UITableViewDelegate
extension CommunityMainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10 // 模拟10条动态
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MomentsTableViewCell", for: indexPath) as! MomentsTableViewCell
        cell.configure(with: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 动态页面的点击事件可以在这里添加
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

// MARK: - MomentsTableViewCell
class MomentsTableViewCell: UITableViewCell {
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let contentLabel = UILabel()
    private let timeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        avatarImageView.backgroundColor = .systemGray5
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        nameLabel.textColor = .label
        
        contentLabel.font = .systemFont(ofSize: 14)
        contentLabel.textColor = .label
        contentLabel.numberOfLines = 2
        
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .secondaryLabel
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(timeLabel)
    }
    
    private func setupConstraints() {
        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(40)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.top.equalTo(avatarImageView.snp.top)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(contentLabel.snp.bottom).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    
    func configure(with index: Int) {
        nameLabel.text = "用户\(index + 1)"
        contentLabel.text = "这是第\(index + 1)条动态内容，展示朋友圈效果..."
        timeLabel.text = "\(index + 1)小时前"
        
        // 设置随机头像颜色
        let colors: [UIColor] = [.systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemPink]
        avatarImageView.backgroundColor = colors[index % colors.count]
    }
}
