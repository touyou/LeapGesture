//
//  ViewController.swift
//  LeapMotionServer
//
//  Created by 藤井陽介 on 2019/10/17.
//  Copyright © 2019 touyou. All rights reserved.
//

import Cocoa
import MultipeerConnectivity

class ViewController: NSViewController {

    fileprivate let leapService = LeapService()

    fileprivate var peerID: MCPeerID!
    fileprivate var mcSession: MCSession!
    fileprivate var mcAdvertiserAssistant: MCAdvertiserAssistant!
    fileprivate var streamTargetPeer: MCPeerID?
    fileprivate var outputStream: OutputStream?

    override func viewDidLoad() {
        super.viewDidLoad()

        leapService.delegate = self
        leapService.run()
    }

    fileprivate func setupPeerId() {

        let kDisplayNameKey = "kDisplayNameKey"
        let kPeerIDKey = "kPeerIDKey"
        let displayName: String = "LMDSupply"
        let defaults = UserDefaults.standard
        let oldDisplayName = defaults.string(forKey: kDisplayNameKey)

        if oldDisplayName == displayName {
            guard let peerIDData = defaults.data(forKey: kPeerIDKey) else {
                return
            }
            guard let id = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(peerIDData) as? MCPeerID else {
                return
            }
            peerID = id
            return
        }

        let peerID = MCPeerID(displayName: displayName)
        let peerIDData = try! NSKeyedArchiver.archivedData(withRootObject: peerID, requiringSecureCoding: false)
        defaults.set(peerIDData, forKey: kPeerIDKey)
        defaults.set(displayName, forKey: kDisplayNameKey)
        self.peerID = peerID
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
