//
//  MessagesViewController.swift
//  AnyTranslator MessagesExtension
//
//  Created by Cardiff Emde on 3/31/25.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    private let textField: UITextField = {
        let field = UITextField()
        field.placeholder = "Type text to translate..."
        field.borderStyle = .roundedRect
        field.translatesAutoresizingMaskIntoConstraints = false
        field.textAlignment = .left
        field.returnKeyType = .done
        field.clearButtonMode = .whileEditing
        return field
    }()
    
    private let languages = ["English", "Spanish", "French", "German", "Italian", "Portuguese", "Russian", "Japanese", "Korean", "Chinese"]
    
    private var selectedSourceLanguage: String = "English"
    private var selectedTargetLanguage: String = "Spanish"
    
    private let sourceLanguageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("From: English", for: .normal)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
        return button
    }()
    
    private let targetLanguageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("To: Spanish", for: .normal)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
        return button
    }()
    
    private let languageSelectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let languageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 44)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Create a simple button to translate
        let translateButton = UIButton(type: .system)
        translateButton.setTitle("Translate", for: .normal)
        translateButton.backgroundColor = .systemBlue
        translateButton.setTitleColor(.white, for: .normal)
        translateButton.layer.cornerRadius = 8
        translateButton.translatesAutoresizingMaskIntoConstraints = false
        translateButton.addTarget(self, action: #selector(translateButtonTapped), for: .touchUpInside)
        
        // Setup text field with keyboard toolbar
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexSpace, doneButton]
        textField.inputAccessoryView = toolbar
        
        // Setup language buttons
        sourceLanguageButton.addTarget(self, action: #selector(sourceLanguageButtonTapped), for: .touchUpInside)
        targetLanguageButton.addTarget(self, action: #selector(targetLanguageButtonTapped), for: .touchUpInside)
        
        // Setup collection view
        languageCollectionView.delegate = self
        languageCollectionView.dataSource = self
        languageCollectionView.register(LanguageCell.self, forCellWithReuseIdentifier: "LanguageCell")
        
        // Create a stack view to hold our UI elements
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add views to stack
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(sourceLanguageButton)
        stackView.addArrangedSubview(targetLanguageButton)
        stackView.addArrangedSubview(languageSelectionView)
        stackView.addArrangedSubview(translateButton)
        
        // Add collection view to language selection view
        languageSelectionView.addSubview(languageCollectionView)
        languageSelectionView.isHidden = true
        
        view.addSubview(stackView)
        
        // Update constraints
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            translateButton.heightAnchor.constraint(equalToConstant: 44),
            sourceLanguageButton.heightAnchor.constraint(equalToConstant: 44),
            targetLanguageButton.heightAnchor.constraint(equalToConstant: 44),
            languageSelectionView.heightAnchor.constraint(equalToConstant: 64),
            languageCollectionView.topAnchor.constraint(equalTo: languageSelectionView.topAnchor),
            languageCollectionView.leadingAnchor.constraint(equalTo: languageSelectionView.leadingAnchor),
            languageCollectionView.trailingAnchor.constraint(equalTo: languageSelectionView.trailingAnchor),
            languageCollectionView.bottomAnchor.constraint(equalTo: languageSelectionView.bottomAnchor)
        ])
        
        // Update toolbar size when view size changes
        view.addObserver(self, forKeyPath: "bounds", options: [.new, .initial], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "bounds" {
            if let toolbar = textField.inputAccessoryView as? UIToolbar {
                toolbar.frame.size.width = view.bounds.width
            }
        }
    }
    
    deinit {
        view.removeObserver(self, forKeyPath: "bounds")
    }
    
    @objc private func sourceLanguageButtonTapped() {
        languageSelectionView.isHidden = false
        updateLanguageButton(sourceLanguageButton, title: "From: \(selectedSourceLanguage)")
    }
    
    @objc private func targetLanguageButtonTapped() {
        languageSelectionView.isHidden = false
        updateLanguageButton(targetLanguageButton, title: "To: \(selectedTargetLanguage)")
    }
    
    private func updateLanguageButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
    }
    
    @objc private func translateButtonTapped() {
        guard let conversation = activeConversation else {
            print("No active conversation")
            return
        }
        
        // Get the text from the text field
        if let text = textField.text, !text.isEmpty {
            print("Text to translate: \(text)")
            print("Source language: \(selectedSourceLanguage)")
            print("Target language: \(selectedTargetLanguage)")
            
            // Translate to selected language
            Task {
                do {
                    print("Starting translation...")
                    let translatedText = try await TranslationService.shared.translate(
                        text: text,
                        from: selectedSourceLanguage,
                        to: selectedTargetLanguage
                    )
                    print("Translation successful: \(translatedText)")
                    
                    // Create a new message with the translated text
                    let translatedMessage = MSMessage()
                    let translatedLayout = MSMessageTemplateLayout()
                    translatedLayout.caption = translatedText
                    translatedMessage.layout = translatedLayout
                    
                    // Insert the translated message
                    conversation.insert(translatedMessage) { error in
                        if let error = error {
                            print("Failed to send message: \(error.localizedDescription)")
                        } else {
                            print("Successfully sent translated message")
                            // Clear the text field after successful translation
                            DispatchQueue.main.async {
                                self.textField.text = ""
                            }
                        }
                    }
                } catch {
                    print("Translation failed: \(error.localizedDescription)")
                    // Create an error message to show in the conversation
                    let errorMessage = MSMessage()
                    let errorLayout = MSMessageTemplateLayout()
                    errorLayout.caption = "Translation failed: \(error.localizedDescription)"
                    errorMessage.layout = errorLayout
                    conversation.insert(errorMessage) { error in
                        if let error = error {
                            print("Failed to send error message: \(error.localizedDescription)")
                        }
                    }
                }
            }
        } else {
            print("No text entered")
        }
    }
    
    @objc private func dismissKeyboard() {
        textField.resignFirstResponder()
    }
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        print("Extension will become active")
    }
    
    override func didBecomeActive(with conversation: MSConversation) {
        super.didBecomeActive(with: conversation)
        print("Extension did become active")
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension MessagesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return languages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LanguageCell", for: indexPath) as! LanguageCell
        cell.configure(with: languages[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedLanguage = languages[indexPath.item]
        if sourceLanguageButton.isHighlighted {
            selectedSourceLanguage = selectedLanguage
            updateLanguageButton(sourceLanguageButton, title: "From: \(selectedLanguage)")
        } else {
            selectedTargetLanguage = selectedLanguage
            updateLanguageButton(targetLanguageButton, title: "To: \(selectedLanguage)")
        }
        languageSelectionView.isHidden = true
    }
}

// MARK: - LanguageCell
class LanguageCell: UICollectionViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemGray6
        layer.cornerRadius = 8
        
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with language: String) {
        titleLabel.text = language
    }
}

// MARK: - UITextFieldDelegate
extension MessagesViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
