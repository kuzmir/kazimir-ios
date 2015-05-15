//
//  WelcomeViewController.swift
//  kazimir-ios
//
//  Created by Krzysiek on 26/04/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var discoverButton: UIButton!
    @IBOutlet weak var messagaLabel: UILabel!
    
    let streetsFetchedResultsController = Storage.sharedInstance.getStreetsFetchedResultsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        streetsFetchedResultsController.performFetch(nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        DataSynchronizer.sharedInstance.delegate = self
        if DataSynchronizer.sharedInstance.isSynchronizationInProgress {
            self.dataSynchronizerDidStartSynchronization(DataSynchronizer.sharedInstance)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.discoverButton.enabled = streetsFetchedResultsController.fetchedObjects?.count > 0
        if !discoverButton.enabled { DataSynchronizer.sharedInstance.startSynchronization(nil) }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        DataSynchronizer.sharedInstance.delegate = nil
        if DataSynchronizer.sharedInstance.isSynchronizationInProgress {
            self.dataSynchronizerDidFinishSynchronization(DataSynchronizer.sharedInstance, error: nil)
        }
    }

}

extension WelcomeViewController: DataSynchronizerDelegate {
    
    func dataSynchronizerDidStartSynchronization(dataSynchronizer: DataSynchronizer) {
        self.activityIndicatorView.startAnimating()
        self.messagaLabel.hidden = false
    }
    
    func dataSynchronizerDidFinishSynchronization(dataSynchronizer: DataSynchronizer, error: NSError?) {
        activityIndicatorView.stopAnimating()
        messagaLabel.hidden = true
        discoverButton.enabled = error == nil
        if !discoverButton.enabled {
            self.performSegueWithIdentifier("showError", sender: self)
        }
    }
    
}
