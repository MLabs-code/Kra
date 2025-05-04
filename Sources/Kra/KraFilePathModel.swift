//
//  KraFilePathModel.swift
//  Kra
//
//  Created by MLabs on 04/05/2025.
//

import Foundation

public struct KraFilePathModel: Codable {
    public let msg: String?
    public let data: KraFilePathData?
    public let success: Int
    
    public var urlLink: URL? {
        URL(string: data?.link ?? "")
    }
}

// MARK: - DataClass
public struct KraFilePathData: Codable {
    public let link: String
}
