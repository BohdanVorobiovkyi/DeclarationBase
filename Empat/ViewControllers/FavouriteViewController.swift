//
//  FavouriteViewController.swift
//  Empat
//
//  Created by Богдан Воробйовський on 16.10.2020.
//

import UIKit
import CoreData

class FavouriteViewController: UITableViewController {
    
    private var reuseIdentifier = "tableFavCell"
    private let dataManager = DataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
//        navigationController?.navigationBar.prefersLargeTitles = true
        setupTableView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.register(ResultTableCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
        tableView.tableFooterView = UIView()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataManager.fetchItems().count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! ResultTableCell
        let fetchedObject = dataManager.fetchItems()[indexPath.row]
        let item = Item(id: fetchedObject.id ?? "", firstname: fetchedObject.firstName ?? "", lastname: fetchedObject.lastName ?? "", placeOfWork: fetchedObject.placeOfWork ?? nil, position: fetchedObject.position ?? nil, linkPDF: fetchedObject.linkPDF ?? "", comment: fetchedObject.userComment, lastUpdate: Date())
        cell.configureCell(model: item)

        return cell
    }
}
