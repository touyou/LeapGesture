//
//  MorseViewController.swift
//  LeapMotionClient
//
//  Created by 藤井陽介 on 2020/01/02.
//  Copyright © 2020 touyou. All rights reserved.
//

import UIKit
// ignore: sorted_imports
import Combine

class MorseViewController: UIViewController {
    @IBOutlet weak var characterLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!

    private var receiver: AnyCancellable?
    var client: UDPClient!
    let utility = MorseUtility()

    override func viewDidLoad() {
        super.viewDidLoad()

        receiver = client.$receivedMessage.sink { [weak self] value in
            guard let self = self else { return }
            let fingers = CodeConverter.convert(from: value)
            let (morse, char) = self.utility.getMorse(fingers)
            DispatchQueue.main.async {
                self.characterLabel.text = char
                self.codeLabel.text = morse
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        receiver?.cancel()
    }
}

extension MorseViewController {
    struct Morse {
        let dot: UInt8
        let bar: UInt8
        let char: String
    }

    class MorseUtility {
        private let morses: [Morse] = [
            Morse(dot: 0b1000, bar: 0b0100, char: "A"),
            Morse(dot: 0b0111, bar: 0b1000, char: "B"),
            Morse(dot: 0b0101, bar: 0b1010, char: "C"),
            Morse(dot: 0b0110, bar: 0b1000, char: "D"),
            Morse(dot: 0b1000, bar: 0b0000, char: "E"),
            Morse(dot: 0b1011, bar: 0b0010, char: "F"),
            Morse(dot: 0b0010, bar: 0b1100, char: "G"),
            Morse(dot: 0b1111, bar: 0b0000, char: "H"),
            Morse(dot: 0b1100, bar: 0b0000, char: "I"),
            Morse(dot: 0b1000, bar: 0b0111, char: "J"),
            Morse(dot: 0b0100, bar: 0b1010, char: "K"),
            Morse(dot: 0b1011, bar: 0b0100, char: "L"),
            Morse(dot: 0b0000, bar: 0b1100, char: "M"),
            Morse(dot: 0b0100, bar: 0b1000, char: "N"),
            Morse(dot: 0b0000, bar: 0b1110, char: "O"),
            Morse(dot: 0b1001, bar: 0b0110, char: "P"),
            Morse(dot: 0b0010, bar: 0b1101, char: "Q"),
            Morse(dot: 0b1010, bar: 0b0100, char: "R"),
            Morse(dot: 0b1110, bar: 0b0000, char: "S"),
            Morse(dot: 0b0000, bar: 0b1000, char: "T"),
            Morse(dot: 0b1100, bar: 0b0010, char: "U"),
            Morse(dot: 0b1110, bar: 0b0001, char: "V"),
            Morse(dot: 0b1000, bar: 0b0110, char: "W"),
            Morse(dot: 0b0110, bar: 0b1001, char: "X"),
            Morse(dot: 0b0100, bar: 0b1011, char: "Y"),
            Morse(dot: 0b0011, bar: 0b1100, char: "Z")
        ]

        func getMorse(_ fingers: [CodeConverter.Finger]) -> (morse: String, char: String) {
            guard let morse = convertToMorse(fingers) else {
                return (morse: "", char: "No Code")
            }

            var morseString = ""
            for idx in (0 ..< 4).reversed() {
                if (morse.dot >> idx & 1) == 1 {
                    morseString += "・"
                } else if (morse.bar >> idx & 1) == 1 {
                    morseString += "ー"
                }
            }

            return (morse: morseString, char: morse.char)
        }

        private func convertToMorse(_ fingers: [CodeConverter.Finger]) -> Morse? {
            var leftHand: UInt8 = 0
            var rightHand: UInt8 = 0
            for finger in fingers {
                let value = finger.rawValue
                if value < 4 {
                    leftHand |= 1 << value
                } else {
                    rightHand |= 1 << (8 - value)
                }
            }
            for morse in morses {
                if morse.dot == leftHand && morse.bar == rightHand {
                    return morse
                }
            }
            return nil
        }
    }
}

extension MorseViewController: StoryboardInstantiable {}
