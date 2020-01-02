//
//  SoundViewController.swift
//  LeapMotionClient
//
//  Created by 藤井陽介 on 2019/12/20.
//  Copyright © 2019 touyou. All rights reserved.
//

import UIKit
// ignore: sorted_imports
import AudioKit
import Combine

class SoundViewController: UIViewController {
    @IBOutlet weak var soundLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    private var receiver: AnyCancellable?
    var duration: Double = 2.0
    var client: UDPClient!
    let audioBox = AudioUtility()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        audioBox.start()
        
        receiver = client.$receivedMessage.sink { [weak self] value in
            guard let self = self else { return }
            let fingers = CodeConverter.convert(from: value)
            self.audioBox.play(for: fingers, duration: self.duration)
            DispatchQueue.main.async {
                self.soundLabel.text = self.audioBox.string(fingers)
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        receiver?.cancel()
        audioBox.stopAll()

        super.viewDidDisappear(animated)
    }
    
    @IBAction private func changedDurationSlider(_ sender: UISlider) {
        durationLabel.text = String(format: "Duration: %.1f", duration)
        duration = Double(sender.value)
    }
}

extension SoundViewController {
    class AudioUtility {
        var oscillators = [AKOscillator]()
        var mixer: AKMixer?
        
        let frequencies = [
            523.251, 587.330, 659.255, 698.456,
            783.991, 880.000, 987.767, 1_046.502
        ]
        
        init() {
            for idx in 0..<8 {
                let oscillator = AKOscillator()
                oscillator.frequency = frequencies[idx]
                oscillator.amplitude = 0.5
                oscillators.append(oscillator)
            }
            mixer = AKMixer(oscillators)
        }
        
        func start() {
            AudioKit.output = mixer
            do {
                try AudioKit.start()
            } catch {
                print("cannot initialize audiokit")
            }
        }
        
        func play(for fingers: [CodeConverter.Finger], duration: Double = 2.0) {
            for finger in fingers {
                let idx = convertToIndex(of: finger)
                oscillators[idx].start()
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [unowned self] in
                    if self.oscillators[idx].isStopped {
                        return
                    }
                    self.oscillators[idx].stop()
                }
            }
        }

        func stopAll() {
            for oscillator in oscillators {
                oscillator.stop()
            }
        }
        
        func string(_ fingers: [CodeConverter.Finger]) -> String {
            let sounds = ["ド", "レ", "ミ", "ファ", "ソ", "ラ", "シ", "Hiド"]
            var soundName = ""
            for finger in fingers {
                soundName += sounds[convertToIndex(of: finger)]
            }
            return soundName
        }
        
        private func convertToIndex(of finger: CodeConverter.Finger) -> Int {
            switch finger {
            case .leftPinky:
                return 0
            case .leftRing:
                return 1
            case .leftMiddle:
                return 2
            case .leftIndex:
                return 3
            case .rightIndex:
                return 4
            case .rightMiddle:
                return 5
            case .rightRing:
                return 6
            case .rightPinky:
                return 7
            }
        }
    }
}

extension SoundViewController: StoryboardInstantiable {}
