//
//  MomentsHeaderView.swift
//  Soul
//
//  Created by Assistant on 2024/01/01.
//

import UIKit
import SnapKit

class MomentsHeaderView: UIView {
    
    // MARK: - UI Components
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "momentpic")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let backgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "detailbackground")
        //        imageView.contentMode = .scaleAspectFit
        return imageView
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

    }
    
    private func setupConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.top.equalTo(37)
            make.right.equalTo(10)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
        }
        
    }
    
}
