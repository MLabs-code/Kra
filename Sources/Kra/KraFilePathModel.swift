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
            
            // Najprv skúsime dekódovať ako zoznam, pretože podľa výpisu to vyzerá ako pole
            do {
                let fileList = try container.decode([FileInfo].self)
                self = .list(fileList)
                return
            } catch {
                // Ak to nefunguje, skúsime dekódovať ako jednotlivý súbor
                do {
                    let singleFile = try container.decode(KraFilePathData.self)
                    self = .single(singleFile)
                    return
                } catch {
                    // Ak ani to nefunguje, vyhodíme chybu
                    throw DecodingError.dataCorruptedError(
                        in: container,
                        debugDescription: "Data is neither a single file nor a file list: \(error.localizedDescription)"
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
    
    // Vlastný inicializátor pre lepšie spracovanie chýb
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Dekódujeme základné vlastnosti
        msg = try container.decodeIfPresent(String.self, forKey: .msg)
        success = try container.decode(Int.self, forKey: .success)
        
        // Dekódujeme data podľa typu
        data = try container.decode(FileData.self, forKey: .data)
    }
    
    // Pomocná metóda pre vytvorenie modelu zo surových dát
    public static func decode(from data: Data) throws -> KraFilePathModel {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(KraFilePathModel.self, from: data)
        } catch {
            print("Chyba dekódovania KraFilePathModel: \(error)")
            throw error
        }
    }
    
    // Pomocná metóda pre ladenie
    public static func printJSON(_ data: Data) {
        if let jsonString = String(data: data, encoding: .utf8) {
            print("JSON: \(jsonString)")
        } else {
            print("Nepodarilo sa previesť dáta na reťazec")
        }
    }
}

public struct KraFilePathData: Codable {
    public let link: String
    
    // Pridané pre prípad, že API vráti ďalšie polia
    private enum CodingKeys: String, CodingKey {
        case link
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        link = try container.decode(String.self, forKey: .link)
    }
    
    public init(link: String) {
        self.link = link
    }
}

public struct FileInfo: Codable {
    public let size: Int
    public let name: String
    public let shared: Bool
    public let ident: String
    public let folder: Bool
    public let created: String
    public let password: Bool
    
    // Pridané pre prípad, že API vráti ďalšie polia
    private enum CodingKeys: String, CodingKey {
        case size, name, shared, ident, folder, created, password
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        size = try container.decode(Int.self, forKey: .size)
        name = try container.decode(String.self, forKey: .name)
        shared = try container.decode(Bool.self, forKey: .shared)
        ident = try container.decode(String.self, forKey: .ident)
        folder = try container.decode(Bool.self, forKey: .folder)
        created = try container.decode(String.self, forKey: .created)
        password = try container.decode(Bool.self, forKey: .password)
    }
    
    public init(size: Int, name: String, shared: Bool, ident: String, folder: Bool, created: String, password: Bool) {
        self.size = size
        self.name = name
        self.shared = shared
        self.ident = ident
        self.folder = folder
        self.created = created
        self.password = password
    }
}

// Rozšírenie pre jednoduchšie použitie
extension KraFilePathModel {
    // Získa prvý súbor zo zoznamu, ak existuje
    public var firstFile: FileInfo? {
        return files?.first
    }
    
    // Skontroluje, či odpoveď obsahuje zoznam súborov
    public var isListResponse: Bool {
        if case .list(_) = data {
            return true
        }
        return false
    }
    
    // Skontroluje, či odpoveď obsahuje jeden súbor
    public var isSingleFileResponse: Bool {
        if case .single(_) = data {
            return true
        }
        return false
    }
    
    // Vráti počet súborov v zozname alebo 0, ak nejde o zoznam
    public var fileCount: Int {
        return files?.count ?? 0
    }
    
    // Vráti identifikátor prvého súboru alebo nil
    public var firstFileIdent: String? {
        return firstFile?.ident
    }
}
