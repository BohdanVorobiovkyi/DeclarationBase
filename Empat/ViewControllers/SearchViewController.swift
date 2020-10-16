//
//  ViewController.swift
//  Empat
//
//  Created by Богдан Воробйовський on 15.10.2020.
//

import UIKit
import ProgressHUD

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
            cell.configureCell(model: items[indexPath.row])
            return cell
        }
           return ResultTableCell()
    }
}


extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text , text.count > 0 {
            ProgressHUD.show()
            dataManager?.getRequest(searchText: searchBar.text ?? "", completion: { [weak self] (items) in
                self?.items = items
                self?.scrollToTop()
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
