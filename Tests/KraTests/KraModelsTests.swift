import XCTest
import Kra

final class KraModelsTests: XCTestCase {
    
    // MARK: - KraLoginModel Tests
    
    func testKraLoginModelDecoding() throws {
        // Given
        let jsonData = MockResponse.loginSuccess
        
        // When
        let loginModel = try JSONDecoder().decode(KraLoginModel.self, from: jsonData)
        
        // Then
        XCTAssertEqual(loginModel.sessionId, "mock-session-id-123")
        XCTAssertEqual(loginModel.response, 1)
        XCTAssertEqual(loginModel.msg, "Login successful")
    }
    
    func testKraLoginModelDecodingFailure() throws {
        // Given
        let jsonData = MockResponse.loginFailure
        
        // When
        let loginModel = try JSONDecoder().decode(KraLoginModel.self, from: jsonData)
        
        // Then
        XCTAssertNil(loginModel.sessionId)
        XCTAssertEqual(loginModel.response, 0)
        XCTAssertEqual(loginModel.msg, "Invalid credentials")
    }
    
    // MARK: - KraUserInfoModel Tests
    
    func testKraUserInfoModelDecoding() throws {
        // Given
        let jsonData = MockResponse.userInfoSuccess
        
        // When
        let userInfoModel = try JSONDecoder().decode(KraUserInfoModel.self, from: jsonData)
        
        // Then
        XCTAssertEqual(userInfoModel.success, 1)
        XCTAssertNil(userInfoModel.msg)
        
        // Verify user info data
        XCTAssertEqual(userInfoModel.data.username, "testuser")
        XCTAssertEqual(userInfoModel.data.email, "test@example.com")
        XCTAssertEqual(userInfoModel.data.daysLeft, 30)
        XCTAssertEqual(userInfoModel.data.objectQuota, 1000)
        XCTAssertEqual(userInfoModel.data.bytesQuota, 1073741824)
        XCTAssertTrue(userInfoModel.data.mailing)
        XCTAssertEqual(userInfoModel.data.objects, 42)
        XCTAssertEqual(userInfoModel.data.bytes, 8388608)
        XCTAssertEqual(userInfoModel.data.subscribedUntil, "2025-12-31")
        
        // Test computed properties
        XCTAssertEqual(userInfoModel.data.vip_days, "30")
        XCTAssertFalse(userInfoModel.data.isNeedExpandSubscrition)
    }
    
    // MARK: - KraFilePathModel Tests
    
    func testKraFilePathModelDecoding() throws {
        // Given
        let jsonData = MockResponse.filePathSuccess
        
        // When
        let filePathModel = try JSONDecoder().decode(KraFilePathModel.self, from: jsonData)
        
        // Then
        XCTAssertEqual(filePathModel.success, 1)
        XCTAssertNil(filePathModel.msg)
        XCTAssertEqual(filePathModel.data?.link, "https://download.kra.sk/files/example.pdf")
        
        // Test computed property
        XCTAssertEqual(filePathModel.urlLink?.absoluteString, "https://download.kra.sk/files/example.pdf")
    }
    
    // MARK: - Edge Cases
    
    func testUserInfoWithNoDaysLeft() throws {
        // Given
        let json = """
        {
            "data": {
                "object_quota": 1000,
                "bytes_quota": 1073741824,
                "mailing": true,
                "username": "freeuser",
                "objects": 10,
                "bytes": 1048576,
                "email": "free@example.com",
                "subscribed_until": "2025-01-01"
            },
            "success": 1,
            "msg": null
        }
        """.data(using: .utf8)!
        
        // When
        let userInfoModel = try JSONDecoder().decode(KraUserInfoModel.self, from: json)
        
        // Then
        XCTAssertNil(userInfoModel.data.daysLeft)
        XCTAssertNil(userInfoModel.data.vip_days)
        XCTAssertTrue(userInfoModel.data.isNeedExpandSubscrition)
    }
} 