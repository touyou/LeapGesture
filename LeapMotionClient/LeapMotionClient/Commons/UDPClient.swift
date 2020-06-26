//
//  UdpClient.swift
//
//
//  Created by 藤井陽介 on 2019/12/04.
//

import Combine
import Foundation
import Network

// ref: https://qiita.com/shu223/items/a6bcc454232e96c107ec

class UDPClient: NSObject {
    @Published var receivedMessage: String = ""
    
    func startConnection() {
        startListener(name: "LeapMotion")
    }
    
    private func startListener(name: String) {
        guard let listener = try? NWListener(using: .udp, on: 1_234) else {
            fatalError()
        }
        
        let listenerQueue = DispatchQueue(label: "dev.touyou.LeapMotionClient.listener")

        listener.newConnectionHandler = { [unowned self] connection in
            print("connected")
            connection.start(queue: listenerQueue)
            self.receive(on: connection)
        }

        listener.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("ready")
                let connection = NWConnection(host: "10.209.15.255", port: 5_432, using: .udp)
                connection.start(queue: listenerQueue)
                self.receive(on: connection)

            default:
                break
            }
        }
        
        listener.start(queue: listenerQueue)
    }
    
    private func receive(on connection: NWConnection) {
        connection.receiveMessage { data, _, _, error in
            if let data = data, let message = String(data: data, encoding: .utf8) {
                print(message)
                self.receivedMessage = message
            }
            if let error = error {
                print(error)
            } else {
                self.receive(on: connection)
            }
        }
    }
}
