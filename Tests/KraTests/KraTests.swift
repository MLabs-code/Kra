import XCTest
@testable import Kra

final class KraTests: XCTestCase {
    var sut: Kra!
    var mockProvider: MockKraProvider!
    
    override func setUp() {
        super.setUp()
        // Create a mock provider and inject it through a custom KraService
        mockProvider = MockKraProvider()
        let service = KraService(provider: mockProvider)
        sut = Kra(service: service)
    }
    
    override func tearDown() {
        mockProvider = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Login Tests
    
    func testLoginSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Login successful")
        mockProvider.mockResponseData = MockResponse.loginSuccess
        
        // When
        sut.login(username: "testuser", password: "password") { result in
            // Then
            switch result {
            case .success(let sessionId):
                XCTAssertEqual(sessionId, "mock-session-id-123")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success but got error: \(error.localizedDescription)")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoginFailure() {
        // Given
        let expectation = XCTestExpectation(description: "Login failure")
        mockProvider.mockResponseData = MockResponse.loginFailure
        
        // When
        sut.login(username: "testuser", password: "wrongpassword") { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertTrue(error.localizedDescription.contains("Invalid credentials"))
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - User Info Tests
    
    func testGetUserInfoSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Get user info successful")
        mockProvider.mockResponseData = MockResponse.userInfoSuccess
        
        // When
        sut.getUserInfo(sessionId: "mock-session-id") { result in
            // Then
            switch result {
            case .success(let userInfo):
                XCTAssertEqual(userInfo.data.username, "testuser")
                XCTAssertEqual(userInfo.data.email, "test@example.com")
                XCTAssertEqual(userInfo.data.daysLeft, 30)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success but got error: \(error.localizedDescription)")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - File Link Tests
    
    func testFileLinkSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Get file link successful")
        mockProvider.mockResponseData = MockResponse.filePathSuccess
        
        // When
        sut.fileLink(sessionId: "mock-session-id", fileIdent: "file-123") { result in
            // Then
            switch result {
            case .success(let filePath):
                XCTAssertEqual(filePath.urlLink?.absoluteString, "https://download.kra.sk/files/example.pdf")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success but got error: \(error.localizedDescription)")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - List Files Tests
    
    func testListFilesSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "List files successful")
        mockProvider.mockResponseData = MockResponse.listFilesSuccess
        
        // When
        sut.listFiles(sessionId: "mock-session-id", folderIdent: nil) { result in
            // Then
            switch result {
            case .success(let files):
                XCTAssertEqual(files.count, 2)
                XCTAssertEqual(files[0].data?.link, "https://download.kra.sk/files/file1.pdf")
                XCTAssertEqual(files[1].data?.link, "https://download.kra.sk/files/file2.jpg")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success but got error: \(error.localizedDescription)")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Logout Tests
    
    func testLogoutSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Logout successful")
        mockProvider.mockResponseData = MockResponse.logoutSuccess
        
        // When
        sut.logout(sessionId: "mock-session-id") { result in
            // Then
            switch result {
            case .success(let success):
                XCTAssertTrue(success)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success but got error: \(error.localizedDescription)")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Error Tests
    
    func testNetworkError() {
        // Given
        let expectation = XCTestExpectation(description: "Handle network error")
        let testError = NSError(domain: "NetworkError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Network connection lost"])
        mockProvider.mockError = testError
        
        // When
        sut.login(username: "testuser", password: "password") { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                let nsError = error as NSError
                XCTAssertEqual(nsError.domain, "NetworkError")
                XCTAssertEqual(nsError.code, 1001)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
} 