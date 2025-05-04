import Foundation

#if canImport(Combine)
import Combine
#endif

// MARK: - Provider
class Provider<Target: TargetType> {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request(_ target: Target, completion: @escaping (Result<Response, Error>) -> Void) {
        guard let request = try? self.urlRequest(from: target) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            let response = Response(statusCode: httpResponse.statusCode, data: data ?? Data())
            completion(.success(response))
        }
        
        task.resume()
    }
    
    #if canImport(Combine) && compiler(>=5.1)
    @available(macOS 10.15, iOS 13.0, *)
    func requestData(request: Target) -> AnyPublisher<Data, Error> {
        guard let urlRequest = try? self.urlRequest(from: request) else {
            return Fail(error: NetworkError.invalidRequest).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    #endif
    
    private func urlRequest(from target: Target) throws -> URLRequest {
        let url = target.baseURL.appendingPathComponent(target.path)
        var request = URLRequest(url: url)
        request.httpMethod = target.method.rawValue
        request.allHTTPHeaderFields = target.headers
        request.cachePolicy = target.cachePolicy
        
        switch target.task {
        case .requestPlain:
            break
        case .requestParameters(let parameters, let encoding):
            try encoding.encode(request: &request, with: parameters)
        case .requestJSONEncodable(let encodable):
            let data = try JSONEncoder().encode(encodable)
            request.httpBody = data
        case .uploadMultipart(_):
            // Implementation for multipart would go here
            break
        }
        
        return request
    }
}

extension Provider {
    struct Response {
        let statusCode: Int
        let data: Data
    }
}

// MARK: - NetworkingClient
struct NetworkingClient {
    static func provider<T: TargetType>() -> Provider<T> {
        return Provider<T>()
    }
}

// MARK: - TargetType Protocol
protocol TargetType {
    var baseURL: URL { get }
    var path: String { get }
    var method: Method { get }
    var task: Task { get }
    var headers: [String: String]? { get }
    var cachePolicy: URLRequest.CachePolicy { get }
}

// MARK: - Cacheable Protocol
protocol Cacheable {
    var cachePolicy: URLRequest.CachePolicy { get }
}

// MARK: - Method Enum
enum Method: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case head = "HEAD"
    case patch = "PATCH"
}

// MARK: - Task Enum
enum Task {
    case requestPlain
    case requestParameters(parameters: [String: Any], encoding: ParameterEncoding)
    case requestJSONEncodable(Encodable)
    case uploadMultipart([MultipartFormData])
}

// MARK: - ParameterEncoding
protocol ParameterEncoding {
    func encode(request: inout URLRequest, with parameters: [String: Any]) throws
}

struct JSONEncoding: ParameterEncoding {
    static let `default` = JSONEncoding()
    
    func encode(request: inout URLRequest, with parameters: [String: Any]) throws {
        if parameters.isEmpty { return }
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data = try JSONSerialization.data(withJSONObject: parameters)
        request.httpBody = data
    }
}

// MARK: - MultipartFormData
struct MultipartFormData {
    let data: Data
    let name: String
    let fileName: String?
    let mimeType: String?
}

// MARK: - Errors
enum NetworkError: Error {
    case invalidRequest
    case invalidResponse
    case requestFailed
}

enum WSServiceError: Error {
    case unknownLogoutProblem
    case unknownError
}

// MARK: - MoyaError for compatibility
enum MoyaError: Error {
    case underlying(Error)
    case statusCode(Int)
    
    var response: Response? {
        return nil // Simplified implementation
    }
    
    struct Response {
        let statusCode: Int
    }
} 