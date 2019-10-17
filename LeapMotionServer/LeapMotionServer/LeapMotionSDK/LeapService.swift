//
//  LeapService.swift
//  LeapMotionServer
//
//  Created by 藤井陽介 on 2019/10/17.
//  Copyright © 2019 touyou. All rights reserved.
//

import Foundation

protocol LeapServiceDelegate {
    func willUpdateData()
    func didStopUpdatingData()
    func didUpdate()
}

final class LeapService: NSObject {

    var delegate: LeapServiceDelegate?

    fileprivate var isUpdatingData: Bool = false {
        willSet {
            if newValue != isUpdatingData {
                newValue == true ? delegate?.willUpdateData() : delegate?.didStopUpdatingData()
            }
        }
    }
    fileprivate var controller: LeapController?

    func run() {
        controller = LeapController()
        controller?.addListener(self)
    }
}

// MARK: - Leap Listener

extension LeapService: LeapListener {

    func onInit(_ notification: Notification!) {

    }

    func onConnect(_ notification: Notification!) {

    }

    func onDisconnect(_ notification: Notification!) {

    }

    func onServiceConnect(_ notification: Notification!) {

    }

    func onDeviceChange(_ notification: Notification!) {

    }

    func onExit(_ notification: Notification!) {

    }

    func onFrame(_ notification: Notification!) {

    }
}
