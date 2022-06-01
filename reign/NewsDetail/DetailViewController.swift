//
//  DetailViewController.swift
//  reign
//
//  Created by Gerardo Villarroel on 31-05-22.
//

import UIKit
import WebKit

class DetailViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    //MARK: Controls
    @IBOutlet weak var mWebView: WKWebView!
    @IBOutlet weak var mActivityProgress: UIActivityIndicatorView!
    
    //MARK: Variables
    var mUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mWebView.navigationDelegate = self
        loadWebPage(stringUrl: mUrl!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.setHidesBackButton(false, animated: true)
    }
    
    //MARK: Control del webview
    func loadWebPage(stringUrl: String) {
        let url = URL(string: stringUrl)
        mWebView.load(URLRequest(url: url!))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        mActivityProgress.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        mActivityProgress.startAnimating()
    }

}
