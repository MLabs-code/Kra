//
//  KraFilePathModel.swift
//  Kra
//
//  Created by MLabs on 04/05/2025.
//

import Foundation

public struct KraFilePathModel: Codable {
    let msg: String?
    let success: Int?
    let data: DataContainer

    public enum DataContainer: Codable {
        case single(KraFilePathData)
        case list([FileInfo])

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            // najprv skúsime dekódovať jediný objekt
            if let single = try? container.decode(KraFilePathData.self) {
                self = .single(single)
            } else {
                // ak to padne, dekódujeme pole
                let list = try container.decode([FileInfo].self)
                self = .list(list)
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .single(let obj):
                try container.encode(obj)
            case .list(let arr):
                try container.encode(arr)
            }
        }
    }

    /// Ak sa to dekódovalo ako single, vráti URL; inak nil
    public var urlLink: URL? {
        switch data {
        case .single(let d): return URL(string: d.link)
        case .list:        return nil
        }
    }
}

public struct KraFilePathData: Codable {
    let link: String
}

public struct FileInfo: Codable {
    let size: Int
    let name: String
    let shared: Bool
    let ident: String
    let folder: Bool
    let created: String
    let password: Bool
}
