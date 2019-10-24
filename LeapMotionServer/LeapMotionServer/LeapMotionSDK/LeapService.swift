//
//  LeapService.swift
//  LeapMotionServer
//
//  Created by 藤井陽介 on 2019/10/17.
//  Copyright © 2019 touyou. All rights reserved.
//
// ref: https://github.com/arthurschiller/ARKit-LeapMotion/blob/master/Mac%20App/LeapMotion%20Visualization/Services/LeapService.swift

import Foundation

protocol LeapServiceDelegate {
    func willUpdateData()
    func didStopUpdatingData()
    func didUpdate(_ handRepresentations: [LeapHandRepresentation])
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
    fileprivate var handRepresentations: [LeapHandRepresentation]?

    func run() {
        controller = LeapController()
        controller?.addListener(self)
        print(controller?.devices)
    }
}

// MARK: - Leap Listener

extension LeapService: LeapListener {

    // MARK: LeapMotion Listener Initialized
    func onInit(_ notification: Notification!) {
        print("on init \(notification.description)")
        print(controller?.devices)
    }

    // MARK: LeapMotion Listener Connected
    func onConnect(_ notification: Notification!) {
        guard let controller: LeapController = notification.object as? LeapController else {
            return
        }

        // If you want to enable some gesture, write here
        // e.g. controller.enable(LEAP_GESTURE_TYPE_CIRCLE, enable: true)
        print(controller.description)
    }

    // MARK: LeapMotion Listener Disconnected
    func onDisconnect(_ notification: Notification!) {
        isUpdatingData = false
        print("on disconnect")
    }

    // MARK: LeapMotion Service Connected
    func onServiceConnect(_ notification: Notification!) {
        print("on service connect")
    }

    // MARK: LeapMotion Service Disconnected
    func onDeviceChange(_ notification: Notification!) {
        print("on device change")
    }

    // MARK: LeapMotion Listener Exited
    func onExit(_ notification: Notification!) {
        isUpdatingData = false
        print("on exit")
    }

    // MARK: gets called each time a new frame gets emitted
    func onFrame(_ notification: Notification!) {
        print("on frame")
        guard
            let controller: LeapController = notification.object as? LeapController,
            let frame = controller.frame(0),
            let hands = frame.hands as? [LeapHand]
            else {
                isUpdatingData = false
                return
        }

        isUpdatingData = true
        handRepresentations = []
        for hand in hands {
            let leapHandRepresentation = hand.getRepresentation()
            guard
                hand.isValid, // hand.confidence > 0.05,
                var handRepresentation = leapHandRepresentation
                else {
                    continue
            }

            if let translation = hand.translation(controller.frame(1)) {
                handRepresentation.translation = translation
            }
            handRepresentations?.append(handRepresentation)
        }
        delegate?.didUpdate(handRepresentations ?? [])
    }
}

// MARK: - Leap Hand Representation

struct LeapHandRepresentation {
    var translation: LeapVector?
    let position: LeapVector
    let eulerAngles: LeapVector
    let thumbFinger: LeapFingerRepresentation?
    let fingers: [LeapFingerRepresentation]
}

extension LeapHand {

    // MARK: returns the representation of a hand
    func getRepresentation() -> LeapHandRepresentation? {
        guard let fingerData = getFingerRepresentations() else {
            return nil
        }

        return LeapHandRepresentation(
            translation: nil,
            position: palmPosition,
            eulerAngles: LeapVector(x: direction.pitch, y: -direction.yaw, z: palmNormal.roll),
            thumbFinger: fingerData.filter { $0.type == LeapFingerType.thumb }.first,
            fingers: fingerData
        )
    }

    // MARK: returns an array of finger representation from the hand
    func getFingerRepresentations() -> [LeapFingerRepresentation]? {
        guard let fingers: [LeapFinger] = fingers as? [LeapFinger] else {
            return nil
        }

        var fingerData: [LeapFingerRepresentation] = []
        for type in LeapFingerType.allCases {
            guard let finger = LeapHelpers.get(finger: type, from: fingers) else {
                return nil
            }

            fingerData.append(
                LeapFingerRepresentation(
                    type: type,
                    mcpPosition: finger.position(of: .mcp),
                    pipPosition: finger.position(of: .pip),
                    dipPosition: finger.position(of: .dip),
                    tipPosition: finger.position(of: .tip)
                )
            )
        }
        return fingerData
    }
}

// MARK: - Leap Finger Representation

struct LeapFingerRepresentation {
    let type: LeapFingerType
    let mcpPosition: LeapVector
    let pipPosition: LeapVector
    let dipPosition: LeapVector
    let tipPosition: LeapVector
}

enum LeapFingerType: CaseIterable {
    case thumb
    case index
    case middle
    case ring
    case pinky
}

enum LeapFingerJointType {
    case mcp
    case pip
    case dip
    case tip
}

extension LeapFinger {

    // MARK: returns representation of a fingers position
    func getRepresentation() -> LeapFingerRepresentation? {
        guard let type = getType() else {
            return nil
        }

        return LeapFingerRepresentation(
            type: type,
            mcpPosition: position(of: .mcp),
            pipPosition: position(of: .pip),
            dipPosition: position(of: .dip),
            tipPosition: position(of: .tip)
        )
    }

    // MARK: returns the type of a finger
    func getType() -> LeapFingerType? {
        switch type {
        case LEAP_FINGER_TYPE_THUMB:
            return .thumb
        case LEAP_FINGER_TYPE_INDEX:
            return .index
        case LEAP_FINGER_TYPE_MIDDLE:
            return .middle
        case LEAP_FINGER_TYPE_RING:
            return .ring
        case LEAP_FINGER_TYPE_PINKY:
            return .pinky
        default:
            return nil
        }
    }

    // MARK: returns the position of a finger's joint
    func position(of joint: LeapFingerJointType) -> LeapVector {
        switch joint {
        case .mcp:
            return jointPosition(.init(0))
        case .pip:
            return jointPosition(.init(1))
        case .dip:
            return jointPosition(.init(2))
        case .tip:
            return jointPosition(.init(3))
        }
    }
}

// MARK: - Leap Helpers

struct LeapHelpers {

    static func get(finger: LeapFingerType, from fingers: [LeapFinger]) -> LeapFinger? {
        guard fingers.count == 5 else {
            return nil
        }

        switch finger {
        case .thumb:
            return fingers[0].isValid ? fingers[0] : nil
        case .index:
            return fingers[1].isValid ? fingers[1] : nil
        case .middle:
            return fingers[2].isValid ? fingers[2] : nil
        case .ring:
            return fingers[3].isValid ? fingers[3] : nil
        case .pinky:
            return fingers[4].isValid ? fingers[4] : nil
        }
    }
}
