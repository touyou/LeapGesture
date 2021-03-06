//
//  ViewController.swift
//  LeapMotionClient
//
//  Created by 藤井陽介 on 2019/11/11.
//  Copyright © 2019 touyou. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    private let reuseIdentifier = "cell"
    
    @IBOutlet weak var featureListTableView: UITableView! {
        didSet {
            featureListTableView.register(UINib(nibName: String(describing: FeatureListTableViewCell.self), bundle: nil), forCellReuseIdentifier: reuseIdentifier)
            featureListTableView.dataSource = self
            featureListTableView.delegate = self
            featureListTableView.tableFooterView = UIView()
        }
    }
    
    private var features = [
        Feature(name: "接続テスト", featureController: TestConnectionViewController()),
        Feature(name: "楽器", featureController: SoundViewController()),
        Feature(name: "計算機", featureController: BinaryViewController()),
        Feature(name: "モールス信号", featureController: MorseViewController())
    ]
    private let client = UDPClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        client.startConnection()
    }
}

// MARK: - TableView Protocols

extension MainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        features.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? FeatureListTableViewCell
        cell?.nameLabel.text = "Ex.\(indexPath.row) " + features[indexPath.row].name
        return cell ?? UITableViewCell()
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var controller = features[indexPath.row].featureController.instantiate()
        controller.client = client
        present(controller, animated: true, completion: nil)
    }
}
