//
//  URLExtension.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 8/3/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

extension NSURL {
    
    // MARK: - Private properties
    private var allQueryItems: [NSURLQueryItem]? {
        guard let components = NSURLComponents(URL: self, resolvingAgainstBaseURL: false) else { return nil }
        guard let queryItems = components.queryItems else { return nil }
        return queryItems
    }
    
    private var normalizedQueryItemNames: String? {
        guard let queryItems = allQueryItems else { return nil }
        // Normalization strips the values from query paramaters and only uses query item names (also filter ignored params)
        let allQueryItemsNames = queryItems.map{ $0.name }.filter{ element in
            !Spoofer.queryParametersToIgnore.contains(element)
        }
        let normalizedNames = "?" + allQueryItemsNames.joinWithSeparator("&")
        return normalizedNames
    }
    
    // MARKPublic properties
    var normalizedURLString: String? {
        // If the host is empty, take an early exit
        guard var normalizedString = self.host else { return nil }
        
        if normalizedString.hasPrefix("www.") {
            let wwwIndex = normalizedString.startIndex.advancedBy(4)
            normalizedString = normalizedString.substringFromIndex(wwwIndex)
        }
        
        // Remove sub domains which are to be ignored from the host name part. e.g. DEV, QA, PREPROD etc
        for subDomainToIgnore in Spoofer.subDomainsToIgnore {
            if let ignoredRange = normalizedString.rangeOfString(subDomainToIgnore + ".") {
                normalizedString.removeRange(ignoredRange)
            }
            if let ignoredRange = normalizedString.rangeOfString(subDomainToIgnore) {
                normalizedString.removeRange(ignoredRange)
            }
        }
        
        // Append the path
        if let pathString = self.path {
            normalizedString += pathString
        }
        
        // Normalize and append query parameter names (ignore values)
        if let queryItemNames = self.normalizedQueryItemNames {
            normalizedString += queryItemNames
        }
        
        return normalizedString
    }
    
    var isHTTP: Bool {
        return ["http","https"].contains(self.scheme)
    }
    
}
