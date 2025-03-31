//
//  MessagesViewController.swift
//  AnyTranslator MessagesExtension
//
//  Created by Cardiff Emde on 3/31/25.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    private let languagePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let languages = ["English", "Spanish", "French", "German", "Italian", "Portuguese", "Russian", "Japanese", "Korean", "Chinese"]
    
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
        
        // Setup language picker
        languagePicker.delegate = self
        languagePicker.dataSource = self
        
        // Create a stack view to hold our UI elements
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add a label for the picker
        let label = UILabel()
        label.text = "Select Target Language:"
        label.textAlignment = .center
        
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(languagePicker)
        stackView.addArrangedSubview(translateButton)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            translateButton.heightAnchor.constraint(equalToConstant: 44),
            languagePicker.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    @objc private func translateButtonTapped() {
        guard let conversation = activeConversation else { return }
        
        // Get the selected text from the conversation
        if let selectedMessage = conversation.selectedMessage,
           let layout = selectedMessage.layout as? MSMessageTemplateLayout {
            let text = layout.caption ?? ""
            let selectedLanguage = languages[languagePicker.selectedRow(inComponent: 0)]
            
            // Translate to selected language
            Task {
                do {
                    let translatedText = try await TranslationService.shared.translate(
                        text: text,
                        to: selectedLanguage
                    )
                    
                    // Create a new message with the translated text
                    let message = MSMessage()
                    let layout = MSMessageTemplateLayout()
                    layout.caption = translatedText
                    message.layout = layout
                    
                    // Insert the translated message
                    conversation.insert(message) { error in
                        if let error = error {
                            print("Failed to send message: \(error.localizedDescription)")
                        }
                    }
                } catch {
                    print("Translation failed: \(error.localizedDescription)")
                }
            }
        }
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

// MARK: - UIPickerViewDelegate & UIPickerViewDataSource
extension MessagesViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row]
    }
}
