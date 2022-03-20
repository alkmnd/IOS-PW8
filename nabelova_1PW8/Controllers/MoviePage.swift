//
//  MoviePage.swift
//  nabelova_1PW8
//
//  Created by Наталья Белова on 20.03.2022.
//

import Foundation
import WebKit

 class WebViewController: UIViewController, WKNavigationDelegate{
     var page = WKWebView()

     var url: URL?

     override func viewDidLoad() {
         page.load(URLRequest(url: url!))
         view.addSubview(page)
         page.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
         page.pinRight(to: view)
         page.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor)
         page.pinLeft(to: view)
     }
 }
