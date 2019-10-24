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

    fileprivate func setupMultipeerConnectivity() {

        setupPeerId()
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        mcSession.delegate = self
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

    fileprivate func startStream() {
        guard
            let streamTargetPeer = streamTargetPeer,
            let stream = try? mcSession.startStream(withName: "LMDDataStream", toPeer: streamTargetPeer)
        else {
            return
        }

        stream.schedule(in: .main, forMode: .default)
        stream.delegate = self
        stream.open()
        outputStream = stream
    }
}

// MARK: - MCSessionDelegate

extension ViewController: MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            streamTargetPeer = peerID
            startStream()
        case .connecting:
            break
        case .notConnected:
            break
        @unknown default:
            fatalError()
        }
    }

    // MARK: did receive stream
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {}

    // MARK: did start receiving resource
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}

    // MARK: did finish receiving resource
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}

    // MARK: did receive data
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
}

// MARK: - StreamDelegate

extension ViewController: StreamDelegate {

    // MARK: handle stream
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {}
}

// MARK: - LeapServiceDelegate

extension ViewController: LeapServiceDelegate {

    func willUpdateData() {
        print("will update data")
    }

    func didStopUpdatingData() {
        print("did stop updating data")
    }

    func didUpdate(_ handRepresentations: [LeapHandRepresentation]) {
        print(handRepresentations.description)
    }
}
