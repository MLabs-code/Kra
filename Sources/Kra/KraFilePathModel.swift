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

public struct KraFilePathData: Codable {
    public let link: String
}

public struct KraFilesModel: Codable {
    public let msg: String?
    public let success: Int
    public let data: [KraFile]
}

public struct KraFile: Codable {
    public let size: Int
    public let name: String
    public let shared: Bool
    public let ident: String
    public let folder: Bool
    public let created: String
    public let password: Bool
}
