//
//  ContactsHeaderView.swift
//  Soul
//
//  Created by Assistant on 2024/01/01.
//

import UIKit
import SnapKit

class ContactsHeaderView: UIView {
    
    // MARK: - UI Components
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "contactpic")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let backgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "detailbackground")
        //        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let edittingButton : UIButton = {
        let bt = UIButton()
        bt.backgroundColor = AppTheme.Colors.secondaryPurple
        bt.setTitle("编辑个人资料", for: .normal)
        bt.titleLabel?.font = .systemFont(ofSize: 8)
        bt.titleLabel?.textColor = .white
        bt.layer.cornerRadius = 12
        bt.clipsToBounds = true
        return bt
    }()

    private let sexLabel : UILabel = {
        let label = UILabel()
        label.text = "女"
        label.font = .systemFont(ofSize: 16)
        label.textColor = AppTheme.Colors.secondaryPurple
        label.backgroundColor = .white
        label.layer.cornerRadius = 12
        label.textAlignment = .center
        label.clipsToBounds = true
        return label
    }()
    
    private let nameLabel :UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.text = "晴川不晚"
        label.textAlignment = .center
        label.textColor = AppTheme.Colors.secondaryPurple
        label.backgroundColor = .white
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()
    
    private let messageLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 8)
        label.text = "个性签名：把喜欢的事情做到极致，就是浪漫。"
        label.textColor = AppTheme.Colors.secondaryPurple
        label.backgroundColor = .clear
        return label
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
//        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(backgroundView)
        addSubview(iconImageView)
        
        addSubview(edittingButton)
        addSubview(sexLabel)
        addSubview(nameLabel)
        addSubview(messageLabel)

    }
    
    private func setupConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.top.equalTo(37)
            make.right.equalTo(10)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalTo(42)
            make.left.equalTo(240)
        }
        
        
        edittingButton.snp.makeConstraints { make in
            make.top.equalTo(79)
            make.left.equalTo(61)
            make.width.equalTo(71)
            make.height.equalTo(22)
        }
        
        sexLabel.snp.makeConstraints { make in
            make.top.equalTo(112)
            make.left.equalTo(61)
            make.width.equalTo(42)
            make.height.equalTo(32)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(112)
            make.left.equalTo(111)
            make.width.equalTo(103)
            make.height.equalTo(32)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(148)
            make.left.equalTo(61)
            make.width.equalTo(168)
            make.height.equalTo(40)
        }
    }

}
