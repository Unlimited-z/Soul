//
//  ContactsView.swift
//  Soul
//
//  Created by Assistant on 2024/01/01.
//

import UIKit
import SnapKit

// MARK: - ContactsViewDelegate
protocol ContactsViewDelegate: AnyObject {
    func contactsView(_ contactsView: ContactsView, didSelectFriend friend: Friend)
}

// MARK: - ContactsView
class ContactsView: UIView {
    
    // MARK: - Delegate
    weak var delegate: ContactsViewDelegate?
    
    // MARK: - UI Components
    private let searchContainerView = UIView()
    private let searchTextField = UITextField()
    private let searchButton = UIButton(type: .system)
    private let friendsTableView = UITableView()
    
    // MARK: - Data
    private var friends: [Friend] = []
    private var filteredFriends: [Friend] = []
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        loadFriends()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        backgroundColor = .clear
        
        // 搜索区域
        searchContainerView.backgroundColor = AppTheme.Colors.primaryPurple
        searchContainerView.layer.cornerRadius = 20
        
        searchTextField.placeholder = nil
        searchTextField.borderStyle = .none
        searchTextField.backgroundColor = .white
        searchTextField.layer.cornerRadius = 8
        
        // 创建搜索图标作为leftView
        let searchIconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let searchIconImageView = UIImageView(frame: CGRect(x: 12, y: 12, width: 16, height: 16))
        searchIconImageView.image = UIImage(systemName: "magnifyingglass")
        searchIconImageView.tintColor = .systemGray
        searchIconImageView.contentMode = .scaleAspectFit
        searchIconContainer.addSubview(searchIconImageView)
        
        searchTextField.leftView = searchIconContainer
        searchTextField.leftViewMode = .always
        searchTextField.returnKeyType = .search
        searchTextField.delegate = self
        searchTextField.layer.cornerRadius = 20
        searchTextField.clipsToBounds = true
        searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        
        searchButton.setTitle("搜索", for: .normal)
        searchButton.titleLabel?.font = .systemFont(ofSize: 20)
        searchButton.backgroundColor = .clear
        searchButton.setTitleColor(.white, for: .normal)
//        searchButton.layer.cornerRadius = 30
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        
        // 好友列表
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        friendsTableView.register(FriendTableViewCell.self, forCellReuseIdentifier: "FriendTableViewCell")
        friendsTableView.backgroundColor = .clear
        friendsTableView.separatorStyle = .none
        friendsTableView.isScrollEnabled = true
        friendsTableView.showsVerticalScrollIndicator = false
        friendsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        
        // 添加子视图
        addSubview(searchContainerView)
        searchContainerView.addSubview(searchTextField)
        searchContainerView.addSubview(searchButton)
        addSubview(friendsTableView)
    }
    
    private func setupConstraints() {
        // 搜索区域
        searchContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
        
        searchButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(70)
            make.height.equalTo(40)
        }
        
        searchTextField.snp.makeConstraints { make in
            make.leading.equalTo(searchButton.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
        }
        
        // 好友列表
        friendsTableView.snp.makeConstraints { make in
            make.top.equalTo(searchContainerView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
//            make.width.equalTo(346)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Data Methods
    private func loadFriends() {
        // 创建测试数据，只显示6个好友对应6张图片
        friends = [
            Friend(id: "1", name: "张三", avatar: "avatar2", relation: .hot),
            Friend(id: "2", name: "李四", avatar: "avatar3", relation: .hot),
            Friend(id: "3", name: "王五", avatar: "avatar4", relation: .normal),
            Friend(id: "4", name: "赵六", avatar: "avatar5", relation: .defaulted),
            Friend(id: "5", name: "钱七", avatar: "avatar6", relation: .defaulted),
            Friend(id: "6", name: "孙八", avatar: "avatar7", relation: .defaulted)
        ]
        filteredFriends = friends
        friendsTableView.reloadData()
    }
    
    private func filterFriends(with searchText: String) {
        if searchText.isEmpty {
            filteredFriends = friends
        } else {
            filteredFriends = friends.filter { friend in
                friend.name.lowercased().contains(searchText.lowercased())
            }
        }
        friendsTableView.reloadData()
    }
    
    // MARK: - Public Methods
    func reloadData() {
        loadFriends()
    }
    
    // MARK: - Actions
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
extension ContactsView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchButtonTapped()
        return true
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ContactsView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableViewCell", for: indexPath) as! FriendTableViewCell
        let friend = filteredFriends[indexPath.row]
        cell.configure(with: friend)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let friend = filteredFriends[indexPath.row]
        delegate?.contactsView(self, didSelectFriend: friend)
    }
}

// MARK: - FriendTableViewCell
class FriendTableViewCell: UITableViewCell {
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let statusLabel = UILabel()
    private let messageLabel = UILabel()
//    private let arrowImageView = UIImageView()
    
    
    
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
        
        // 设置cell容器样式
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 20
        containerView.layer.masksToBounds = true
        contentView.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.leading.trailing.equalToSuperview()
        }
        
//        avatarImageView.backgroundColor = .systemGray5
        avatarImageView.layer.cornerRadius = 25
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        
        nameLabel.font = .systemFont(ofSize: 24, weight: .medium)
        nameLabel.textColor = AppTheme.Colors.secondaryPurple
        
        statusLabel.font = .systemFont(ofSize: 8)
        statusLabel.textAlignment = .center
        statusLabel.textColor = .white
        statusLabel.backgroundColor = AppTheme.Colors.secondaryPurple
        statusLabel.layer.cornerRadius = 12
        statusLabel.clipsToBounds = true

        
        messageLabel.font = .systemFont(ofSize: 8)
        messageLabel.textColor = AppTheme.Colors.secondaryPurple
        
        
        
        containerView.addSubview(avatarImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(statusLabel)
        containerView.addSubview(messageLabel)
        
//        containerView.addSubview(arrowImageView)
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
//            make.trailing.equalTo(arrowImageView.snp.leading).offset(-12)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).offset(20)
            make.centerY.equalTo(nameLabel)
            make.height.equalTo(22)
            make.width.equalTo(77)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
        }
        
    }
    
    func configure(with friend: Friend) {
        nameLabel.text = friend.name
//        statusLabel.text = friend.isOnline ? "在线" : "离线"
//        statusLabel.textColor = friend.isOnline ? .systemGreen : .systemGray
        let relation = friend.relation
        
        switch relation {
        case .hot:
            statusLabel.text = "至交好友"
        case .normal:
            statusLabel.text = "put好友"
        case .defaulted:
            statusLabel.isHidden = true
        }
        
        
        // 设置头像
        if !friend.avatar.isEmpty, let image = UIImage(named: friend.avatar) {
            avatarImageView.image = image
            avatarImageView.contentMode = .scaleAspectFill
            avatarImageView.clipsToBounds = true
            avatarImageView.layer.cornerRadius = 25 // 圆形头像
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
//            avatarImageView.tintColor = friend.isOnline ? .systemBlue : .systemGray
            avatarImageView.contentMode = .scaleAspectFit
            avatarImageView.layer.cornerRadius = 0
        }
        
        messageLabel.text = "消息:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    }
}
