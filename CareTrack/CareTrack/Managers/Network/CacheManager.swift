//
//  CacheManager.swift
//  CareTrack
//
//  Created by Mike Konapelsky on 9/15/26.
//

import Foundation

class CacheManager {
    static let shared = CacheManager()
    private let urlCache = URLCache.shared
    
    func store(request: URLRequest, response: URLResponse, data: Data) {
        let cachedData = CachedURLResponse(response: response, data: data)
        urlCache.storeCachedResponse(cachedData, for: request)
    }
    
    func retrieve<T: Decodable>(for request: URLRequest, as type: T.Type) async throws -> T {
        guard
            let data = urlCache.cachedResponse(for: request)?.data,
            let type = try? JSONDecoder().decode(type, from: data)
        else {
            throw AppError.Network(type: .general, errorString: "Unable to retrieve cached data for \(request.url?.absoluteString ?? "url")")
        }
        
        return type
    }
    
    func purge() {
        urlCache.removeAllCachedResponses()
    }
    
    func clearCache(for request: URLRequest) {
        urlCache.removeCachedResponse(for: request)
    }
}

// MARK: GET/SET Last Cache Date
extension CacheManager {
    func setCacheData(for endpoint: Endpoint) {
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: endpoint.path)
    }
    
    func getCacheDate(for endpoint: Endpoint) -> Date {
        Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: endpoint.path))
    }
}
