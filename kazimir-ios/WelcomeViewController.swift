//
//  WelcomeViewController.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 26/04/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit
import CoreData

class WelcomeViewController: UIViewController {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var discoverButton: UIButton!
    @IBOutlet weak var messagaLabel: UILabel!
    
    let streetsFetchedResultsController = Storage.sharedInstance.getStreetsFetchedResultsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        streetsFetchedResultsController.delegate = self
        streetsFetchedResultsController.performFetch(nil)
        
        DataSynchronizer.sharedInstance.delegate = self
        if streetsFetchedResultsController.fetchedObjects?.count == 0 {
            discoverButton.enabled = false
            DataSynchronizer.sharedInstance.startSynchronization(locally: true)
        }
        else {
            DataSynchronizer.sharedInstance.startSynchronization(locally: false)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

}

extension WelcomeViewController: DataSynchronizerDelegate {
    
    func dataSynchronizer(dataSynchronizer: DataSynchronizer, didFinishSynchronizationLocally locally: Bool, error: NSError?) {
        activityIndicatorView.stopAnimating()
        messagaLabel.hidden = true
        DataSynchronizer.sharedInstance.delegate = nil
        if locally {
            DataSynchronizer.sharedInstance.startSynchronization(locally: false)
        }
        else {
            activityIndicatorView.stopAnimating()
            messagaLabel.hidden = true
            DataSynchronizer.sharedInstance.delegate = nil
        }
    }
    
}

extension WelcomeViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        discoverButton.enabled = controller.fetchedObjects?.count > 0
    }
    
}
