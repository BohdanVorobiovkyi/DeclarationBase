//
//  FavouriteViewController.swift
//  Empat
//
//  Created by Богдан Воробйовський on 16.10.2020.
//

import UIKit
import MBProgressHUD

class FavouriteViewController: UITableViewController {
    
    private var reuseIdentifier = "tableFavCell"
    private let dataManager = DataManager()
    private var items: [SavedItem] {
        return dataManager.fetchItems()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle()
        setupTableView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setTitle() {
        self.navigationController?.navigationBar.isHidden = false
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 28))
        label.textAlignment = .center
        label.attributedText = NSMutableAttributedString().bold("Обрані")
        self.navigationItem.titleView = label
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
        cell.favButton.isHidden = true
        let fetchedObject = dataManager.fetchItems()[indexPath.row]
        let item = Item(id: fetchedObject.id ?? "", firstname: fetchedObject.firstName ?? "", lastname: fetchedObject.lastName ?? "", placeOfWork: fetchedObject.placeOfWork ?? nil, position: fetchedObject.position ?? "", linkPDF: fetchedObject.linkPDF ?? "", comment: fetchedObject.userComment, lastUpdate: Date())
        cell.configureCell(model: item)
        cell.delegate = self
        return cell
    }
    
    func getHud() -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.animationType = .fade
        hud.mode = .customView
//        hud.customView = UIImageView(image: UIImage(named: "checkmark"))
        return hud
    }
    
    
    private func makeDeleteContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
           return UIContextualAction(style: .destructive, title: "Видалити") { [weak self] (action, swipeButtonView, completion) in
               print("DELETE HERE")
            if let id = self?.items[indexPath.row].id {
                self?.dataManager.removeItem(itemId: id )
               completion(true)
                self?.tableView.reloadData()
            }
           }
       }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
           return UISwipeActionsConfiguration(actions: [
               makeDeleteContextualAction(forRowAt: indexPath)
           ])
       }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard (tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? ResultTableCell) != nil else {return}
        tableView.deselectRow(at: indexPath, animated: true)
//           Show alert with current comment
        let alert = UIAlertController(title: "Оновити коментар", message: "", preferredStyle: .alert)
        let savedItem = self.dataManager.fetchItems()[indexPath.row]
        
        alert.addTextField { (textField) in
            textField.text = savedItem.userComment
        }
        let textField = alert.textFields?[0]
        let saveAction = UIAlertAction(title: "Оновити", style: .default) { [weak self] (_) in
            if let id = savedItem.id, let newComment = textField?.text {
                self?.dataManager.updateFavouriteItem(id: id, comment: newComment) { (status) in
                    let hud = self?.getHud()
                    
                    switch status {
                    case .updated:
                        hud?.label.text = "Комментар оновлено"
                        DispatchQueue.main.async { [weak self] in
                            self?.tableView.reloadData()
                        }
                    case .noChanges:
                        hud?.label.text = "Комментар не змінився"
                    case .error:
                        hud?.label.text = "Помилка в зміні комментаря"
                    }
                    hud?.show(animated: true)
                    hud?.hide(animated: true, afterDelay: 1.5)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Відміна", style: .cancel) {(_) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}


extension FavouriteViewController: PDFSelectedDelegate {
    func openWebVC(with url: URL) {
        let webVC = WebViewController(with: url)
        self.navigationController?.present(webVC, animated: true, completion: nil)
    }
}
