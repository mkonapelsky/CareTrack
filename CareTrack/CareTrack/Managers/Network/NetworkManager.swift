//
//  NetworkManager.swift
//  CareTrack
//
//  Created by Mike Konapelsky on 9/15/26.
//

import Foundation
import OSLog

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

struct Empty200Response: Codable {}

class NetworkManager: NSObject {
    
    // Sends a network request using "standard" headers defined below. Includes cache options, returns a parsed generic type from response
    static func send<T: Decodable>(request: URLRequest,
                                  method: HTTPMethod,
                                  customHeaders: [String: String]? = nil,
                                  params: [String: Any]? = nil,
                                  body: Data? = nil,
                                  asObject type: T.Type = T.self,
                                  useCache _: Bool = false) async -> Result<T, AppError.Network>
    {
        // Append request
        var req = request
        req.httpMethod = method.rawValue
        req.timeoutInterval = 15
        req.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData // For the sake of this demo, ignore server cache rules to use our own (even though we're going to be using entirely mock data.... -.-)
        
        // Does this request use headers?
        if let customHeaders = customHeaders {
            for header in customHeaders {
                req.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
        do {
            
            // This wouldn't be great in production, but works in a pinch for demo purposes. Assumption for this demo is that either a dictionaty representation OR serialized data will be passed in and set as the body
            if let params {
                req.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            }
            
            if let body = body {
                if method != .GET {
                    req.httpBody = body
                }
            }
            
            let configuration = URLSessionConfiguration.ephemeral // Use our own custom caching mechanism for demo purposes only
            
            // Execute
            let (data, response) = try await URLSession(configuration: configuration).data(for: req)
            
            // Process response
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(AppError.Network(type: .invalidResponse, code: -1, response: nil, data: data, errorString: "Invalid Response"))
            }
            
            switch httpResponse.statusCode {
            case 200:
                
                // Cache if setup
                CacheManager.shared.store(request: req, response: response, data: data)
                
                if type.self == Empty200Response.self {
                    return .success(Empty200Response() as! T)
                } else {
                    
                    do {
                        return try .success(JSONDecoder().decode(type, from: data)) // This is the magic of this function. We tell it what we expect the route to return and it spits out our parsed local model. Completely reusable
                        
                    } catch {
                        return .failure(AppError.Network(type: .unableToDecode, data: data, errorString: "Unable to decode JSON: \(error.localizedDescription)"))
                    }
                }
                
            case 400:
                return .failure(AppError.Network(type: .badRequest, code: 400, response: httpResponse, data: data, errorString: "Bad Request"))
                
            case 500:
                return .failure(AppError.Network(type: .serverError, code: 500, response: httpResponse, data: data, errorString: "Server Error"))

            default:
                return .failure(AppError.Network(type: .general, code: httpResponse.statusCode, response: httpResponse, data: data, errorString: "Invalid Status Code"))
            }
            
        } catch {
            return .failure(AppError.Network(type: .general, errorString: error.localizedDescription))
        }
        
    }
}
