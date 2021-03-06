//
//  NetworkInterceptable.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 6/28/16.
//  Copyright (c) 2016 Hotwire. All rights reserved.
//

import Foundation

/// Protocol to be adopted by NSURLProtocol adopters to simplify the intercept setup process
public protocol NetworkInterceptable: AnyObject {
    static func startIntercept() -> Bool
    static func stopIntercept()
}

public extension NetworkInterceptable {
    static func startIntercept() -> Bool {
        let protocolRegistered = URLProtocol.registerClass(Self.self)
        // Swizzle will only happen once due to being a global closure
        URLSessionConfiguration.swizzleConfiguration()
        return protocolRegistered
    }

    static func stopIntercept() {
        URLProtocol.unregisterClass(Self.self)
    }
}
