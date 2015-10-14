//
//  Utility.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 10/11/15.
//  Copyright © 2015 Hotwire. All rights reserved.
//

import Foundation

func logFormattedSeperator(message: String? = "-") {
    guard let message = message else { return }
    // Print "-" character before and after the message, 100 character total. Just logging every important message nicely.
    let messageStart = 50 - (message.characters.count / 2)
    if messageStart > 0 {
        let hyphen = Character("-")
        let hyphenString = String(count: messageStart, repeatedValue: hyphen)
        print("\(hyphenString)\(message)\(hyphenString)")
    } else {
        print("Message too long for formatting: \(message)")
    }
}

func spooferStoryBoard() -> UIStoryboard {
    let frameworkBundle = NSBundle(identifier: "com.hotwire.apiresponsespoofer")
    let storyBoard = UIStoryboard(name: "Spoofer", bundle: frameworkBundle)
    return storyBoard
}

func handleError(reason: String, recoveryMessage: String, code: Int, url: String? = nil, errorHandler: ((error: NSError) -> Void)?) -> NSError {
    var userInfo = [NSLocalizedFailureReasonErrorKey : reason, NSLocalizedRecoverySuggestionErrorKey: recoveryMessage]
    if let url = url {
        userInfo[NSURLErrorFailingURLErrorKey] = url
    }
    let spooferError = NSError(domain: "APIResponseSpoofer", code: code, userInfo: userInfo)
    errorHandler?(error: spooferError)
    return spooferError
}