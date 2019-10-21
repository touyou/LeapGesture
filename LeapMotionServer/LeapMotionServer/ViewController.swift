//
//  ViewController.swift
//  LeapMotionServer
//
//  Created by 藤井陽介 on 2019/10/17.
//  Copyright © 2019 touyou. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    fileprivate let leapService = LeapService()

    override func viewDidLoad() {
        super.viewDidLoad()

        leapService.delegate = self
        leapService.run()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

// MARK: - LeapServiceDelegate

extension ViewController: LeapServiceDelegate {

    func willUpdateData() {

    }

    func didStopUpdatingData() {

    }

    func didUpdate(_ handRepresentations: [LeapHandRepresentation]) {

    }
}
