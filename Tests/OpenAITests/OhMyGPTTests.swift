//
//  OhMyGPTTests.swift
//
//
//  Created by zang qilong on 2024/9/3.
//

import XCTest
@testable import SwiftOpenAI

final class OhMyGPTTests: XCTestCase {
    let service = OpenAIServiceFactory.ohmygptService(apiKey: "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")
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testBaseResponse() async throws {
        let parameters = ChatCompletionParameters(messages: [.init(role: .user, content: .text("who is linken?"))],
                                                  model: .gpt4o)
        do {
            let choices = try await service.startChat(parameters: parameters).choices
            debugPrint(choices.map(\.message).compactMap(\.content))
            // Work with choices
        } catch APIError.responseUnsuccessful(let description, let statusCode) {
            print("Network error with status code: \(statusCode) and description: \(description)")
            throw APIError.responseUnsuccessful(description: description, statusCode: statusCode)
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    
}
