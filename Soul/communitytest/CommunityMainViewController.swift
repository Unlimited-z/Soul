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
                                           selectedTextColor: AppTheme.Colors.primaryPurple)
        
        let control = BetterSegmentedControl(
            frame: .zero,
            segments: segments,
            index: 0,
            options: [
                .backgroundColor(AppTheme.Colors.primaryPurple),
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
    private let contactsContainerView = UIView()
    private let searchContainerView = UIView()
    private let searchTextField = UITextField()
    private let searchButton = UIButton(type: .system)
    private let friendsTableView = UITableView()
    
    // MARK: - Data
    private var friends: [Friend] = []
    private var filteredFriends: [Friend] = []
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
        
        // 联系人页面容器
        contactsContainerView.backgroundColor = .clear
        contactsContainerView.isHidden = true
        
        // 搜索区域
        searchContainerView.backgroundColor = .systemGray6
        searchContainerView.layer.cornerRadius = 12
        
        searchTextField.placeholder = "搜索好友..."
        searchTextField.borderStyle = .none
        searchTextField.backgroundColor = .white
        searchTextField.layer.cornerRadius = 8
        searchTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        searchTextField.leftViewMode = .always
        searchTextField.returnKeyType = .search
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        
        searchButton.setTitle("搜索", for: .normal)
        searchButton.backgroundColor = .systemBlue
        searchButton.setTitleColor(.white, for: .normal)
        searchButton.layer.cornerRadius = 8
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        
        // 好友列表
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        friendsTableView.register(FriendTableViewCell.self, forCellReuseIdentifier: "FriendTableViewCell")
        friendsTableView.backgroundColor = .clear
        friendsTableView.separatorStyle = .none
        friendsTableView.isScrollEnabled = true
        
        // 添加所有子视图
        view.addSubview(topSpacerView)
        view.addSubview(segmentControl)
        view.addSubview(contentContainerView)
        
        // 动态页面
        contentContainerView.addSubview(momentsTableView)
        
        // 联系人页面
        contentContainerView.addSubview(contactsContainerView)
        contactsContainerView.addSubview(searchContainerView)
        searchContainerView.addSubview(searchTextField)
        searchContainerView.addSubview(searchButton)
        contactsContainerView.addSubview(friendsTableView)
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
        
        // 联系人页面容器
        contactsContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 搜索区域
        searchContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
        
        searchTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(searchButton.snp.leading).offset(-12)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
        }
        
        searchButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(70)
            make.height.equalTo(40)
        }
        
        // 好友列表
        friendsTableView.snp.makeConstraints { make in
            make.top.equalTo(searchContainerView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Data Methods
    private func loadFriends() {
        // 创建测试数据，只显示6个好友对应6张图片
        friends = [
            Friend(id: "1", name: "张三", avatar: "avatar2", isOnline: true),
            Friend(id: "2", name: "李四", avatar: "avatar3", isOnline: false),
            Friend(id: "3", name: "王五", avatar: "avatar4", isOnline: true),
            Friend(id: "4", name: "赵六", avatar: "avatar5", isOnline: true),
            Friend(id: "5", name: "钱七", avatar: "avatar6", isOnline: false),
            Friend(id: "6", name: "孙八", avatar: "avatar7", isOnline: true)
        ]
        filteredFriends = friends
        updateTableViewHeight()
        friendsTableView.reloadData()
    }
    
    private func updateTableViewHeight() {
        // TableView 现在可以自然滚动，不需要手动控制高度
        friendsTableView.isScrollEnabled = true
    }
    
    private func switchToPage(index: Int) {
        currentSelectedIndex = index
        
        if index == 0 {
            // 显示动态页面
            momentsTableView.isHidden = false
            contactsContainerView.isHidden = true
        } else {
            // 显示联系人页面
            momentsTableView.isHidden = true
            contactsContainerView.isHidden = false
        }
    }
    
    private func filterFriends(with searchText: String) {
        if searchText.isEmpty {
            filteredFriends = friends
        } else {
            filteredFriends = friends.filter { friend in
                friend.name.lowercased().contains(searchText.lowercased())
            }
        }
        updateTableViewHeight()
        friendsTableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func segmentChanged() {
        switchToPage(index: segmentControl.index)
    }
    
    @objc private func searchTextChanged() {
        guard let searchText = searchTextField.text else { return }
        filterFriends(with: searchText)
    }
    
    @objc private func searchButtonTapped() {
        searchTextField.resignFirstResponder()
        guard let searchText = searchTextField.text else { return }
        filterFriends(with: searchText)
    }
}

// MARK: - UITextFieldDelegate
extension CommunityMainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchButtonTapped()
        return true
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CommunityMainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == momentsTableView {
            return 10 // 模拟10条动态
        } else {
            return filteredFriends.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == momentsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MomentsTableViewCell", for: indexPath) as! MomentsTableViewCell
            cell.configure(with: indexPath.row)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableViewCell", for: indexPath) as! FriendTableViewCell
            let friend = filteredFriends[indexPath.row]
            cell.configure(with: friend)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == momentsTableView {
            return 120
        } else {
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == friendsTableView {
            let friend = filteredFriends[indexPath.row]
            
            // 跳转到好友的个人资料页面（即之前的 CommunityTestViewController）
            let profileVC = CommunityTestViewController()
            profileVC.title = friend.name
            profileVC.friendImageName = friend.avatar // 传递图片名称
            let navController = UINavigationController(rootViewController: profileVC)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        }
        // 动态页面的点击事件可以在这里添加
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

// MARK: - FriendTableViewCell
class FriendTableViewCell: UITableViewCell {
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let statusLabel = UILabel()
    private let arrowImageView = UIImageView()
    
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
        avatarImageView.layer.cornerRadius = 25
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        nameLabel.textColor = .label
        
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.textColor = .secondaryLabel
        
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .systemGray3
        arrowImageView.contentMode = .scaleAspectFit
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(arrowImageView)
    }
    
    private func setupConstraints() {
        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.top.equalTo(avatarImageView.snp.top).offset(4)
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-12)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.bottom.equalTo(avatarImageView.snp.bottom).offset(-4)
            make.trailing.equalTo(nameLabel)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
    }
    
    func configure(with friend: Friend) {
        nameLabel.text = friend.name
        statusLabel.text = friend.isOnline ? "在线" : "离线"
        statusLabel.textColor = friend.isOnline ? .systemGreen : .systemGray
        
        // 设置头像
        if !friend.avatar.isEmpty, let image = UIImage(named: friend.avatar) {
            avatarImageView.image = image
            avatarImageView.contentMode = .scaleAspectFill
            avatarImageView.clipsToBounds = true
            avatarImageView.layer.cornerRadius = 25 // 圆形头像
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
            avatarImageView.tintColor = friend.isOnline ? .systemBlue : .systemGray
            avatarImageView.contentMode = .scaleAspectFit
            avatarImageView.layer.cornerRadius = 0
        }
    }
}
