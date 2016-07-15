//
//  Spoofer+Replay.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 11/11/15.
//  Copyright © 2015 Hotwire. All rights reserved.
//

import Foundation
import UIKit

public extension Spoofer {

    // MARK: - Replay

    /// Returns true if the Spoofer is replaying a scenario
    class var isReplaying: Bool {
        return sharedInstance.replaying
    }
    
    /**
     Show recorded scenarios in Documents folder as a list for the user to select and start replay (Replay selection UI)
     
     - parameter sourceViewController: The view controller from which to present the replay selection UI
     
     - Note: The replay selection UI also has few other roles.
        - It allows configuring the spoofer using a config button the nav bar, allowing to tweak whitelist/blacklist/query parameters, normalization etc
        - It shows the list of pre-recorded scenarios in the folder. Tapping a scenario starts replay directly and dismissed the UI
        - It allows diving deeper into the scenario by tapping the info button along the right of each scenario. This lists the url's which have recorded responses in the scenario.
     */
    class func showRecordedScenarios(inViewController sourceViewController: UIViewController?) {
        guard let sourceViewController = sourceViewController else { return }
        let scenarioListController = spooferStoryBoard().instantiateViewControllerWithIdentifier(ScenarioListController.identifier)
        sourceViewController.presentViewController(scenarioListController, animated: true, completion: nil)
    }
    
    /**
     Starts replaying a recorded scenario
     
     - parameter name: The name of the scenario to start replay.
     
     - Precondition: A scenario file with the specified name must exist on the Documents folder of the app
     
     - Returns: True if replay was started, else false
     */
    public class func startReplaying(scenarioName name: String?) -> Bool {
        
        guard let name = name else { return false }
        
        let protocolRegistered = ReplayingProtocol.startIntercept()
        Store.loadScenario(name, callback: { success, scenario in
            if success {
                setReplaying = true
                spoofedScenario = scenario
                // Inform the delegate that spoofer started replay
                Spoofer.delegate?.spooferDidStartReplaying(name, success: true)
                // Post a state change notification for interested parties
                NSNotificationCenter.defaultCenter().postNotificationName(spooferStartedReplayingNotification, object: sharedInstance, userInfo: ["scenario": name, "success": true])
            }
            }, errorHandler: { error in
                // Inform the delegate that spoofer could not start replay
                Spoofer.delegate?.spooferDidStartReplaying(name, success: false)
                // Post a state change notification for interested parties
                NSNotificationCenter.defaultCenter().postNotificationName(spooferStoppedReplayingNotification, object: sharedInstance)
        })
        return protocolRegistered
    }
    
    /**
     Stop replaying the current scenario
     */
    class func stopReplaying() {
        ReplayingProtocol.stopIntercept()
        setReplaying = false
        if let scenarioName = spoofedScenario?.name {
            // Inform the delegate that spoofer stopped replay
            Spoofer.delegate?.spooferDidStopReplaying(scenarioName)
            // Post a state change notification for interested parties
            NSNotificationCenter.defaultCenter().postNotificationName(spooferStoppedReplayingNotification, object: sharedInstance)
        }
        spoofedScenario = nil
    }
}
