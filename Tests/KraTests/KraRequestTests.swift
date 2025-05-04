import XCTest
@testable import Kra

final class KraRequestTests: XCTestCase {
    
    // MARK: - Base URL Tests
    
    func testBaseURLForStandardRequests() {
        // Given
        let loginRequest = KraRequest.login(username: "test", password: "pass")
        let listFilesRequest = KraRequest.listFiles(sessionId: "session", folderIdent: nil)
        let userInfoRequest = KraRequest.userInfo(sessionId: "session")
        
        // Then
        XCTAssertEqual(loginRequest.baseURL.absoluteString, "https://api.kra.sk/api")
        XCTAssertEqual(listFilesRequest.baseURL.absoluteString, "https://api.kra.sk/api")
        XCTAssertEqual(userInfoRequest.baseURL.absoluteString, "https://api.kra.sk/api")
    }
    
    func testBaseURLForUploadRequest() {
        // Given
        let uploadRequest = KraRequest.uploadFile(sessionId: "session", filename: "test.txt", folderIdent: nil, isShared: false, chunkMB: 5)
        
        // Then
        XCTAssertEqual(uploadRequest.baseURL.absoluteString, "https://upload.kra.sk")
    }
    
    // MARK: - Path Tests
    
    func testPathForEachRequest() {
        // Given
        let loginRequest = KraRequest.login(username: "test", password: "pass")
        let userInfoRequest = KraRequest.userInfo(sessionId: "session")
        let listFilesRequest = KraRequest.listFiles(sessionId: "session", folderIdent: nil)
        let downloadFileRequest = KraRequest.downloadFile(sessionId: "session", fileIdent: "file-id")
        let uploadRequest = KraRequest.uploadFile(sessionId: "session", filename: "test.txt", folderIdent: nil, isShared: false, chunkMB: 5)
        let createFolderRequest = KraRequest.createFolder(sessionId: "session", name: "New Folder", parentFolderIdent: nil, isShared: false)
        let deleteObjectRequest = KraRequest.deleteObject(sessionId: "session", objectIdent: "obj-id", recursive: true)
        let objectInfoRequest = KraRequest.objectInfo(sessionId: "session", objectIdent: "obj-id")
        let versionRequest = KraRequest.version
        let logoutRequest = KraRequest.logout(sessionId: "session")
        
        // Then
        XCTAssertEqual(loginRequest.path, "/user/login")
        XCTAssertEqual(userInfoRequest.path, "/user/info")
        XCTAssertEqual(listFilesRequest.path, "/file/list")
        XCTAssertEqual(downloadFileRequest.path, "/file/download")
        XCTAssertEqual(uploadRequest.path, "/upload/upload/")
        XCTAssertEqual(createFolderRequest.path, "/file/create")
        XCTAssertEqual(deleteObjectRequest.path, "/file/delete")
        XCTAssertEqual(objectInfoRequest.path, "/file/info")
        XCTAssertEqual(versionRequest.path, "/version")
        XCTAssertEqual(logoutRequest.path, "/user/logout")
    }
    
    // MARK: - Method Tests
    
    func testHTTPMethodForRequests() {
        // Given
        let loginRequest = KraRequest.login(username: "test", password: "pass")
        let uploadRequest = KraRequest.uploadFile(sessionId: "session", filename: "test.txt", folderIdent: nil, isShared: false, chunkMB: 5)
        
        // Then
        XCTAssertEqual(loginRequest.method.rawValue, "POST")
        XCTAssertEqual(uploadRequest.method.rawValue, "PATCH")
    }
    
    // MARK: - Headers Tests
    
    func testHeadersForStandardRequests() {
        // Given
        let loginRequest = KraRequest.login(username: "test", password: "pass")
        
        // Then
        XCTAssertEqual(loginRequest.headers?["Content-Type"], "application/json")
    }
    
    func testHeadersForUploadRequest() {
        // Given
        let uploadRequest = KraRequest.uploadFile(sessionId: "session", filename: "test.txt", folderIdent: nil, isShared: false, chunkMB: 5)
        
        // Then
        XCTAssertEqual(uploadRequest.headers?["Tus-Resumable"], "1.0.0")
        XCTAssertEqual(uploadRequest.headers?["Content-Type"], "application/offset+octet-stream")
    }
    
    // MARK: - Task Tests
    
    func testLoginTaskParameters() {
        // Given
        let request = KraRequest.login(username: "testuser", password: "testpass")
        
        // When
        guard case let .requestJSONEncodable(params) = request.task else {
            XCTFail("Expected requestJSONEncodable task")
            return
        }
        
        // Then - since we can't directly inspect the Encodable value, we'll encode it to verify
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(params)
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let dataDict = json?["data"] as? [String: String]
            
            XCTAssertEqual(dataDict?["username"], "testuser")
            XCTAssertEqual(dataDict?["password"], "testpass")
        } catch {
            XCTFail("Failed to encode login parameters: \(error)")
        }
    }
    
    func testUserInfoTaskParameters() {
        // Given
        let request = KraRequest.userInfo(sessionId: "test-session")
        
        // When
        guard case let .requestJSONEncodable(params) = request.task else {
            XCTFail("Expected requestJSONEncodable task")
            return
        }
        
        // Then
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(params)
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
            
            XCTAssertEqual(json?["session_id"], "test-session")
        } catch {
            XCTFail("Failed to encode user info parameters: \(error)")
        }
    }
    
    func testCreateFolderTaskParameters() {
        // Given
        let request = KraRequest.createFolder(
            sessionId: "test-session",
            name: "Test Folder",
            parentFolderIdent: "parent-id",
            isShared: true
        )
        
        // When
        guard case let .requestParameters(parameters, encoding) = request.task else {
            XCTFail("Expected requestParameters task")
            return
        }
        
        // Then
        XCTAssertTrue(encoding is JSONEncoding)
        XCTAssertEqual(parameters["session_id"] as? String, "test-session")
        
        guard let data = parameters["data"] as? [String: Any] else {
            XCTFail("Expected data dictionary")
            return
        }
        
        XCTAssertEqual(data["name"] as? String, "Test Folder")
        XCTAssertEqual(data["parent"] as? String, "parent-id")
        XCTAssertEqual(data["shared"] as? Bool, true)
        XCTAssertEqual(data["folder"] as? Bool, true)
    }
} 