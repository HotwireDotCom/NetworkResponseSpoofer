//
//  ReplayingProtocol.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 8/1/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

enum ReplayMethod {
    case StatusCodeAndHeader
    case MimeTypeAndEncoding
}

class ReplayingProtocol: NSURLProtocol, NetworkInterceptable {
    
    private var currentReplayMethod: ReplayMethod {
        // Customization: Switch the replay method according to the one which suits your specific requirement.
        return .StatusCodeAndHeader
    }
    
    override class func canInitWithRequest(request: NSURLRequest) -> Bool {
         guard let url = request.URL else { return false }
        
        // 1: Check the request's scheme. Only HTTP/HTTPS is supported right now
        let isHTTP = url.isHTTP
        // 2: Check if the request is to be handled or not based on a whitelist. If no whitelist is set all requests are handled
        let shouldHandleURL = Spoofer.shouldHandleURL(url)
        // 3: Check if we have a scenario loaded in memory
        let hasSavedScenario = (Spoofer.spoofedScenario != nil) ? true : false
        
        if Spoofer.isReplaying && isHTTP && shouldHandleURL && hasSavedScenario {
            return true
        }
        return false
    }
    
    override class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
        return request
    }
    
    override class func requestIsCacheEquivalent(aRequest: NSURLRequest, toRequest bRequest: NSURLRequest) -> Bool {
        // Let the super class handle it
        return super.requestIsCacheEquivalent(aRequest, toRequest:bRequest)
    }
    
    override func startLoading() {
        guard let url = request.URL else { return }
        
        guard let spoofedScenario = Spoofer.spoofedScenario, cachedResponse = spoofedScenario.responseForRequest(request) else {
            // Throw an error in case we are unable to load a response
            let httpError = handleError("No saved response found", recoveryMessage: "You might need to re-record the scenario", code: SpooferError.NoSavedResponseError.rawValue, url: url.absoluteString, errorHandler: nil)
            client?.URLProtocol(self, didFailWithError: httpError)
            return
        }
        
        var httpResponse: NSHTTPURLResponse?
        
        switch currentReplayMethod {
            case .StatusCodeAndHeader:
                let statusCode = (cachedResponse.statusCode >= 200) ? cachedResponse.statusCode : 200
                httpResponse = NSHTTPURLResponse(URL: cachedResponse.requestURL, statusCode: statusCode, HTTPVersion: "HTTP/1.1", headerFields: cachedResponse.headerFields as? [String : String])
            case .MimeTypeAndEncoding:
                httpResponse = NSHTTPURLResponse(URL: cachedResponse.requestURL, MIMEType: cachedResponse.mimeType, expectedContentLength: cachedResponse.expectedContentLength, textEncodingName: cachedResponse.encoding)
        }

        guard let spoofedResponse = httpResponse else {
            // Throw an error in case we are unable to serialize a response
            let httpError = handleError("No saved response found", recoveryMessage: "You might need to re-record the scenario", code: SpooferError.NoSavedResponseError.rawValue, url: url.absoluteString, errorHandler: nil)
            client?.URLProtocol(self, didFailWithError: httpError)
            return
        }
        
        postNotification("Serving response from cache for : \(request.URL?.absoluteString)", object: self)
        
        client?.URLProtocol(self, didReceiveResponse: spoofedResponse, cacheStoragePolicy: .NotAllowed)
        client?.URLProtocol(self, didLoadData: cachedResponse.data)
        client?.URLProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        // Nothing to do here for replay
    }
    
}