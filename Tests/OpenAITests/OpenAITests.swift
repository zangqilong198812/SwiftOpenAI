import XCTest
@testable import SwiftOpenAI

final class OpenAITests: XCTestCase {

   // OpenAI is loose with their API contract, unfortunately.
   // Here we test that `tool_choice` is decodable from a string OR an object,
   // which is required for deserializing responses from assistants:
   // https://platform.openai.com/docs/api-reference/runs/createRun#runs-createrun-tool_choice
   func testToolChoiceIsDecodableFromStringOrObject() throws {
      let expectedResponseMappings: [(String, ToolChoice)] = [
         ("\"auto\"", .auto),
         ("\"none\"", .none),
         ("{\"type\": \"function\", \"function\": {\"name\": \"my_function\"}}", .function(type: "function", name: "my_function"))
      ]
      let decoder = JSONDecoder()
      for (response, expectedToolChoice) in expectedResponseMappings {
         print(response)
         guard let jsonData = response.data(using: .utf8) else {
            XCTFail("Could not create json from sample response")
            return
         }
         let toolChoice = try decoder.decode(ToolChoice.self, from: jsonData)
         XCTAssertEqual(toolChoice, expectedToolChoice, "Mapping from \(response) did not yield expected result")
      }
   }

   // Regression test for decoding assistant runs. Thank you to Martin Brian for the repro:
   // https://gist.github.com/mbrian23/6863ffa705ccbb5097bd07efb2355a30
   func testThreadRunResponseIsDecodable() throws {
      let response = """
        {
          "id": "run_ZWntP0jJr391lwVu3JqFZbKV",
          "object": "thread.run",
          "created_at": 1713979538,
          "assistant_id": "asst_qxhQxXsecIjqw9cBjFTB6yvd",
          "thread_id": "thread_CT4hxsN5N0A5vXg4FeR4pOPD",
          "status": "queued",
          "started_at": null,
          "expires_at": 1713980138,
          "cancelled_at": null,
          "failed_at": null,
          "completed_at": null,
          "required_action": null,
          "last_error": null,
          "model": "gpt-4-1106-preview",
          "instructions": "You answer ever question with ‘hello world’",
          "tools": [],
          "file_ids": [],
          "metadata": {},
          "temperature": 1.0,
          "top_p": 1.0,
          "max_completion_tokens": null,
          "max_prompt_tokens": null,
          "truncation_strategy": {
            "type": "auto",
            "last_messages": null
          },
          "incomplete_details": null,
          "usage": null,
          "response_format": "auto",
          "tool_choice": "auto"
        }
        """

      guard let jsonData = response.data(using: .utf8) else {
         XCTFail("Could not create json from sample response")
         return
      }
      let decoder = JSONDecoder()
      let runObject = try decoder.decode(RunObject.self, from: jsonData)
      XCTAssertEqual(runObject.id, "run_ZWntP0jJr391lwVu3JqFZbKV")
   }
}
