// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

/// Main entry point for the Kra API client
public class Kra {
    private let service: KraServiceProtocol
    
    /// Initialize the Kra API client
    public init(service: KraServiceProtocol? = nil) {
        self.service = service ?? KraService()
    }
    
    /// Login to the Kra service
    /// - Parameters:
    ///   - username: The username to login with
    ///   - password: The password to login with
    ///   - completion: A closure that returns a Result with either a session ID or an error
    public func login(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        service.login(username: username, password: password, completion: completion)
    }
    
    /// Gets information about the current user
    /// - Parameters:
    ///   - sessionId: The session ID obtained from login
    ///   - completion: A closure that returns a Result with either user info or an error
    public func getUserInfo(sessionId: String, completion: @escaping (Result<KraUserInfoModel, Error>) -> Void) {
        service.getUserInfo(sessionId: sessionId, completion: completion)
    }
    
    /// Get a download link for a file
    /// - Parameters:
    ///   - sessionId: The session ID obtained from login
    ///   - fileIdent: The file identifier
    ///   - completion: A closure that returns a Result with either file path info or an error
    public func fileLink(sessionId: String, fileIdent: String, completion: @escaping (Result<KraFilePathModel, Error>) -> Void) {
        service.fileLink(sessionId: sessionId, fileIdent: fileIdent, completion: completion)
    }
    
    /// List files in a folder
    /// - Parameters:
    ///   - sessionId: The session ID obtained from login
    ///   - folderIdent: Optional folder identifier. If nil, lists files in the root folder
    ///   - completion: A closure that returns a Result with either a list of files or an error
    public func listFiles(sessionId: String, folderIdent: String?, completion: @escaping (Result<[KraFilePathModel], Error>) -> Void) {
        service.listFiles(sessionId: sessionId, folderIdent: folderIdent, completion: completion)
    }
    
    /// Logout from the Kra service
    /// - Parameters:
    ///   - sessionId: The session ID to invalidate
    ///   - completion: A closure that returns a Result with either success or an error
    public func logout(sessionId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        service.logout(sessionId, completion)
    }
}
