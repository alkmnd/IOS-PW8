//
//  ScrollViewController.swift
//  nabelova_1PW8
//
//  Created by Наталья Белова on 20.03.2022.
//

import Foundation
import UIKit

 class ScrollViewController: UIViewController {

     private let tableView = UITableView()
     private var pageCount = 0
     private var movies = [Movie]()
     private var session: URLSessionDataTask?!
     private let apiKey = "fc57145e7f23876373951e70a3dd0560"
     var window: UIWindow?

     override func viewDidLoad() {
         super.viewDidLoad()
         view.backgroundColor = .white
         configureUI()
         DispatchQueue.global(qos: .background).async { [weak self] in
             self?.loadMovies(page: 2)
         }
         tableView.rowHeight = 250
     }

     private func loadMoviePage(id: Int) -> String {
         return "https://www.themoviedb.org/movie/\(id)"
     }
     private func configureUI(){
         view.addSubview(tableView)
         tableView.dataSource = self
         tableView.prefetchDataSource = self
         tableView.delegate = self
         tableView.register(MovieCell.self, forCellReuseIdentifier: MovieCell.identifier)
         tableView.translatesAutoresizingMaskIntoConstraints = false
         NSLayoutConstraint.activate([
             tableView.topAnchor.constraint(equalTo:view.topAnchor),
             tableView.leadingAnchor.constraint(equalTo:view.leadingAnchor),
             tableView.trailingAnchor.constraint(equalTo:view.trailingAnchor),
             tableView.bottomAnchor.constraint(equalTo:view.bottomAnchor)
         ])
         tableView.reloadData()
     }

     private func loadImagesForMovies(_ movies: [Movie], completion: @escaping ([Movie]) -> Void) {
         let group = DispatchGroup()
         for movie in movies {
             group.enter()
             DispatchQueue.global(qos: .background).async {
                 movie.loadPoster { _ in
                     group.leave()
                 }
             }
         }
         group.notify(queue: .main) {
             completion(movies)
         }

     }

     private func loadMovies(page: Int){
         if (session != nil) {
             session!.cancel()
         }
         guard let url = URL(string:"https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)&language=ru-RU&page=\(page)") else {return assertionFailure()}
         session = URLSession.shared.dataTask(with: URLRequest(url: url), completionHandler: {data, _, _ in
             guard
                 let data = data,
                 let dict = try? JSONSerialization.jsonObject (with: data, options: .json5Allowed) as? [String: Any],
                 let results = dict["results"] as? [[String: Any]]
             else { return }
             let movies: [Movie] = results.map { params in
                 let title = params["title"] as! String
                 let imagePath = params["poster_path"] as? String
                 let id = params["id"] as? Int
                 let path = self.loadMoviePage(id: id!)
                 return Movie(title: title, posterPath: imagePath,
                    path: path
                )
             }
             self.loadImagesForMovies(movies) { movies in
                 self.movies.append(contentsOf: movies)
                 self.pageCount += 1
                 DispatchQueue.main.async {
                     self.tableView.reloadData()
                 }
             }
         })
         session!.resume()
     }


 }

 extension ScrollViewController : UITableViewDataSource {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return movies.count
     }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.identifier, for: indexPath) as! MovieCell
         cell.configure(movie: movies[indexPath.row])
         return cell
     }
 }

 extension ScrollViewController: UITableViewDataSourcePrefetching {
     func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
         let index = indexPaths[0]
         let page = (index.row + 1) / 20
         DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
             if (self.pageCount < page + 1) {
                 self.loadMovies(page: page + 1)
             }
         }
     }
 }
extension ScrollViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = URL(string: movies[indexPath.row].path!) {
            let controller = WebViewController()
            controller.url = url
            navigationController?.modalPresentationStyle = .fullScreen
            navigationController!.pushViewController(controller, animated: true)
        }
    }
 }
