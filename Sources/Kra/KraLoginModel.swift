//
//  KraLoginModel.swift
//  Kra
//
//  Created by MLabs on 04/05/2025.
//

import Foundation

public struct KraLoginModel: Codable {
    public let msg: String?
    public let sessionId: String?
    public let response: Int
    
    enum CodingKeys: String, CodingKey {
        case msg
        case sessionId = "session_id"
        case response = "success"
    }
}
