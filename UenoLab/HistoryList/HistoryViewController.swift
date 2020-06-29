//
//  HistoryViewController.swift
//  UenoLab
//
//  Created by MBP0020 on 12/4/19.
//  Copyright © 2019 UenoLab. All rights reserved.
//

import UIKit
import RealmSwift

class HistoryViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

    let viewModel = HistoryListViewModel()
    var tokenUserRecord: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "History"
        configTable()

        tokenUserRecord = try! Realm().objects(UserRecord.self).observe({ (chnaged) in
            self.tableView.reloadData()
        })
    }

    private func configTable() {
        let nib = UINib(nibName: "HistoryTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "HistoryTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
}

extension HistoryViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems(inSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell") as? HistoryTableViewCell else {
            return UITableViewCell()
        }
        cell.userRecord = viewModel.viewModelForItem(at: indexPath)
        return cell
    }
}

extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = HistoryDetailViewController()
        vc.userRecorded = viewModel.viewModelForItem(at: indexPath)
        navigationController?.pushViewController(vc, animated: true)
    }
}
