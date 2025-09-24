//
//  ImageTestViewController.swift
//  Soul
//
//  Created by Ricard.li on 2025/7/16.
//

import UIKit
import SnapKit
import SoulNetwork

class ImageTestViewController: BaseViewController {
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor.systemBackground
        table.delegate = self
        table.dataSource = self
        table.register(PromptCell.self, forCellReuseIdentifier: "PromptCell")
        table.register(GeneratedImageCell.self, forCellReuseIdentifier: "GeneratedImageCell")
        return table
    }()
    
    private lazy var generateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("生成图片", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = UIColor.systemGreen
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(generateButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Data
    private var userInputTexts: [String] = []
    private var generatedImageURL: String?
    private var isGenerating = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadUserInputs()
        updateGenerateButtonState()
    }
    
    // MARK: - Setup Methods
    override func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = "图片生成测试"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "清除数据",
            style: .plain,
            target: self,
            action: #selector(clearDataTapped)
        )
        
        view.addSubview(tableView)
        view.addSubview(generateButton)
        view.addSubview(loadingIndicator)
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(generateButton.snp.top).offset(-16)
        }
        
        generateButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.height.equalTo(50)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // MARK: - Data Loading
    private func loadUserInputs() {
        userInputTexts = ChatDataManager.shared.getUserInputTexts()
        tableView.reloadData()
        
        // 显示数据统计
        let totalCount = ChatDataManager.shared.getTotalMessageCount()
        print("📊 加载了 \(userInputTexts.count) 条用户输入，总消息数：\(totalCount)")
        
        if userInputTexts.isEmpty {
            showEmptyState()
        }
    }
    
    private func showEmptyState() {
        let alertController = UIAlertController(
            title: "暂无数据",
            message: "请先在聊天页面发送一些消息，然后再来生成图片。",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "确定", style: .default))
        present(alertController, animated: true)
    }
    
    // MARK: - Actions
    @objc private func generateButtonTapped() {
        guard !userInputTexts.isEmpty else {
            showEmptyState()
            return
        }
        
        // 将所有用户输入合并，并添加生成卡通人物的提示
        let combinedPrompt = createCombinedPrompt()
        generateImage(with: combinedPrompt)
    }
    
    private func createCombinedPrompt() -> String {
        let userInputsText = userInputTexts.joined(separator: "，")
        return "根据这些内容：\(userInputsText)，生成一张采用「3D渲染」背景为纯，带有一些卡通风格的多巴胺配色的女孩全身图片"
    }
    
    @objc private func clearDataTapped() {
        let alertController = UIAlertController(
            title: "清除所有数据",
            message: "这将删除所有保存的聊天记录，确定要继续吗？",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel))
        alertController.addAction(UIAlertAction(title: "确定", style: .destructive) { _ in
            ChatDataManager.shared.clearAllData()
            self.loadUserInputs()
            self.generatedImageURL = nil
            self.updateGenerateButtonState()
        })
        
        present(alertController, animated: true)
    }
    
    // MARK: - Image Generation
    private func generateImage(with prompt: String) {
        setGeneratingState(true)
        
        DoubaoImageService.shared.generateImage(prompt: prompt) { [weak self] result in
            guard let self = self else { return }
            
            self.setGeneratingState(false)
            
            switch result {
            case .success(let imageURL):
                self.generatedImageURL = imageURL
                print("🎨 图片生成成功: \(imageURL)")
                
                // 更新 UI 显示生成的图片
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.scrollToGeneratedImage()
                }
                
                // 显示生成成功的提示
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showSuccessAlert(combinedPrompt: prompt)
                }
                
            case .failure(let error):
                print("❌ 图片生成失败: \(error.localizedDescription)")
                self.showErrorAlert(error.localizedDescription)
            }
        }
    }
    
    private func setGeneratingState(_ generating: Bool) {
        isGenerating = generating
        
        if generating {
            loadingIndicator.startAnimating()
            generateButton.setTitle("生成中...", for: .normal)
            generateButton.isEnabled = false
            generateButton.alpha = 0.5
        } else {
            loadingIndicator.stopAnimating()
            generateButton.setTitle("生成图片", for: .normal)
            updateGenerateButtonState()
        }
    }
    
    private func updateGenerateButtonState() {
        let hasData = !userInputTexts.isEmpty
        generateButton.isEnabled = hasData && !isGenerating
        generateButton.alpha = hasData ? 1.0 : 0.5
    }
    
    private func scrollToGeneratedImage() {
        // 如果有生成的图片，滚动到底部显示
        if generatedImageURL != nil {
            let lastSection = numberOfSections(in: tableView) - 1
            if lastSection >= 0 {
                let lastRow = tableView.numberOfRows(inSection: lastSection) - 1
                if lastRow >= 0 {
                    let indexPath = IndexPath(row: lastRow, section: lastSection)
                    tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }
    
    private func showErrorAlert(_ message: String) {
        let alertController = UIAlertController(
            title: "生成失败",
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "确定", style: .default))
        present(alertController, animated: true)
    }
    
    private func showSuccessAlert(combinedPrompt: String) {
        let alertController = UIAlertController(
            title: "图片生成成功",
            message: "使用的提示词：\(combinedPrompt)",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "确定", style: .default))
        present(alertController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ImageTestViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return generatedImageURL != nil ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return userInputTexts.count
        } else {
            return 1 // 生成的图片
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "用户输入内容（共 \(userInputTexts.count) 条）"
        } else {
            return "生成的图片"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PromptCell", for: indexPath) as! PromptCell
            let text = userInputTexts[indexPath.row]
            cell.configure(with: text, isSelected: false) // 不再需要选择状态
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GeneratedImageCell", for: indexPath) as! GeneratedImageCell
            if let imageURL = generatedImageURL {
                cell.configure(with: imageURL)
            }
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension ImageTestViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 移除选择功能，用户输入内容仅用于展示
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 300 // 图片显示高度
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 60 : 300
    }
}
