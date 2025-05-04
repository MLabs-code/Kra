//
//  KraFilePathModel.swift
//  Kra
//
//  Created by MLabs on 04/05/2025.
//

import Foundation

public struct KraFilePathModel: Codable {
    let msg: String?
    let data: KraFilePathData?
    let success: Int
    
    var urlLink: URL? {
        URL(string: data?.link ?? "")
    }
}

public struct KraFilePathData: Codable {
    let link: String
}

public struct KraFilesModel: Codable {
    let msg: String?
    let success: Int
    let data: [KraFile]
}

public struct KraFile: Codable {
    let size: Int
    let name: String
    let shared: Bool
    let ident: String
    let folder: Bool
    let created: String
    let password: Bool
}
