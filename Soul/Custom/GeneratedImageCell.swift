//
//  GeneratedImageCell.swift
//  Soul
//
//  Created by Ricard.li on 2025/7/16.
//

import UIKit
import SnapKit

class GeneratedImageCell: UITableViewCell {
    
    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var generatedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.systemGray5
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var urlLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.systemGray
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Properties
    private var currentImageURL: String?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        generatedImageView.image = nil
        urlLabel.text = nil
        loadingIndicator.stopAnimating()
        currentImageURL = nil
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(generatedImageView)
        containerView.addSubview(loadingIndicator)
        containerView.addSubview(urlLabel)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
        
        generatedImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(220)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(generatedImageView)
        }
        
        urlLabel.snp.makeConstraints { make in
            make.top.equalTo(generatedImageView.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }
    
    // MARK: - Configuration
    func configure(with imageURL: String) {
        currentImageURL = imageURL
        urlLabel.text = "图片 URL: \(imageURL)"
        
        loadImage(from: imageURL)
    }
    
    // MARK: - Image Loading
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            showErrorState("无效的图片 URL")
            return
        }
        
        loadingIndicator.startAnimating()
        generatedImageView.image = nil
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self,
                      self.currentImageURL == urlString else { return }
                
                self.loadingIndicator.stopAnimating()
                
                if let error = error {
                    self.showErrorState("加载失败: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data,
                      let image = UIImage(data: data) else {
                    self.showErrorState("无法解析图片数据")
                    return
                }
                
                self.generatedImageView.image = image
                print("✅ 图片加载成功")
            }
        }.resume()
    }
    
    private func showErrorState(_ message: String) {
        generatedImageView.image = UIImage(systemName: "exclamationmark.triangle")
        generatedImageView.tintColor = UIColor.systemRed
        urlLabel.text = message
        urlLabel.textColor = UIColor.systemRed
    }
} 