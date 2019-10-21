//
//  FingerTap.swift
//  LeapMotionServer
//
//  Created by 藤井陽介 on 2019/10/21.
//  Copyright © 2019 touyou. All rights reserved.
//

import Foundation

enum FingerTapType: Int, CaseIterable {
    case leftPinky
    case leftRing
    case leftMiddle
    case leftIndex
    case rightIndex
    case rightMiddle
    case rightRing
    case rightPinky
}

enum HandType {
    case left
    case right
}

class FingerTapHelper {
    class func getTapTypes(_ hand: LeapHandRepresentation, for type: HandType) -> [FingerTapType] {
        guard let thumb = hand.thumbFinger else {
            return []
        }

        let isTappedThumb = { (finger: LeapFingerRepresentation) -> Bool in
            let distance = finger.tipPosition.distance(to: thumb.tipPosition)
            return distance < 1.0
        }

        return hand.fingers.filter {
            $0.type != LeapFingerType.thumb && isTappedThumb($0)
        }.map {
            switch (type, $0.type) {
            case (.left, .index):
                return .leftIndex
            case (.left, .middle):
                return .leftMiddle
            case (.left, .ring):
                return .leftRing
            case (.left, .pinky):
                return .leftPinky
            case (.right, .index):
                return .rightIndex
            case (.right, .middle):
                return .rightMiddle
            case (.right, .ring):
                return .rightRing
            case (.right, .pinky):
                return .rightPinky
            default:
                fatalError("Filter Error")
            }
        }
    }
}

// MARK: Custom Description for Debug

extension Array where Element == FingerTapType {
    var description: String {
        get {
            var result = ""
            for (i, type) in self.enumerated() {
                if i != 0 {
                    result += ", "
                }
                result += String(type.rawValue)
            }
            return result
        }
    }
}
