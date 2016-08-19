//
//  BasePopupWebViewController.swift
//  ruby-china-ios
//
//  Created by Jason Lee on 16/8/9.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import Foundation

import UIKit
import WebKit

protocol PopupWebViewControllerDelegate: class {
    func popupWebViewControllerDidFinished(controller: PopupWebViewController, toURL url: NSURL?)
}

class PopupWebViewController: UIViewController {
    var webViewConfiguration: WKWebViewConfiguration?
    weak var delegate: PopupWebViewControllerDelegate?
    var path = ""
    var closeButton: UIBarButtonItem?

    lazy var webView: WKWebView = {
        let configuration = self.webViewConfiguration ?? WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRectZero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: [ "view": webView ]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: [ "view": webView ]))
        
        closeButton = UIBarButtonItem(title: "关闭", style: .Plain, target: self, action:  #selector(actionClose))        
        navigationItem.leftBarButtonItem = closeButton
        
        navigationController?.navigationBar.tintColor = UIColor.blackColor()
        
        var urlString = ROOT_URL + path
        if let accessToken = OAuth2.shared.accessToken {
            urlString += "?access_token=" + accessToken
        }
        webView.loadRequest(NSURLRequest(URL: NSURL(string: urlString)!))
    }
    
    func  actionClose() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension PopupWebViewController: WKNavigationDelegate {
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if (navigationAction.request.HTTPMethod == "GET") {
            if let URL = navigationAction.request.URL where URL.path != path {
                dismissViewControllerAnimated(true, completion: nil)
                delegate?.popupWebViewControllerDidFinished(self, toURL: URL)
                decisionHandler(.Cancel)
                return
            }
        }
        
        decisionHandler(.Allow)
    }
}