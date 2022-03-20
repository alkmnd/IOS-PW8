//
//  ViewController.swift
//  nabelova_1PW8
//
//  Created by Наталья Белова on 20.03.2022.
//

import UIKit


class MoviesViewController: UIViewController {

    private let tableView = UITableView()
    private let apiKey = "fc57145e7f23876373951e70a3dd0560"
    private var movies = [Movie]()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        DispatchQueue.global(qos: .background).async {
            [weak self] in self?.loadMovies()
        }
    }
    private func configureUI() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.register(MovieCell.self, forCellReuseIdentifier: MovieCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.reloadData()
    }
    
    private func loadMovies() {
        guard let url = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=(apiKey)&language=ruRu") else {
            return assertionFailure("some problem with url")
        }
        let session = URLSession.shared.dataTask(with: URLRequest(url: url), completionHandler: { data, _, _ in
            guard
                let data = data,
                let dict = try? JSONSerialization.jsonObject(with: data, options: .json5Allowed)
                    as? [String: Any],
                let results = dict["result"] as? [[String: Any]]
            else {
                return
            }
            let movies:[Movie] = results.map {params in
                let title = params["title"] as! String
                let imagePath = params["poster_path"] as! String
                return Movie(title: title, posterPath: imagePath, poster: nil)
            }
            self.movies = movies
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        session.resume()
    }

}

extension MoviesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection secion: Int) -> Int {
        return movies.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.identifier, for: indexPath) as! MovieCell
        cell.configure(movie: movies[indexPath.row])
        return cell
    }
}
