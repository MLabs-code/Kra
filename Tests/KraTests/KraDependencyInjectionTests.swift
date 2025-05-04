import XCTest
import Kra

/// Tests the Kra class with a mock service through dependency injection
final class KraDependencyInjectionTests: XCTestCase {
    var mockService: MockKraService!
    var sut: Kra!
    
    override func setUp() {
        super.setUp()
        mockService = createMockKraService()
        sut = Kra(service: mockService)
    }
    
    override func tearDown() {
        mockService = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Login Tests
    
    func testLoginCallsService() {
        // Given
        let expectation = expectation(description: "Login calls service")
        mockService.loginResult = .success("test-session-id")
        
        // When
        sut.login(username: "testuser", password: "testpass") { result in
            // Then
            XCTAssertTrue(self.mockService.loginCalled)
            XCTAssertEqual(self.mockService.lastUsername, "testuser")
            XCTAssertEqual(self.mockService.lastPassword, "testpass")
            
            if case .success(let sessionId) = result {
                XCTAssertEqual(sessionId, "test-session-id")
            } else {
                XCTFail("Expected success result")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - User Info Tests
    
    func testGetUserInfoCallsService() {
        // Given
        let expectation = expectation(description: "Get user info calls service")
        let mockUserInfo = createMockUserInfo()
        mockService.getUserInfoResult = .success(mockUserInfo)
        
        // When
        sut.getUserInfo(sessionId: "test-session-id") { result in
            // Then
            XCTAssertTrue(self.mockService.getUserInfoCalled)
            XCTAssertEqual(self.mockService.lastSessionId, "test-session-id")
            
            if case .success(let userInfo) = result {
                XCTAssertEqual(userInfo.data.username, "testuser")
                XCTAssertEqual(userInfo.data.email, "test@example.com")
            } else {
                XCTFail("Expected success result")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - File Link Tests
    
    func testFileLinkCallsService() {
        // Given
        let expectation = expectation(description: "File link calls service")
        let mockFilePath = createMockFilePath()
        mockService.fileLinkResult = .success(mockFilePath)
        
        // When
        sut.fileLink(sessionId: "test-session-id", fileIdent: "file-id") { result in
            // Then
            XCTAssertTrue(self.mockService.fileLinkCalled)
            XCTAssertEqual(self.mockService.lastSessionId, "test-session-id")
            XCTAssertEqual(self.mockService.lastFileIdent, "file-id")
            
            if case .success(let filePath) = result {
                XCTAssertEqual(filePath.data?.link, "https://download.kra.sk/files/example.pdf")
            } else {
                XCTFail("Expected success result")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - List Files Tests
    
    func testListFilesCallsService() {
        // Given
        let expectation = expectation(description: "List files calls service")
        let mockFiles = createMockFilePathArray()
        mockService.listFilesResult = .success(mockFiles)
        
        // When
        sut.listFiles(sessionId: "test-session-id", folderIdent: "folder-id") { result in
            // Then
            XCTAssertTrue(self.mockService.listFilesCalled)
            XCTAssertEqual(self.mockService.lastSessionId, "test-session-id")
            XCTAssertEqual(self.mockService.lastFolderIdent, "folder-id")
            
            if case .success(let files) = result {
                XCTAssertEqual(files.count, 2)
                XCTAssertEqual(files[0].data?.link, "https://download.kra.sk/files/file1.pdf")
                XCTAssertEqual(files[1].data?.link, "https://download.kra.sk/files/file2.jpg")
            } else {
                XCTFail("Expected success result")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Logout Tests
    
    func testLogoutCallsService() {
        // Given
        let expectation = expectation(description: "Logout calls service")
        mockService.logoutResult = .success(true)
        
        // When
        sut.logout(sessionId: "test-session-id") { result in
            // Then
            XCTAssertTrue(self.mockService.logoutCalled)
            XCTAssertEqual(self.mockService.lastSessionId, "test-session-id")
            
            if case .success(let success) = result {
                XCTAssertTrue(success)
            } else {
                XCTFail("Expected success result")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandling() {
        // Given
        let expectation = expectation(description: "Error is propagated")
        let testError = NSError(domain: "TestDomain", code: 100, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        mockService.loginResult = .failure(testError)
        
        // When
        sut.login(username: "testuser", password: "testpass") { result in
            // Then
            if case .failure(let error) = result,
               let nsError = error as NSError? {
                XCTAssertEqual(nsError.domain, "TestDomain")
                XCTAssertEqual(nsError.code, 100)
                XCTAssertEqual(nsError.localizedDescription, "Test error")
                expectation.fulfill()
            } else {
                XCTFail("Expected failure result with specific error")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
} 