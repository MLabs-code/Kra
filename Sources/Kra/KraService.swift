//
//  KraService.swift
//  Kra
//
//  Created by MLabs on 04/05/2025.
//


import Foundation
#if canImport(Combine) && compiler(>=5.1)
import Combine
#endif

public protocol KraServiceProtocol {
    func login(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void)
    func getUserInfo(sessionId: String, completion: @escaping (Result<KraUserInfoModel, Error>) -> Void)
    func fileLink(sessionId: String, fileIdent: String, completion: @escaping (Result<KraFilePathModel, Error>) -> Void)
    func listFiles(sessionId: String, folderIdent: String?, completion: @escaping (Result<[KraFilePathModel], Error>) -> Void)
    func logout(_ token: String, _ completion: @escaping (Result<Bool, Error>) -> Void)
    
    #if canImport(Combine) && compiler(>=5.1)
    @available(macOS 10.15, iOS 13.0, *)
    func logout(_ token: String) -> AnyPublisher<Bool, Error>
    #endif
}

final class KraService: KraServiceProtocol {
    private let provider: Provider<KraRequest>
    
    var onLoginNeeded: (() -> Void)?
    
    init(provider: Provider<KraRequest>? = nil) {
        self.provider = provider ?? KraProviderFactory.shared.kraProvider
    }

    #if canImport(Combine) && compiler(>=5.1)
    @available(macOS 10.15, iOS 13.0, *)
    func logout(_ token: String) -> AnyPublisher<Bool, Error> {
        return provider
            .requestData(request: .logout(sessionId: token))
            .tryMap { _ -> Bool in
                   return true
            }
            .eraseToAnyPublisher()
    }
    #endif
    
    // Non-Combine version of logout for older platforms
    func logout(_ token: String, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        provider.request(.logout(sessionId: token)) { result in
            switch result {
            case .success(_):
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func login(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        provider.request(.login(username: username, password: password)) { result in
            switch result {
            case .success(let response):
                do {
                    let loginResponse = try JSONDecoder().decode(KraLoginModel.self, from: response.data)
                    if let sessionId = loginResponse.sessionId {
                        completion(.success((sessionId)))
                    } else if let errorMsg = loginResponse.msg {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMsg])))
                    } else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
                    }
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    @available(macOS 10.15, iOS 13.0, *)
    func loginAsync(username: String?, password: String?) async throws -> String {
        guard let username, let password else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Username and password are required"])
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.login(username: username, password: password) { result in
                switch result {
                case .success(let sessionId):
                    continuation.resume(returning: sessionId)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getUserInfo(sessionId: String, completion: @escaping (Result<KraUserInfoModel, Error>) -> Void) {
        provider.request(.userInfo(sessionId: sessionId)) { result in
            switch result {
            case .success(let response):
                do {
                    let userInfoResponse = try JSONDecoder().decode(KraUserInfoModel.self, from: response.data)
                    completion(.success(userInfoResponse))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    @available(macOS 10.15, iOS 13.0, *)
    func getUserInfoAsync(sessionId: String) async throws -> KraUserInfoModel {
        return try await withCheckedThrowingContinuation { continuation in
            getUserInfo(sessionId: sessionId) { result in
                switch result {
                case .success(let userInfo):
                    continuation.resume(returning: userInfo)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    @available(macOS 10.15, iOS 13.0, *)
    func fileLinkAsync(sessionId: String,
                       fileIdent: String) async throws -> KraFilePathModel {
        return try await withCheckedThrowingContinuation { continuation in
            fileLink(sessionId: sessionId,
                     fileIdent: fileIdent) { result in
                switch result {
                case .success(let fileInfo):
                    continuation.resume(returning: fileInfo)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func fileLink(sessionId: String,
                  fileIdent: String,
                  completion: @escaping (Result<KraFilePathModel, Error>) -> Void) {
        
        provider.request(.downloadFile(sessionId: sessionId, fileIdent: fileIdent)) { result in
            switch result {
            case .success(let response):
                do {
                    let fileResponse = try JSONDecoder().decode(KraFilePathModel.self, from: response.data)
                    completion(.success(fileResponse))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    @available(macOS 10.15, iOS 13.0, *)
    func listFilesAsync(sessionId: String,
                        folderIdent: String?) async throws -> [KraFilePathModel]
    {
        return try await withCheckedThrowingContinuation { continuation in
            listFiles(sessionId: sessionId, folderIdent: folderIdent) { result in
                switch result {
                case .success(let files):
                    continuation.resume(returning: files)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func listFiles(sessionId: String,
                   folderIdent: String?,
                   completion: @escaping (Result<[KraFilePathModel], Error>) -> Void)
    {
        provider.request(.listFiles(sessionId: sessionId, folderIdent: folderIdent)) { result in
            switch result {
            case .success(let response):
                do {
                    // Manual JSON parsing since we need to extract array from a dictionary structure
                    guard let jsonObject = try JSONSerialization.jsonObject(with: response.data) as? [String: Any],
                          let success = jsonObject["success"] as? Int, (success == 1 || success == 2011 || success == 201) else {
                        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    }
                    
                    // Check for error message list retrieved
                    if let errorMsg = jsonObject["msg"] as? String, (errorMsg != "list retrieved" || !errorMsg.isEmpty) {
                        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMsg])
                    }
                    
                    // Extract the array of file data
                    guard let filesData = jsonObject["data"] as? [[String: Any]] else {
                        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing data array"])
                    }
                    
                    // Convert each file dictionary into a KraFilePathModel
                    var files: [KraFilePathModel] = []
                    for fileDict in filesData {
                        let fileData = try JSONSerialization.data(withJSONObject: fileDict)
                        let fileModel = try JSONDecoder().decode(KraFilePathModel.self, from: fileData)
                        files.append(fileModel)
                    }
                    
                    completion(.success(files))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
