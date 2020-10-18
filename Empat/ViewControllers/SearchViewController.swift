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

enum MocConstants {
    static let font = UIFont(name: "HelveticaNeue", size: 16)
    static let topLogo = UIImage(named: "github-header.png")
}


class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableVeiw: UITableView!
    
    //    private let reuseIdentifier = "SearchCell"
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

        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = false
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 28))
        label.attributedText = NSMutableAttributedString().bold("Державний реєстр декларацій")
        self.navigationItem.titleView = label
        setupSearchBar()
        setupTableView()
//        setupCollectionView()
        dataManager = DataManager()
        dataManager?.getRequest(searchText: searchBar.text ?? "", completion: { [weak self] (items) in
            self?.items = items
        })
        
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
//    private func setupDataManager() {
//        dataManager = DataManager()
//    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.isTranslucent = true
        
        // Cancel Button Color
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.lightGray], for: .disabled)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.darkGray], for: .normal)
    }
    
    private func setupTitle() {
        let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 28))
        iv.contentMode = .scaleAspectFit
        iv.image = MocConstants.topLogo
        self.navigationItem.titleView = iv
    }
    
    private func setupTableView() {
//        tableVeiw.register(ResultTableCell.self, forCellReuseIdentifier: "DefaultCell")
        tableVeiw.dataSource = self
        tableVeiw.delegate = self
        tableVeiw.rowHeight = UITableView.automaticDimension
        tableVeiw.estimatedRowHeight = 400
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
            print(items[indexPath.row].comment)
            cell.configureCell(model: items[indexPath.row])
            cell.delegate = self
            return cell
        }
           return ResultTableCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? ResultTableCell else {return}
        
        tableView.deselectRow(at: indexPath, animated: true)
        let alert = UIAlertController(title: "Зберегти в список обраних", message: "Додайте свій коментар", preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
//            textField.text = "Some default text"
        }
        struct ItemToSave {
            let item: Item
            let date: Date = Date()
        }
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self]  (_) in
            guard let strongSelf = self else {return}
            let textField = alert.textFields![0] // Force unwrapping because we know it exists.
            if let item = self?.items?[indexPath.row] {
                let itemToSave = Item(id: item.id, firstname: item.firstname, lastname: item.lastname, placeOfWork: item.placeOfWork, position: item.position, linkPDF: item.linkPDF, comment: item.comment, lastUpdate: Date())
//                self?.dataManager?.saveNewFavourite(item: item, comment: textField.text)
                self?.dataManager?.addNewItem(item: itemToSave, comment: textField.text, completion: { (status) in
                    let hud = MBProgressHUD.showAdded(to: strongSelf.view, animated: true)
                    hud.animationType = .fade
                    hud.mode = .customView
                    
                    hud.customView = UIImageView(image: UIImage(named: "checkmark")) // according to the documentation a good image size is something like 37x37px
                    
                    switch status {
                    case .exist:
                        hud.label.text = "Item already exist"
                        hud.show(animated: true)
                        hud.hide(animated: true, afterDelay: 1)
                    case .added:
                        hud.label.text = "Completed"
                        hud.show(animated: true)
                        hud.hide(animated: true, afterDelay: 1)
                    case .updated:
                        hud.label.text = "Updated"
                        hud.show(animated: true)
                        hud.hide(animated: true, afterDelay: 1)
                    default:
                        print("Something wrong with saving")
                    }
                })
            
            }
            
            print("Text field: \(textField.text)")
        }))
        self.present(alert, animated: true, completion: nil)
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


extension SearchViewController: PDFSelected {
    func openWebVC(with url: URL) {
        let webVC = WebViewController(with: url)
        self.navigationController?.present(webVC, animated: true, completion: nil)
    }
    
    
}

extension SearchViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print(controller.fetchedObjects)
//        self.view.updateCollection()
//        self.isLoading = false
    }
}



//extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//
//    private func setupCollectionView() {
//        self.view.addSubview(collectionView)
//
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView.keyboardDismissMode = .onDrag
//        collectionView.backgroundColor = .lightGray
//        collectionView.register(ResultCell.self, forCellWithReuseIdentifier: reuseIdentifier)
//        collectionView.contentInset = UIEdgeInsets(top: 20, left: 40, bottom: 0, right: 40)
//
//        NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: searchBar, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
//        NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
//            NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
//
//        NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
//    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: UIScreen.main.bounds.width - 40, height: ResultCell.cellHeight)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return items?.count ?? 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ResultCell
//        cell.isUserInteractionEnabled = true
//        if let items = items {
//            cell.configureCell(model: items[indexPath.row])
//            return cell
//        }
//        return UICollectionViewCell()
//    }
//}
