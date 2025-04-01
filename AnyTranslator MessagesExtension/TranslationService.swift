import Foundation

class TranslationService {
    static let shared = TranslationService()
    private let baseURL = "https://api.mymemory.translated.net/get"
    
    func translate(text: String, from: String, to: String) async throws -> String {
        guard let sourceCode = TranslationMessage.supportedLanguages[from],
              let targetCode = TranslationMessage.supportedLanguages[to] else {
            print("Translation failed: Invalid language selection")
            throw NSError(domain: "TranslationService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unsupported language"])
        }
        
        print("Creating translation request from \(sourceCode) to \(targetCode)")
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "q", value: text),
            URLQueryItem(name: "langpair", value: "\(sourceCode)|\(targetCode)")
        ]
        
        guard let url = components.url else {
            throw NSError(domain: "TranslationService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        do {
            print("Sending request to MyMemory Translation API")
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                throw NSError(domain: "TranslationService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }
            
            print("Received response with status code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                print("Server error: \(httpResponse.statusCode)")
                if let errorString = String(data: data, encoding: .utf8) {
                    print("Error response: \(errorString)")
                }
                throw NSError(domain: "TranslationService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Server error: \(httpResponse.statusCode)"])
            }
            
            let decoder = JSONDecoder()
            let translationResponse = try decoder.decode(MyMemoryTranslationResponse.self, from: data)
            print("Successfully decoded response")
            return translationResponse.responseData.translatedText
        } catch {
            print("Translation request failed: \(error)")
            throw error
        }
    }
}

struct MyMemoryTranslationResponse: Codable {
    let responseData: ResponseData
}

struct ResponseData: Codable {
    let translatedText: String
} 