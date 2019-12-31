//
//  CodeConverter.swift
//  LeapMotionClient
//
//  Created by 藤井陽介 on 2019/12/20.
//  Copyright © 2019 touyou. All rights reserved.
//

import Foundation

class CodeConverter {
    enum Finger: Int {
        case leftPinky = 3
        case leftRing = 2
        case leftMiddle = 1
        case leftIndex = 0
        case rightIndex = 5
        case rightMiddle = 6
        case rightRing = 7
        case rightPinky = 8
    }

    static func convert(from message: String) -> [Finger] {
        var fingers = [Finger]()
        for num in message {
            guard
                let rawValue = Int(num.description),
                let finger = Finger(rawValue: rawValue) else { continue }
            fingers.append(finger)
        }
        return fingers
    }
}
