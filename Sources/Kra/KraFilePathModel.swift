//
//  KraFilePathModel.swift
//  Kra
//
//  Created by MLabs on 04/05/2025.
//

import Foundation

public struct KraFilePathModel: Codable {
    public let msg: String?
    public let success: Int
    public let data: FileData
    
    public var urlLink: URL? {
        if case .single(let fileData) = data {
            return URL(string: fileData.link)
        }
        return nil
    }
    
    public enum FileData: Codable {
        case single(KraFilePathData)
        case list([FileInfo])
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            // Skúsime dekódovať ako jednotlivý súbor
            do {
                let singleFile = try container.decode(KraFilePathData.self)
                self = .single(singleFile)
                return
            } catch {
                // Ak to nefunguje, skúsime dekódovať ako zoznam
                do {
                    let fileList = try container.decode([FileInfo].self)
                    self = .list(fileList)
                    return
                } catch {
                    throw DecodingError.dataCorruptedError(
                        in: container,
                        debugDescription: "Data is neither a single file nor a file list"
                    )
                }
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            
            switch self {
            case .single(let fileData):
                try container.encode(fileData)
            case .list(let fileList):
                try container.encode(fileList)
            }
        }
    }
}

public struct KraFilePathData: Codable {
    public let link: String
}

public struct FileInfo: Codable {
    public let size: Int
    public let name: String
    public let shared: Bool
    public let ident: String
    public let folder: Bool
    public let created: String
    public let password: Bool
}
