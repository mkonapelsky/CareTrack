//
//  Scheme.swift
//  CareTrack
//
//  Created by Mike Konapelsky on 9/15/26.
//

import Foundation

class Sentinal: NSObject {}

public enum Scheme {
    
    enum Keys {
        enum Plist {
            static let APP_BASE_URL = "APP_BASE_URL"
            static let APP_VERSION = "CFBundleShortVersionString"
            static let BUILD_NUMBER = "CFBundleVersion"
        }
    }
    
    private static let infoDictionary: [String: Any] = {
        let activeBundle = Bundle(for: Sentinal.self)
        guard let dict = activeBundle.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    static let APP_BASE_URL: String = {
        guard let baseUrlString = Scheme.infoDictionary[Keys.Plist.APP_BASE_URL] as? String else {
            fatalError("APP_BASE_URL is invalid")
        }

        return baseUrlString
    }()
    
    static let APP_VERSION: String = {
        guard let apiKey = Scheme.infoDictionary[Keys.Plist.APP_VERSION] as? String else {
            fatalError("APP_VERSION is invalid")
        }

        return apiKey
    }()
    
    static let BUILD_NUMBER: String = {
        guard let apiKey = Scheme.infoDictionary[Keys.Plist.BUILD_NUMBER] as? String else {
            fatalError("APP_VERSION is invalid")
        }

        return apiKey
    }()

}
