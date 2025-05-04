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
    
    public var files: [FileInfo]? {
        if case .list(let fileList) = data {
            return fileList
        }
        return nil
    }
    
    public enum FileData: Codable {
        case single(KraFilePathData)
        case list([FileInfo])
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            // Najprv skúsime dekódovať ako zoznam, pretože podľa vášho výpisu to vyzerá ako pole
            do {
                let fileList = try container.decode([FileInfo].self)
                self = .list(fileList)
            } catch {
                // Ak to nefunguje, skúsime dekódovať ako jednotlivý súbor
                do {
                    let singleFile = try container.decode(KraFilePathData.self)
                    self = .single(singleFile)
                } catch let error as DecodingError {
                    // Spracovanie chyby dekódovania
                    switch error {
                    case .keyNotFound(let key, let context):
                        print("Kľúč \(key.stringValue) nebol nájdený: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("Očakávaný typ \(type) sa nezhoduje: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("Hodnota typu \(type) nebola nájdená: \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("Poškodené dáta: \(context.debugDescription)")
                    @unknown default:
                        print("Neznáma chyba dekódovania")
                    }
                } catch {
                    print("Iná chyba: \(error)")
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
