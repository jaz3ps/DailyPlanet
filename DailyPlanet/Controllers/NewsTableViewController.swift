//
//  NewsTableViewController.swift
//  DailyPlanet
//
//  Created by jazeps.ivulis on 24/11/2021.
//

import UIKit

class NewsTableViewController: UITableViewController {
    
    var newsItems: [NewsItem] = []
    var keyword = "country=us"
    var category = "&category=general"
    var apiKey = "10cc685dabbc4e449c5bf0bff4f5fcdb"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "General news"
        handleGetData(keyword: keyword)
    }

 
    //MARK: - Switch to dark/light mode
    @IBAction func switchModeButtonTapped(_ sender: Any) {
        var modeOn: String
        var modeOff: String
        
        if self.traitCollection.userInterfaceStyle == .dark {
            modeOn = "Dark"
            modeOff = "Light"
        } else {
            modeOn = "Light"
            modeOff = "Dark"
        }
        
        let settings = UIAlertController(title: "\(modeOn) mode is on", message: "Want to switch to \(modeOff) mode?\nPress button \"Open settings\" below and do it in phone settings.", preferredStyle: .actionSheet)
        
        let phoneSettings = UIAlertAction(title: "Open settings", style: .default) { Action in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {return}
            
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL, options: [:]) {
                    success in
                }
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        settings.addAction(phoneSettings)
        settings.addAction(cancel)
        
        present(settings, animated: true, completion: nil)
    }
    
    
    //MARK: - Choose category button
    @IBAction func changeCategoryButtonTapped(_ sender: Any) {
        let categoryMenu = UIAlertController(title: "Choose news category", message: .none, preferredStyle: .actionSheet)
        let business = UIAlertAction(title: "Business", style: .default) { Action in
            self.category = "&category=business"
            self.navigationItem.title = "Business news"
            self.handleGetData(keyword: self.keyword, category: self.category)
        }
        let entertainment = UIAlertAction(title: "Entertainment", style: .default) { Action in
            self.category = "&category=entertainment"
            self.navigationItem.title = "Entertainment news"
            self.handleGetData(keyword: self.keyword, category: self.category)
        }
        let general = UIAlertAction(title: "General", style: .default) { Action in
            self.category = "&category=general"
            self.navigationItem.title = "General news"
            self.handleGetData(keyword: self.keyword, category: self.category)
        }
        let health = UIAlertAction(title: "Health", style: .default) { Action in
            self.category = "&category=health"
            self.navigationItem.title = "Health news"
            self.handleGetData(keyword: self.keyword, category: self.category)
        }
        let science = UIAlertAction(title: "Science", style: .default) { Action in
            self.category = "&category=science"
            self.navigationItem.title = "Science news"
            self.handleGetData(keyword: self.keyword, category: self.category)
        }
        let sports = UIAlertAction(title: "Sports", style: .default) { Action in
            self.category = "&category=sports"
            self.navigationItem.title = "Sports news"
            self.handleGetData(keyword: self.keyword, category: self.category)
        }
        let technology = UIAlertAction(title: "Technology", style: .default) { Action in
            self.category = "&category=technology"
            self.navigationItem.title = "Technology news"
            self.handleGetData(keyword: self.keyword, category: self.category)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        categoryMenu.addAction(business)
        categoryMenu.addAction(entertainment)
        categoryMenu.addAction(general)
        categoryMenu.addAction(health)
        categoryMenu.addAction(science)
        categoryMenu.addAction(sports)
        categoryMenu.addAction(technology)
        categoryMenu.addAction(cancel)
        
        present(categoryMenu, animated: true, completion: nil)
    }
    

    //MARK: - Pull to refresh action
    @IBAction func refresh(_ sender: UIRefreshControl) {
        handleGetData(keyword: keyword, category: category)
    }
    
    
    //MARK: - Get data
    func handleGetData(keyword: String, category: String? = nil){
        refreshControl?.beginRefreshing()
        let jsonUrl = "https://newsapi.org/v2/top-headlines?\(keyword)\(category ?? "")&apiKey=\(apiKey)"
        
        guard let url = URL(string: jsonUrl) else {return}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        
        URLSession(configuration: config).dataTask(with: urlRequest) { data, response, error in
            if error != nil {
                print((error?.localizedDescription)!)
                self.basicAlert(title: "Error!", message: "\(String(describing: error?.localizedDescription))")
                return
            }
            
            guard let data = data else {
                self.basicAlert(title: "Error!", message: "Something went wrong, no data.")
                return
            }
            
            do{
                let jsonData = try JSONDecoder().decode(Articles.self, from: data)
                self.newsItems = jsonData.articles
                DispatchQueue.main.async {
                    print("self.newsItems:", self.newsItems)
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            }catch{
                print("err:", error)
            }
    
        }.resume()
    }
    
 
    //MARK: - Number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsItems.count
    }

    
    //MARK: - Write item in cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as? NewsTableViewCell else {return UITableViewCell()}

        let item = newsItems[indexPath.row]
        cell.newsTitleLabel.text = item.title
        cell.newsTitleLabel.numberOfLines = 0
        cell.newsImageView.sd_setImage(with:URL(string: item.urlToImage ?? ""), placeholderImage: UIImage(named: "news.png"))

        return cell
    }
    
    
    //MARK: - Row height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    
    //MARK: - Navigate to article preview
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storybord = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let vc = storybord.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {return}
        let item = newsItems[indexPath.row]
        vc.newsImage = item.urlToImage ?? ""
        vc.titleString = item.title
        vc.webUrlString = item.url
        vc.contentString = item.description ?? ""
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
