//
//  OhMyGPTTests.swift
//
//
//  Created by zang qilong on 2024/9/3.
//

import XCTest
@testable import SwiftOpenAI

enum ConsumptionType: String, CaseIterable {
    case diet = "餐饮"
    case traffic = "交通"
    case shopping = "购物"
    case entertainment = "娱乐"
    case medical = "医疗"
    case social = "社交"
    case pet = "宠物"
    case other = "其他"
    
    var jsonSchema: JSONSchemaType {
        return .string
    }
}

final class OhMyGPTTests: XCTestCase {
    let service = OpenAIServiceFactory.ohmygptService(apiKey: "", debugEnabled: true)
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testBaseResponse() async throws {
        let parameters = ChatCompletionParameters(messages: [.init(role: .user, content: .text("谁是杜甫?"))],
                                                  model: .gpt4omini)
        do {
            let choices = try await service.startChat(parameters: parameters).choices
            debugPrint(choices.map(\.message).compactMap(\.content))
            XCTAssert(choices.count > 0)
            // Work with choices
        } catch APIError.responseUnsuccessful(let description, let statusCode) {
            print("Network error with status code: \(statusCode) and description: \(description)")
            throw APIError.responseUnsuccessful(description: description, statusCode: statusCode)
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    
    func testStructResponse() async throws {
        let parameters = ChatCompletionParameters(messages: [.init(role: .user, content: .text("我今天买了一杯咖啡，花了36元，请帮我解析出消费类型和消费金额"))],
                                                  model: .gpt4omini, responseFormat: .jsonSchema(responseFormat()))
        do {
            let choices = try await service.startChat(parameters: parameters).choices
            debugPrint(choices.map(\.message).compactMap(\.content))
            XCTAssert(choices.count > 0)
            // Work with choices
        } catch APIError.responseUnsuccessful(let description, let statusCode) {
            print("Network error with status code: \(statusCode) and description: \(description)")
            throw APIError.responseUnsuccessful(description: description, statusCode: statusCode)
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    
    func testImageParse() async throws {
        let imageURL = "https://p.ipic.vip/gyiw9y.PNG"
        let prompt = "这是一张消费截图，请帮我解析出消费类型和消费金额"
        let messageContent: [ChatCompletionParameters.Message.ContentType.MessageContent] = [.text(prompt), .imageUrl(.init(url: URL(string: imageURL)!))]
        let parameters = ChatCompletionParameters(messages: [.init(role: .user, content: .contentArray(messageContent))], model: .gpt4o20240806, responseFormat: .jsonSchema(billResponseFormat()))
        do {
            let choices = try await service.startChat(parameters: parameters).choices
            debugPrint(choices.map(\.message).compactMap(\.content))
            XCTAssert(choices.count > 0)
            // Work with choices
        } catch APIError.responseUnsuccessful(let description, let statusCode) {
            print("Network error with status code: \(statusCode) and description: \(description)")
            throw APIError.responseUnsuccessful(description: description, statusCode: statusCode)
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    
    func responseFormat() -> JSONSchemaResponseFormat {
        let billSchema = JSONSchema(type: .object, properties: [
            "type": JSONSchema(type: .string),
            "amount": JSONSchema(type: .number)
        ],
                                    required: ["type", "amount"],
                                    additionalProperties: false
        )
        let responseFormat = JSONSchemaResponseFormat(name: "match_consume", strict: true, schema: billSchema)
        return responseFormat
    }
    
    func billResponseFormat() -> JSONSchemaResponseFormat {
        let billSchema = JSONSchema(type: .object, properties: [
            "type": JSONSchema(type: .string, enum: ConsumptionType.allCases.map(\.rawValue)),
            "amount": JSONSchema(type: .number)
        ],
                                    required: ["type", "amount"],
                                    additionalProperties: false
        )
        let responseFormat = JSONSchemaResponseFormat(name: "match_consume", strict: true, schema: billSchema)
        return responseFormat
    }
}
