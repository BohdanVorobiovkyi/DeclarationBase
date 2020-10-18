//
//  ViewController.swift
//  Empat
//
//  Created by Богдан Воробйовський on 15.10.2020.
//

import UIKit
import ProgressHUD
import CoreData
import MBProgressHUD


class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableVeiw: UITableView!

    private let reuseIdentifier = "tableCell"
    private var dataManager: DataManager?
    private var items: [Item]? {
        didSet{
            DispatchQueue.main.async {[weak self] in
                self?.tableVeiw.reloadData()
                if let items = self?.items?.count, items != 0 {
                    self?.scrollToTop()
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.tintColor = .darkGray
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = false
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 28))
        label.attributedText = NSMutableAttributedString().bold("Державний реєстр декларацій")
        self.navigationItem.titleView = label
        setupSearchBar()
        setupTableView()
    
        dataManager = DataManager()
        dataManager?.getRequest(searchText: searchBar.text ?? "", completion: { [weak self] (items) in
            self?.items = items
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.isTranslucent = true
        
        // Cancel Button Color
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.lightGray], for: .disabled)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.lightGray], for: .disabled)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.darkGray], for: .normal)
    }
    
    
    private func setupTableView() {
        tableVeiw.dataSource = self
        tableVeiw.delegate = self
        tableVeiw.rowHeight = UITableView.automaticDimension
        tableVeiw.estimatedRowHeight = 250
        tableVeiw.tableFooterView = UIView()
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? ResultTableCell else {return ResultTableCell()}
        if let items = items {
            cell.configureCell(model: items[indexPath.row])
            cell.delegate = self
            cell.starDelegate = self
            return cell
        }
        return ResultTableCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard (tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? ResultTableCell) != nil else {return}
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text , text.count > 0 {
            ProgressHUD.show()
            dataManager?.getRequest(searchText: searchBar.text ?? "", completion: { [weak self] (items) in
                self?.items = items
                ProgressHUD.dismiss()
            })
        }
    }
    
    private func scrollToTop() {
        let topRow = IndexPath(row: 0,
                               section: 0)
        DispatchQueue.main.async { [weak self] in
            self?.tableVeiw.scrollToRow(at: topRow,
                                        at: .top,
                                        animated: true)
            self?.searchBar.resignFirstResponder()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        ProgressHUD.show()
        self.searchBar.text?.removeAll()
        self.searchBar.showsCancelButton = true
        items = []
        self.tableVeiw.endEditing(true)
        ProgressHUD.dismiss()
    }
}


extension SearchViewController: PDFSelectedDelegate, StarSelectedDelegate {
    
    private func mapSavedItem(with item: Item) -> Item {
        return Item(id: item.id, firstname: item.firstname, lastname: item.lastname, placeOfWork: item.placeOfWork, position: item.position, linkPDF: item.linkPDF, comment: item.comment, lastUpdate: Date())
    }
    
    
    
    private func checkItem(item: Item, comment: String?) {
        let itemToSave = mapSavedItem(with: item)
        
        func getHud() -> MBProgressHUD {
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud.animationType = .fade
            hud.mode = .customView
    //        hud.customView = UIImageView(image: UIImage(named: "checkmark"))
            return hud
        }
    
        self.dataManager?.checkItem(item: itemToSave, comment: comment, completion: {(status) in
            let hud = getHud()
            switch status {
            case .checked:
//                hud.customView = UIImageView(image: UIImage(named: "star.png"))
                hud.label.text = "Додано до списку обраних"
            case .unchecked:
                hud.label.text = "Видалено зі списку обраних"
            default:
                print("Something wrong with saving")
            }
            hud.show(animated: true)
            hud.hide(animated: true, afterDelay: 1.5)
        })
    }
    //Delegates
    func starSelected(item: Item) {
        
        let alert = UIAlertController(title: "Зберегти до списку обраних", message: "Додайте свій коментар", preferredStyle: .alert)
        alert.addTextField { (textField) in
        }
        let cancelAction = UIAlertAction(title: "Відміна", style: .cancel) {(_) in
            alert.dismiss(animated: true, completion: nil)
        }
        let saveAction = UIAlertAction(title: "OK", style: .default, handler: { [weak self]  (_) in
            let textField = alert.textFields![0] // Force unwrapping because we know it exists.
            self?.checkItem(item: item, comment: textField.text)
        })
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        if let isSaved = dataManager?.alreadySaved(item: item) {
            if isSaved == false {
                self.present(alert, animated: true, completion: nil)
            } else {
                
                self.checkItem(item: item, comment: "")
            }
        }
    }
    
    func openWebVC(with url: URL) {
        let webVC = WebViewController(with: url)
        self.navigationController?.present(webVC, animated: true, completion: nil)
    }
}
