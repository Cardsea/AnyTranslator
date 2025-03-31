import Foundation

struct TranslationMessage: Codable {
    var sourceText: String
    var translatedText: String
    var sourceLanguage: String
    var targetLanguage: String
    
    static let supportedLanguages = [
        "English": "en",
        "Spanish": "es",
        "French": "fr",
        "German": "de",
        "Italian": "it",
        "Portuguese": "pt",
        "Russian": "ru",
        "Chinese": "zh",
        "Japanese": "ja",
        "Korean": "ko"
    ]
    
    static let languageNames = Array(supportedLanguages.keys).sorted()
} 