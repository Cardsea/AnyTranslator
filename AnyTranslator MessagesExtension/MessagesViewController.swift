//
//  MessagesViewController.swift
//  AnyTranslator MessagesExtension
//
//  Created by Cardiff Emde on 3/31/25.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
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
        
        view.addSubview(translateButton)
        
        NSLayoutConstraint.activate([
            translateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            translateButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            translateButton.widthAnchor.constraint(equalToConstant: 120),
            translateButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func translateButtonTapped() {
        guard let conversation = activeConversation else { return }
        
        // Get the selected text from the conversation
        if let selectedMessage = conversation.selectedMessage,
           let layout = selectedMessage.layout as? MSMessageTemplateLayout {
            let text = layout.caption ?? ""
            
            // Translate to English (or any other default language)
            Task {
                do {
                    let translatedText = try await TranslationService.shared.translate(
                        text: text,
                        to: "English"
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
