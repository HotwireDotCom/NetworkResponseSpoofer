//
//  Spoofer+Recording.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 11/11/15.
//  Copyright © 2015 Hotwire. All rights reserved.
//

import Foundation
import UIKit

extension Spoofer {
    
    // MARK: - Public methods
    
    public class var isRecording: Bool {
        return sharedInstance.recording
    }
    
    public class func startRecording(scenarioName name: String?) -> Bool {
        
        guard let name = name else { return false }
        
        let protocolRegistered = NSURLProtocol.registerClass(RecordingProtocol)
        
        if protocolRegistered {
            setRecording = true
            // Create a fresh scenario based on the named passed in
            spoofedScenario = Scenario(name: name)
            // Inform the delegate that spoofer started recording
            Spoofer.delegate?.spooferDidStartRecording(name)
            // Post a state change notification for interested parties
            NSNotificationCenter.defaultCenter().postNotificationName(spooferStartedRecordingNotification, object: sharedInstance)
        }
        return protocolRegistered
    }
    
    public class func startRecording(inViewController sourceViewController: UIViewController?) {
        
        guard let sourceViewController = sourceViewController else { return }
        
        // When a view controller was passed in, use it to display an alert controller asking for a scenario name
        let alertController = UIAlertController(title: "Create Scenario", message: "Enter a scenario name to save the requests & responses", preferredStyle: .Alert)

        let createAction = UIAlertAction(title: "Create", style: .Default) { [unowned alertController](_) in
            if let textField = alertController.textFields?.first, scenarioName = textField.text {
                startRecording(scenarioName: scenarioName)
            }
        }
        createAction.enabled = false

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in
            setRecording = false
            spoofedScenario = nil
            NSURLProtocol.unregisterClass(RecordingProtocol)
        }

        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Enter scenario name"
            textField.autocapitalizationType = .Sentences
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                createAction.enabled = textField.text != ""
            }
        }

        alertController.addAction(createAction)
        alertController.addAction(cancelAction)

        sourceViewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    public class func stopRecording() {
        NSURLProtocol.unregisterClass(RecordingProtocol)
        guard let scenario = sharedInstance.scenario else { return }
        Store.saveScenario(scenario, callback: { success, savedScenario in
            if success {
                setRecording = false
                spoofedScenario = nil
                guard let savedScenario = savedScenario else { return }
                // Inform the delegate of successful save
                Spoofer.delegate?.spooferDidStopRecording(savedScenario.name, success: true)
                NSNotificationCenter.defaultCenter().postNotificationName(spooferStoppedRecordingNotification, object: sharedInstance)
            }
            }, errorHandler: { error in
                if let scenarioName = spoofedScenario?.name {
                    // Inform the delegate that saving scenario failed
                    Spoofer.delegate?.spooferDidStopRecording(scenarioName, success: false)
                    // Post a state change notification for interested parties
                    NSNotificationCenter.defaultCenter().postNotificationName(spooferStoppedRecordingNotification, object: sharedInstance)
                    setRecording = false
                    spoofedScenario = nil
                }
        })
    }
    
}