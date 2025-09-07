//
//  CardViewController.swift
//  Soul
//
//  Created by Assistant on 2024.
//

import UIKit
import SnapKit
import JXSegmentedView
import ZLSwipeableViewSwift

class CardViewController: BaseViewController {
    
    // MARK: - UI Components
    private let segmentedView = JXSegmentedView()
    private let segmentedDataSource = JXSegmentedTitleDataSource()
    
    private let swipeableView = ZLSwipeableView()
    private let promptView1 = PromptView(avatarImage: UIImage(named: "promote1"))
    private let promptView2 = PromptView(avatarImage: UIImage(named: "promote2"))
    
    // 一周日期数据
    private var weekDays: [String] = []
    private var selectedDayIndex = 0
    
    // ZLSwipeableView相关属性
    private var imageIndex = 0
//    private var loadCardsFromXib = false
    private let images = ["image1", "image2", "image3", "image4","image1", "image2", "image3", "image4","image1", "image2", "image3", "image4"]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()
        setupWeekDays()
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        title = "Card"
        navigationController?.navigationBar.prefersLargeTitles = false
        

    }
    
    override func setupUI() {
        super.setupUI()
        
        // 配置JXSegmentedView
        segmentedView.backgroundColor = AppTheme.Colors.lightPurple
        segmentedView.layer.shadowColor = UIColor.black.cgColor
        segmentedView.layer.shadowOffset = CGSize(width: 0, height: 2)
        segmentedView.layer.shadowOpacity = 0.1
        segmentedView.layer.shadowRadius = 4
        segmentedView.layer.cornerRadius = 12
        segmentedView.clipsToBounds = true
        segmentedView.delegate = self
        segmentedView.dataSource = segmentedDataSource
        
        // 配置数据源
        segmentedDataSource.titleNormalColor = UIColor.secondaryLabel
        segmentedDataSource.titleSelectedColor = UIColor.white
        segmentedDataSource.titleNormalFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        segmentedDataSource.titleSelectedFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        segmentedDataSource.isTitleColorGradientEnabled = true
        
        // 配置指示器
        let indicator = JXSegmentedIndicatorBackgroundView()
        indicator.indicatorColor = AppTheme.Colors.primaryPurple
        indicator.indicatorCornerRadius = 8
        indicator.indicatorHeight = 40
        segmentedView.indicators = [indicator]
        
        // 配置ZLSwipeableView
        swipeableView.backgroundColor = UIColor.clear
        
        // 添加点击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        swipeableView.addGestureRecognizer(tapGesture)
        
        // 配置滑动回调
        swipeableView.didStart = { view, location in
            print("Did start swiping view at location: \(location)")
        }
        
        swipeableView.swiping = { view, location, translation in
            print("Swiping at location: \(location) with translation: \(translation)")
        }
        
        swipeableView.didEnd = { view, location in
            print("Did end swiping view at location: \(location)")
        }
        
        swipeableView.didSwipe = { view, direction, vector in
            print("Did swipe view in direction: \(direction) with vector: \(vector)")
        }
        
        swipeableView.didCancel = { view in
            print("Did cancel swiping view")
        }
        
        // 配置提示词视图
        promptView1.updateContent(text: "今日提示词\n点击生成你的专属卡片")
        promptView2.updateContent(text: "每日灵感\n发现更多创意可能")
        
        // 添加子视图
        view.addSubview(segmentedView)
        view.addSubview(swipeableView)
        view.addSubview(promptView1)
        view.addSubview(promptView2)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        swipeableView.nextView = {
            return self.nextCardView()
        }
    }
    private func setupConstraints() {
        // JXSegmentedView约束
        segmentedView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
        
        // ZLSwipeableView约束
        swipeableView.snp.makeConstraints { make in
            make.top.equalTo(segmentedView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(350)
        }
        
        // 第一个提示词视图约束
        promptView1.snp.makeConstraints { make in
            make.top.equalTo(swipeableView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(80)
        }
        
        // 第二个提示词视图约束
        promptView2.snp.makeConstraints { make in
            make.top.equalTo(promptView1.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(80)
        }
    }
    
    private func setupWeekDays() {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: today)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_CN")
        
        weekDays.removeAll()
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: i, to: startOfWeek)!
            
            // 设置日期文本
            dateFormatter.dateFormat = "E"
            let weekdayText = dateFormatter.string(from: date)
            dateFormatter.dateFormat = "d"
            let dayText = dateFormatter.string(from: date)
            
            let dayTitle = "\(weekdayText)\n\(dayText)"
            weekDays.append(dayTitle)
            
            // 设置今天为选中状态
            if calendar.isDate(date, inSameDayAs: today) {
                selectedDayIndex = i
            }
        }
        
        // 更新数据源
        segmentedDataSource.titles = weekDays
        segmentedDataSource.reloadData(selectedIndex: selectedDayIndex)
        segmentedView.defaultSelectedIndex = selectedDayIndex
        segmentedView.reloadData()
    }
    
    // MARK: - Button Actions
    @objc func cardTapped() {
        self.swipeableView.swipeTopView(inDirection: .Right)
    }
    
    // MARK: - Card Creation
    func nextCardView() -> UIView? {
        if imageIndex >= images.count {
            imageIndex = 0
        }
        
        let imageView = UIImageView(frame: swipeableView.bounds)

        imageView.image = UIImage(named: images[imageIndex])
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        
        imageIndex += 1
        
        return imageView
    }
    
}


    



// MARK: - JXSegmentedViewDelegate
extension CardViewController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        selectedDayIndex = index
        print("选中了第\(selectedDayIndex + 1)天")
    }
}
