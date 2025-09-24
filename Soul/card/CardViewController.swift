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
import SoulNetwork

class CardViewController: BaseViewController {
    
    // MARK: - UI Components
    private let segmentedView = JXSegmentedView()
    private let segmentedDataSource = JXSegmentedTitleDataSource()
    
    private let swipeableView = ZLSwipeableView()
    private let promptView1 = PromptView(avatarImage: UIImage(named: "promote1"))
    private let promptView2 = PromptView(avatarImage: UIImage(named: "promote2"))
    private let inputControlView = InputControlView()
    
    // 文本输入相关组件
    private lazy var inputContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 25
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.1
        view.isHidden = true // 初始隐藏
        return view
    }()
    
    private lazy var textInputView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.clear
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = UIColor.label
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        textView.returnKeyType = .send
        return textView
    }()
    
    // 一周日期数据
    private var weekDays: [String] = []
    private var selectedDayIndex = 0
    
    // ZLSwipeableView相关属性
    private var imageIndex = 0
//    private var loadCardsFromXib = false
    private var images = ["card1", "card2", "card3", "card4","card5","card6","card7"]
    private var generatedImages: [String: UIImage] = [:]
    
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
        
        // 配置 inputControlView
        inputControlView.onTextInputTapped = { [weak self] in
            self?.showTextInput()
        }
        inputControlView.onVoiceInputTapped = { [weak self] in
            print("语音输入功能暂未实现")
        }
        
        // 添加子视图
        view.addSubview(segmentedView)
        view.addSubview(swipeableView)
        view.addSubview(promptView1)
        view.addSubview(promptView2)
        view.addSubview(inputContainer)
        view.addSubview(inputControlView)
        
        // 配置文本输入容器
        inputContainer.addSubview(textInputView)
        
        // 添加键盘监听
        addKeyboardObservers()
        
        // 添加点击空白区域收起键盘的手势
        let tapGestureToHideKeyboard = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardOnTap))
        tapGestureToHideKeyboard.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureToHideKeyboard)
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
            make.bottom.equalTo(promptView1.snp.top).offset(-16)
        }
        
        // 提示词视图约束（隐藏状态）
        promptView1.snp.makeConstraints { make in
            make.top.equalTo(swipeableView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(80)
        }
        
        promptView2.snp.makeConstraints { make in
            make.top.equalTo(promptView1.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(80)
        }
        
        // 显示提示词视图
        promptView1.isHidden = false
        promptView2.isHidden = false
        
        // InputControlView约束
        inputControlView.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
        
        inputContainer.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.height.greaterThanOrEqualTo(50)
        }
        
        textInputView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
    
    @objc func hideKeyboardOnTap() {
        // 如果文本输入框正在显示且是第一响应者，则收起键盘
        if !inputContainer.isHidden && textInputView.isFirstResponder {
            hideTextInput()
        }
    }
    
    // MARK: - 文本输入相关方法
    private func showTextInput() {
        // 隐藏自定义控件
        inputControlView.isHidden = true
        
        // 显示文本输入框
        inputContainer.isHidden = false
        
        // // 重新设置swipeableView约束
        // swipeableView.snp.remakeConstraints { make in
        //     make.top.equalTo(segmentedView.snp.bottom).offset(20)
        //     make.left.right.equalToSuperview()
        //     make.bottom.equalTo(inputContainer.snp.top).offset(-16)
        // }
        
        // 动画显示并聚焦
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.textInputView.becomeFirstResponder()
        }
    }
    
    private func hideTextInput() {
        // 收起键盘
        textInputView.resignFirstResponder()
        
        // 隐藏文本输入框
        inputContainer.isHidden = true
        
        // 显示自定义控件
        inputControlView.isHidden = false
        
//        // 重新设置swipeableView约束
//        swipeableView.snp.remakeConstraints { make in
//            make.top.equalTo(segmentedView.snp.bottom).offset(20)
//            make.left.right.equalToSuperview()
//            make.bottom.equalTo(promptView1.snp.top).offset(-16)
//        }
        
        // 动画隐藏
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func sendMessage() {
        guard !textInputView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let messageText = textInputView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        textInputView.text = ""
        
        // 隐藏文本输入
        hideTextInput()
        
        // 生成图片
        generateImageWithPrompt(messageText)
    }
    
    // MARK: - 键盘监听
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        // 计算键盘高度，需要考虑到父视图控制器约束中预留的TabBar高度
        let tabBarHeight: CGFloat = 80 // CustomTabBar的高度
        let keyboardHeight = keyboardFrame.height - tabBarHeight
        
        inputContainer.snp.updateConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-keyboardHeight)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        inputContainer.snp.updateConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func generateImageWithPrompt(_ prompt: String) {
        // 显示加载状态
        inputControlView.setTextButtonEnabled(false)
        
        DoubaoImageService.shared.generateImage(prompt: prompt) { [weak self] result in
            DispatchQueue.main.async {
                self?.inputControlView.setTextButtonEnabled(true)
                
                switch result {
                case .success(let imageURL):
                    self?.addGeneratedImageToTop(imageURL: imageURL)
                case .failure(let error):
                    self?.showErrorAlert(error: error)
                }
            }
        }
    }
    
    private func addGeneratedImageToTop(imageURL: String) {
        // 异步加载图片
        loadImage(from: imageURL) { [weak self] image in
            DispatchQueue.main.async {
                guard let self = self, let image = image else { return }
                
                // 生成唯一的图片标识符
                let imageKey = "generated_\(Date().timeIntervalSince1970)"
                
                // 存储生成的图片
                self.generatedImages[imageKey] = image
                
                // 将生成的图片标识符添加到images数组的开头
                self.images.insert(imageKey, at: 0)
                
                // 重置imageIndex以显示新图片
                self.imageIndex = 0
                
                // 重新加载swipeableView
                self.swipeableView.discardViews()
                self.swipeableView.loadViews()
            }
        }
    }
    
    private func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }.resume()
    }
    
    private func showErrorAlert(error: ImageServiceError) {
        let alert = UIAlertController(title: "生成失败", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Card Creation
    func nextCardView() -> UIView? {
        if imageIndex >= images.count {
            imageIndex = 0
        }
        
        let imageView = UIImageView(frame: swipeableView.bounds)
        let imageName = images[imageIndex]
        
        // 检查是否为生成的图片
        if let generatedImage = generatedImages[imageName] {
            imageView.image = generatedImage
        } else {
            imageView.image = UIImage(named: imageName)
        }
        
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        
        imageIndex += 1
        
        return imageView
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


    



// MARK: - JXSegmentedViewDelegate
extension CardViewController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        selectedDayIndex = index
        print("选中了第\(selectedDayIndex + 1)天")
    }
}

// MARK: - UITextViewDelegate
extension CardViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            sendMessage()
            return false
        }
        return true
    }
}
