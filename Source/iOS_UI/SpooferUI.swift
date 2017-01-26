//
//  SpooferUI.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 11/14/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
import UIKit

public extension Spoofer {

    /**
     Starts recording a new scenario from a specific view controller.

     - parameter sourceViewController: The view controller from which the record popup UI will be presented from

     - Note: A popup will appear asking the user to name the scenario, before recording starts. Use this method if you need to manually provide the scenario name
     */
    class func startRecording(inViewController sourceViewController: UIViewController?) {
        presentController(with: RecordTableViewController.identifier, sourceViewController: sourceViewController)
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
        presentController(with: ScenarioListController.identifier, sourceViewController: sourceViewController)
    }
}

fileprivate extension Spoofer {

    class func presentController(with identifier: String, sourceViewController: UIViewController?) {
        guard let sourceViewController = sourceViewController else { return }

        let viewControllerToPresent = spooferStoryBoard().instantiateViewController(withIdentifier: identifier)
        sourceViewController.present(viewControllerToPresent, animated: true, completion: nil)
    }

    class func spooferStoryBoard() -> UIStoryboard {
        let frameworkBundle = Bundle(for: Spoofer.self)
        let storyBoard = UIStoryboard(name: "Spoofer", bundle: frameworkBundle)
        return storyBoard
    }
}
