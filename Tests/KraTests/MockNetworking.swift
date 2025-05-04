import Foundation
import Kra
import XCTest

// MARK: - Mock Data
enum MockResponse {
    // Login responses
    static let loginSuccess = """
    {
        "session_id": "mock-session-id-123",
        "success": 1,
        "msg": "Login successful"
    }
    """.data(using: .utf8)!
    
    static let loginFailure = """
    {
        "session_id": null,
        "success": 0,
        "msg": "Invalid credentials"
    }
    """.data(using: .utf8)!
    
    // User info responses
    static let userInfoSuccess = """
    {
        "data": {
            "days_left": 30,
            "object_quota": 1000,
            "bytes_quota": 1073741824,
            "mailing": true,
            "username": "testuser",
            "objects": 42,
            "bytes": 8388608,
            "email": "test@example.com",
            "subscribed_until": "2025-12-31"
        },
        "success": 1,
        "msg": null
    }
    """.data(using: .utf8)!
    
    // File path responses
    static let filePathSuccess = """
    {
        "data": {
            "link": "https://download.kra.sk/files/example.pdf"
        },
        "success": 1,
        "msg": null
    }
    """.data(using: .utf8)!
    
    // List files responses
    static let listFilesSuccess = """
    {
        "data": [
            {
                "data": {
                    "link": "https://download.kra.sk/files/file1.pdf"
                },
                "success": 1,
                "msg": null
            },
            {
                "data": {
                    "link": "https://download.kra.sk/files/file2.jpg"
                },
                "success": 1,
                "msg": null
            }
        ],
        "success": 1,
        "msg": null
    }
    """.data(using: .utf8)!
    
    // Logout response
    static let logoutSuccess = """
    {
        "success": 1,
        "msg": "Logged out successfully"
    }
    """.data(using: .utf8)!
}

// MARK: - Mock URL Protocol
class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("Missing request handler")
            return
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
} 