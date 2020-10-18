//
//  WebViewController.swift
//  Empat
//
//  Created by Богдан Воробйовський on 17.10.2020.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    private var webView: WKWebView!
    private var link: URL
    private lazy var closeButton: UIButton = {
        let button = UIButton()

        return button
    }()
    
    init(with urlLink: URL){
        self.link = urlLink
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
         print("WebPageViewController deinit")
     }
    
    override func loadView() {
        super.loadView()
        webView = WKWebView(frame: view.frame)
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let request = URLRequest(url: link, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 5)
        webView.load(request)
        self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}


