//
//  StoryboardInstantiable.swift
//  LeapMotionClient
//
//  Created by 藤井陽介 on 2019/12/04.
//  Copyright © 2019 touyou. All rights reserved.
//

import UIKit

protocol StoryboardInstantiable {
    static var storyboardName: String { get }
    var client: UDPClient! { get set }
}

extension StoryboardInstantiable where Self: UIViewController {
    static var storyboardName: String {
        String(describing: self)
    }
    
    func instantiate() -> Self {
        let storyboard = UIStoryboard(name: Self.storyboardName, bundle: nil)
        
        guard let controller = storyboard.instantiateInitialViewController() as? Self else {
            fatalError("Not found \(Self.storyboardName).swift")
        }
        
        return controller
    }
}
