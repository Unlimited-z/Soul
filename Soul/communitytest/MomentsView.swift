//
//  MomentsView.swift
//  Soul
//
//  Created by Assistant on 2024/01/01.
//

import UIKit
import SnapKit

// MARK: - MomentsViewDelegate
protocol MomentsViewDelegate: AnyObject {
    func momentsView(_ momentsView: MomentsView, didSelectMomentAt index: Int)
}

// MARK: - MomentsView
class MomentsView: UITableView {
    
    // MARK: - Properties
    weak var momentsDelegate: MomentsViewDelegate?
    
    // MARK: - Data
    private let momentsCount = 3 // 3个cell
    
    // MARK: - Initialization
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupUI()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        // 配置TableView
        delegate = self
        dataSource = self
        register(MomentsTableViewCell.self, forCellReuseIdentifier: "MomentsTableViewCell")
        // backgroundColor = .systemGroupedBackground
        separatorStyle = .none
        isScrollEnabled = true
//        contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 200}
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MomentsView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return momentsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MomentsTableViewCell", for: indexPath) as! MomentsTableViewCell
        cell.configure(with: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        momentsDelegate?.momentsView(self, didSelectMomentAt: indexPath.row)
    }
    

}

// MARK: - MomentsTableViewCell
class MomentsTableViewCell: UITableViewCell {
    private let topImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
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
        
        // 创建容器视图
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.1
        
        contentView.addSubview(containerView)
        
        // 设置容器视图约束，上下各留10px间距
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.leading.trailing.equalToSuperview()
        }
        
        // 顶部图片配置
//        topImageView.backgroundColor = .systemGray5
//        topImageView.layer.cornerRadius = 8
        topImageView.clipsToBounds = true
        topImageView.contentMode = .scaleAspectFill
        
        // 标题配置
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        
        // 副标题配置
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .left
        subtitleLabel.numberOfLines = 0
        
        containerView.addSubview(topImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
    }
    
    private func setupConstraints() {
        // 为contentView添加边距
//        contentView.snp.makeConstraints { make in
//            make.top.bottom.equalToSuperview().inset(8)
//            make.leading.trailing.equalToSuperview().inset(16)
//        }
        
        // 顶部图片 - 居中显示
        topImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(-10)
        }
        
        // 标题 - 左对齐
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(topImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(30)
        }
        
        // 副标题 - 左对齐
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    func configure(with index: Int) {
        let titles = [
            "正念（Mindfulness）疗法",
            "什么是认知行为疗法（CBT）？",
            "小行动与心理健康"
        ]
        
        let subtitles = [
            "核心点：关注当下的感受，接纳自己的情绪而不是抗拒。",
            "核心点：情绪—思维—行为之间相互影响。",
            "科学依据：研究表明，完成微小行动能促进多巴胺分泌，带来愉悦感；持续积累有助于形成积极行为习惯。"
        ]
        
        let imageNames = ["cell1", "cell2", "cell3"]
        
        titleLabel.text = titles[index]
        subtitleLabel.text = subtitles[index]
        topImageView.image = UIImage(named: imageNames[index])
    }
}
