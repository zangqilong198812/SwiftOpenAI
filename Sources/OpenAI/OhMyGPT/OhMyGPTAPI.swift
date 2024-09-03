//
//  LocalModelAPI.swift
//
//
//  Created by James Rochabrun on 6/30/24.
//

import Foundation

public enum OhMyGPTAPI {
   
   public static var overrideBaseURL: String = "https://aigptx.top"
   
   case chat
}

extension OhMyGPTAPI: Endpoint {
    
    var base: String {
       Self.overrideBaseURL
    }
   
   var path: String {
      switch self {
      case .chat: "/v1/chat/completions"
      }
   }
}
