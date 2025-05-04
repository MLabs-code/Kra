import Foundation
import XCTest
@testable import Kra

#if canImport(Combine)
import Combine
#endif

// MARK: - Mock Provider
class MockKraProvider: Provider<KraRequest> {
    var mockResponseData: Data?
    var mockError: Error?
    
    override func request(_ target: KraRequest, completion: @escaping (Result<Response, Error>) -> Void) {
        if let error = mockError {
            completion(.failure(error))
            return
        }
        
        if let data = mockResponseData {
            let response = Response(statusCode: 200, data: data)
            completion(.success(response))
            return
        }
        
        // Default mock responses based on the request type
        var responseData: Data
        
        switch target {
        case .login:
            responseData = MockResponse.loginSuccess
        case .userInfo:
            responseData = MockResponse.userInfoSuccess
        case .downloadFile:
            responseData = MockResponse.filePathSuccess
        case .listFiles:
            responseData = MockResponse.listFilesSuccess
        case .logout:
            responseData = MockResponse.logoutSuccess
        default:
            responseData = "{}".data(using: .utf8)!
        }
        
        let response = Response(statusCode: 200, data: responseData)
        completion(.success(response))
    }
}

// MARK: - Mock KraService for Dependency Injection

class MockKraService {
    // Track calls to methods
    var loginCalled = false
    var getUserInfoCalled = false
    var fileLinkCalled = false
    var listFilesCalled = false
    var logoutCalled = false
    
    // Parameters passed to methods
    var lastUsername: String?
    var lastPassword: String?
    var lastSessionId: String?
    var lastFileIdent: String?
    var lastFolderIdent: String?
    
    // Responses to return
    var loginResult: Result<String, Error>?
    var getUserInfoResult: Result<KraUserInfoModel, Error>?
    var fileLinkResult: Result<KraFilePathModel, Error>?
    var listFilesResult: Result<[KraFilePathModel], Error>?
    var logoutResult: Result<Bool, Error>?
}

extension MockKraService: KraServiceProtocol {
    func login(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        loginCalled = true
        lastUsername = username
        lastPassword = password
        
        if let result = loginResult {
            completion(result)
        } else {
            completion(.failure(NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No mock response provided"])))
        }
    }
    
    func getUserInfo(sessionId: String, completion: @escaping (Result<KraUserInfoModel, Error>) -> Void) {
        getUserInfoCalled = true
        lastSessionId = sessionId
        
        if let result = getUserInfoResult {
            completion(result)
        } else {
            completion(.failure(NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No mock response provided"])))
        }
    }
    
    func fileLink(sessionId: String, fileIdent: String, completion: @escaping (Result<KraFilePathModel, Error>) -> Void) {
        fileLinkCalled = true
        lastSessionId = sessionId
        lastFileIdent = fileIdent
        
        if let result = fileLinkResult {
            completion(result)
        } else {
            completion(.failure(NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No mock response provided"])))
        }
    }
    
    func listFiles(sessionId: String, folderIdent: String?, completion: @escaping (Result<[KraFilePathModel], Error>) -> Void) {
        listFilesCalled = true
        lastSessionId = sessionId
        lastFolderIdent = folderIdent
        
        if let result = listFilesResult {
            completion(result)
        } else {
            completion(.failure(NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No mock response provided"])))
        }
    }
    
    func logout(_ token: String, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        logoutCalled = true
        lastSessionId = token
        
        if let result = logoutResult {
            completion(result)
        } else {
            completion(.failure(NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No mock response provided"])))
        }
    }
    
    #if canImport(Combine) && compiler(>=5.1)
    @available(macOS 10.15, iOS 13.0, *)
    func logout(_ token: String) -> AnyPublisher<Bool, Error> {
        // This is needed just to satisfy the protocol - not actually used in tests
        return Fail(error: NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented"]))
            .eraseToAnyPublisher()
    }
    #endif
}

// MARK: - Helpers

extension XCTestCase {
    func createMockKraService() -> MockKraService {
        return MockKraService()
    }
    
    func createMockUserInfo() -> KraUserInfoModel {
        let data = KraUserInfoData(
            daysLeft: 30,
            objectQuota: 1000,
            bytesQuota: 1_073_741_824,
            mailing: true,
            username: "testuser",
            objects: 42,
            bytes: 8_388_608,
            email: "test@example.com",
            subscribedUntil: "2025-12-31"
        )
        
        return KraUserInfoModel(msg: nil, data: data, success: 1)
    }
    
    func createMockFilePath() -> KraFilePathModel {
        let data = KraFilePathData(link: "https://download.kra.sk/files/example.pdf")
        return KraFilePathModel(msg: nil, data: data, success: 1)
    }
    
    func createMockFilePathArray() -> [KraFilePathModel] {
        let data1 = KraFilePathData(link: "https://download.kra.sk/files/file1.pdf")
        let data2 = KraFilePathData(link: "https://download.kra.sk/files/file2.jpg")
        
        return [
            KraFilePathModel(msg: nil, data: data1, success: 1),
            KraFilePathModel(msg: nil, data: data2, success: 1)
        ]
    }
} 
