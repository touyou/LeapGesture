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

class UdpClient: NSObject {
    private let networkType = "_networkplayground._udp."
    private let networkDomain = "local"
    private let netServiceBrowser = NetServiceBrowser()
    
    var receivedMessage = PassthroughSubject<String, Never>()
    
    func startConnection() {
        netServiceBrowser.delegate = self
        netServiceBrowser.searchForServices(ofType: networkType, inDomain: networkDomain)
    }
    
    private func startListener(name: String) {
        let udpParams = NWParameters.udp
        guard let listener = try? NWListener(using: udpParams) else {
            fatalError()
        }
        
        listener.service = NWListener.Service(name: name, type: networkType)
        
        let listenerQueue = DispatchQueue(label: "dev.touyou.LeapMotionClient.listener")
        
        listener.newConnectionHandler = { [unowned self] connection in
            connection.start(queue: listenerQueue)
            self.receive(on: connection)
        }
        
        listener.start(queue: listenerQueue)
    }
    
    private func receive(on connection: NWConnection) {
        connection.receiveMessage { data, _, _, error in
            if let data = data, let message = String(data: data, encoding: .utf8) {
                self.receivedMessage.send(message)
            }
            if let error = error {
                print(error)
            } else {
                self.receive(on: connection)
            }
        }
    }
}

extension UdpClient: NetServiceBrowserDelegate {
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        startListener(name: service.name)
    }
}
