//
//  BinaryViewController.swift
//  LeapMotionClient
//
//  Created by 藤井陽介 on 2019/12/31.
//  Copyright © 2019 touyou. All rights reserved.
//

import UIKit
// ignore: sorted_imports
import Combine

class BinaryViewController: UIViewController {
    @IBOutlet weak var resultLabel: UILabel!

    private var receiver: AnyCancellable?
    var client: UDPClient!

    override func viewDidLoad() {
        super.viewDidLoad()

        receiver = client.$receivedMessage.sink { [weak self] value in
            guard let self = self else { return }
            let fingers = CodeConverter.convert(from: value)
            let result = self.convertFingers(fingers)
            DispatchQueue.main.async {
                self.resultLabel.text = String(format: "%d + %d = %d", result[0], result[1], result[0] + result[1])
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        receiver?.cancel()
    }

    func convertFingers(_ fingers: [CodeConverter.Finger]) -> [Int] {
        var result = [Int](repeating: 0, count: 2)
        for finger in fingers {
            let value = finger.rawValue
            if value < 4 {
                result[0] += 1 << value
            } else {
                result[1] += 1 << (8 - value)
            }
        }
        return result
    }
}

extension BinaryViewController: StoryboardInstantiable {}
