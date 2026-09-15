//
//  AppError.swift
//  CareTrack
//
//  Created by Mike Konapelsky on 9/15/26.
//

import Foundation

enum AppError {
    struct Network: Error {
        enum ErrorType {
            case general
            case invalidURL
            case invalidResponse
            case serverError
            case unableToDecode
            case badRequest
            case notFound
            case updateRequired
            case accountExists
        }
        
        let type: ErrorType
        var code: Int? = nil
        var response: HTTPURLResponse?
        var data: Data?
        var errorString: String?
    }
}
