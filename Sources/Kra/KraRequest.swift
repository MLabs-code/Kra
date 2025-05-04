//
//  KraRequest.swift
//  Kra
//
//  Created by MLabs on 04/05/2025.
//


import Foundation

// MARK: - Provider Factory
class KraProviderFactory {
    static let shared = KraProviderFactory()
    
    // Use lazy initialization to create the provider only when needed
    lazy var kraProvider: Provider<KraRequest> = {
        return NetworkingClient.provider()
    }()
    
    private init() {}
}

enum KraRequest {
    // User Authentication
    case login(username: String, password: String)
    case userInfo(sessionId: String)
    case logout(sessionId: String)
    
    // File Operations
    case listFiles(sessionId: String, folderIdent: String?)
    case downloadFile(sessionId: String, fileIdent: String)
    case uploadFile(sessionId: String, filename: String, folderIdent: String?, isShared: Bool, chunkMB: Int)
    case createFolder(sessionId: String, name: String, parentFolderIdent: String?, isShared: Bool)
    case deleteObject(sessionId: String, objectIdent: String, recursive: Bool)
    case objectInfo(sessionId: String, objectIdent: String)
    
    // Version
    case version
}

extension KraRequest: TargetType, Cacheable {
    var baseURL: URL {
        switch self {
        case .uploadFile:
            return URL(string: "https://upload.kra.sk")!
        default:
            return URL(string: "https://api.kra.sk/api")!
        }
    }
    
    var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringLocalCacheData
    }
    
    var path: String {
        switch self {
        case .login:
            return "/user/login"
        case .userInfo:
            return "/user/info"
        case .listFiles:
            return "/file/list"
        case .downloadFile:
            return "/file/download"
        case .uploadFile:
            return "/upload/upload/"
        case .createFolder:
            return "/file/create"
        case .deleteObject:
            return "/file/delete"
        case .objectInfo:
            return "/file/info"
        case .version:
            return "/version"
        case .logout:
            return "/user/logout"
        }
    }
    
    var method: Method {
        switch self {
        case .login, .userInfo, .listFiles, .downloadFile, .createFolder, .deleteObject, .objectInfo, .version, .logout:
            return .post
        case .uploadFile:
            return .patch
        }
    }
    
    var task: Task {
        switch self {
        case .login(let username, let password):
            let parameters: [String: [String:String]] = [
                "data": [
                    "username": username,
                    "password": password
                ]
            ]
            return .requestJSONEncodable(parameters)
            
        case .userInfo(let sessionId):
            let parameters = ["session_id":sessionId]
            return .requestJSONEncodable(parameters)
            
        case .listFiles(let sessionId, let folderIdent):
            var parameters: [String:Any] = ["session_id":sessionId]
            if let folderIdent {
                parameters["data"] = ["ident": folderIdent]
            }
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .downloadFile(let sessionId, let fileIdent):
            let parameters: [String:Any] = ["session_id":sessionId, "data" : ["ident": fileIdent]]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .uploadFile:
            // Upload functionality is not fully implemented yet
            fatalError("Upload functionality not implemented")
            
        case .createFolder(let sessionId, let name, let parentFolderIdent, let isShared):
            var data: [String: Any] = [
                "name": name,
                "folder": true,
                "shared": isShared
            ]
            if let parent = parentFolderIdent {
                data["parent"] = parent
            }
            let parameters: [String:Any] = ["session_id":sessionId, "data" : data]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .deleteObject(let sessionId, let objectIdent, let recursive):
            var data: [String: Any] = [
                "ident": objectIdent
            ]
            if recursive {
                data["recursive"] = true
            }
            let parameters: [String: Any] = ["session_id":sessionId, "data" : data]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .objectInfo(let sessionId, let objectIdent):
            let data = ["ident": objectIdent]
            let parameters: [String:Any] = ["session_id":sessionId, "data" : data]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .version:
            return .requestPlain
        case .logout(let sessionId):
            let parameters = ["session_id": sessionId]
            return .requestJSONEncodable(parameters)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .uploadFile:
            return [
                "Tus-Resumable": "1.0.0",
                "Content-Type": "application/offset+octet-stream"
            ]
        default:
            return [
                "Content-Type": "application/json"
            ]
        }
    }
    
    var sampleData: Data {
        // Poskytnite vzorové dáta pre testovanie
        return Data()
    }
}
