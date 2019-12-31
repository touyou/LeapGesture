//
//  TestConnectionViewController.swift
//  LeapMotionClient
//
//  Created by 藤井陽介 on 2019/12/12.
//  Copyright © 2019 touyou. All rights reserved.
//

import UIKit
// ignore:sorted_imports
import Combine

class TestConnectionViewController: UIViewController {
    @IBOutlet weak var statusLabel: UILabel!

    private var receiver: AnyCancellable?
    let client = UDPClient()

    override func viewDidLoad() {
        super.viewDidLoad()

        client.startConnection()

        receiver = client.$receivedMessage.sink { [weak self] value in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.statusLabel.text = String(value)
            }
            print(CodeConverter.convert(from: value))
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}

extension TestConnectionViewController: StoryboardInstantiable {}
