//
//  Endpoint.swift
//  CareTrack
//
//  Created by Mike Konapelsky on 9/15/26.
//

import Foundation

enum Endpoint: Equatable {
    case appointmentsAll
    case appointments(id: Int)
    case medications
    case profile
    
    private var baseUrl: String {
        Scheme.APP_BASE_URL
    }
    
    static var cachedEndpoints: [Endpoint] {
        [.appointmentsAll, .medications, .profile]
    }
    
    var path: String {
        switch self {
        case .appointmentsAll:
            return "\(baseUrl)/appointments"
        case .appointments(let id):
            return "\(baseUrl)/appointments/\(id)"
        case .medications:
            return "\(baseUrl)/medications"
        case .profile:
            return "\(baseUrl)/profile"
        }
    }
}

