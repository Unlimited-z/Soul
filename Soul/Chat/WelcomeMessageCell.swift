import UIKit
import SnapKit

class WelcomeMessageCell: UITableViewCell {
    
    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var welcomeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "welcome_icon") // 请确保添加了这张图片到项目中
        return imageView
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.darkGray
        label.textAlignment = .left
        return label
    }()
    
    private lazy var aiAvatarView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor(red: 110/255.0, green: 60/255.0, blue: 241/255.0, alpha: 0.1)
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        // 可以设置AI头像图片
        imageView.image = UIImage(systemName: "brain.head.profile")
        imageView.tintColor = UIColor(red: 110/255.0, green: 60/255.0, blue: 241/255.0, alpha: 1.0)
        return imageView
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.text = nil
        welcomeImageView.image = UIImage(named: "welcome_icon")
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(aiAvatarView)
        containerView.addSubview(welcomeImageView)
        containerView.addSubview(messageLabel)
    }
    
    private func setupConstraints() {
        // 容器视图 - 固定尺寸 383*581
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
//        // AI 头像
//        aiAvatarView.snp.makeConstraints { make in
//            make.left.top.equalToSuperview().offset(16)
//            make.width.height.equalTo(40)
//        }
        
        // 欢迎图片 - 占据大部分空间
        welcomeImageView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(aiAvatarView.snp.bottom).offset(16)
            make.height.equalTo(350) // 给图片固定高度
        }
        
        // 消息文本
        messageLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(welcomeImageView.snp.bottom).offset(16)
            make.bottom.lessThanOrEqualToSuperview().offset(-20)
        }
    }
    
    // MARK: - Configuration
    func configure(with message: ChatMessage) {
        messageLabel.text = message.content
    }
    
    // MARK: - Size
    static func cellHeight() -> CGFloat {
        return 581
    }
} 
