//
//  TabBarController.swift
//  nabelova_1PW8
//
//  Created by Наталья Белова on 20.03.2022.
//

import Foundation
import UIKit

 class TabBarController: UITabBarController {
     override func viewDidLoad() {
         super.viewDidLoad()
         view.backgroundColor = .systemBackground
         setUpViewControllers()
     }

     private func setUpViewControllers(){
         viewControllers = [
             navigate(for: MoviesViewController(), title: "Фильмы", image: UIImage(named: "movie")!),
             navigate(for: SearchViewController(), title: "Поиск", image: UIImage(named: "search")!)
         ]
     }

     private func navigate(for rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController{
         let controller = UINavigationController(rootViewController: rootViewController)
         controller.tabBarItem.image = image
         controller.tabBarItem.title = title
         controller.navigationBar.prefersLargeTitles = true
         rootViewController.navigationItem.title = title
         return controller
     }

 }
