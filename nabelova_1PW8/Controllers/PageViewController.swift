//
//  PageViewController.swift
//  nabelova_1PW8
//
//  Created by Наталья Белова on 20.03.2022.
//

import Foundation

import UIKit

 class PageViewController : UIViewController{

     private let apiKey = "fc57145e7f23876373951e70a3dd0560"
     private let tableView = UITableView()
     private let pickerView = UIPickerView()
     private var session: URLSessionDataTask!
     private var movies = [Movie]()
     private let pages = ["1", "2", "3", "4", "5"]

     override func viewDidLoad() {
         super.viewDidLoad()
         view.backgroundColor = .white
         configureUI()
         DispatchQueue.global(qos: .background).async { [weak self] in
             self?.loadMovies(page: 1)
         }
         tableView.rowHeight = 250
     }
     var window : UIWindow?
     override func viewDidAppear(_ animated: Bool) {
        view.backgroundColor = .white
        configureUI()
     }

     private func configureUI(){
         view.addSubview(tableView)
         navigationItem.titleView = pickerView
         let rotationAngle: CGFloat! = -90  * (.pi / 180)
         pickerView.transform = CGAffineTransform(rotationAngle: rotationAngle)
         pickerView.frame = CGRect(x: -150, y: 100.0, width: view.bounds.width + 300, height: 200)
         tableView.delegate = self
         tableView.dataSource = self
         pickerView.delegate = self
         pickerView.dataSource = self
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

     private func loadMoviePage(id: Int) -> String {
              return "https://www.themoviedb.org/movie/\(id)"
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
                 let backdropPath = self.loadMoviePage(id: id!)
                return Movie(
                    title: title,
                    posterPath: imagePath,
                    path: backdropPath
                )
             }
             self.loadImagesForMovies(movies) { movies in
                 self.movies = movies
                 DispatchQueue.main.async {
                     self.tableView.reloadData()
                 }
             }
         })
         session.resume()
     }

 }

 extension PageViewController : UITableViewDataSource {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return movies.count
     }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.identifier, for: indexPath) as! MovieCell
         cell.configure(movie: movies[indexPath.row])
         return cell
     }
 }

 extension PageViewController: UIPickerViewDelegate {
     func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
         DispatchQueue.global(qos: .background).async { [weak self] in
             self?.loadMovies(page: row + 1)
         }
     }

 }

 extension PageViewController: UIPickerViewDataSource {
     func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return 1
     }

     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return pages.count
     }


     func pickerView(_ pickerView: UIPickerView, viewForRow row: Int,
                     forComponent component: Int, reusing view: UIView?) -> UIView {
         let view = UIView()
         view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
         let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
         label.textColor = .darkGray
         label.text = pages[row]
         label.textAlignment = .center
         view.addSubview(label)
         let rotationAngle: CGFloat! = 90  * (.pi / 180)
         view.transform = CGAffineTransform(rotationAngle: rotationAngle)
         return view
     }

 }
extension PageViewController: UITableViewDelegate {

     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

         if let url = URL(string: movies[indexPath.row].path!) {
             let controller = WebViewController()
             controller.url = url
             navigationController?.modalPresentationStyle = .fullScreen
             navigationController!.pushViewController(controller, animated: true)
         }
     }
 }
