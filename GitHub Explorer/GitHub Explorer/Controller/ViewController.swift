//
//  ViewController.swift
//  GitHub Explorer
//
//  Created by Daniel Wahby on 19/04/2021.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {
    
    //    MARK: IBOutlet
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultsTableView: UITableView!
    
    @IBOutlet weak var actvityIndicator: UIActivityIndicatorView!
    
    //    MARK: Variables
    var searchResults = [GitHubUser]()
    let group = DispatchGroup()
//    var extraInfo = [ExtraRepoInfo]()
    var filteredData: [GitHubUser]!
    var profileImages = [UIImage]()


    override func viewDidLoad() {
        super.viewDidLoad()
//        altImage = UIImageView(image: UIImage(named: "Alt"))
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.register(UINib(nibName: "ResultCell", bundle: nil), forCellReuseIdentifier: "ResultCell")
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.isUserInteractionEnabled = false
        fetchRepositories()
    }
    
    func fetchRepositories(){
        actvityIndicator.startAnimating()
        DispatchQueue.main.async {
            self.get("http://api.github.com/repositories")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5){
            print("Count is: ",self.searchResults.count)
            
            var i = 0
            while i < self.searchResults.count{
                var currentItem = self.searchResults.remove(at: i)
                let extraInfo = try! self.getExtra(urlString: currentItem.owner?.url ?? "")
                print(extraInfo)
                currentItem.extraInfo = extraInfo
                self.searchResults.append(currentItem)
                i += 1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+10){
            self.resultsTableView.reloadData()
            self.actvityIndicator.stopAnimating()
            self.searchBar.isUserInteractionEnabled = true
        }
    }

}
extension ViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchBar.isFirstResponder ? filteredData.count : searchResults.count
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        if searchText.count >= 2{
            filteredData = searchText.isEmpty ? searchResults :  searchResults.filter {
                $0.full_name?.contains(searchText) != nil
            }
            resultsTableView.reloadData()
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = resultsTableView.dequeueReusableCell(withIdentifier: "ResultCell") as! ResultCell
        cell.avatarImageView.image = profileImages[indexPath.row]
        cell.repositoryName.text = searchResults[indexPath.row].full_name
        cell.repositoryOwner.text = searchResults[indexPath.row].owner?.login
        cell.creationDate.text = searchResults[indexPath.row].extraInfo?.created_at ?? "DATE CREATED"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RepoScreen") as! RepoViewController
        vc.passedImageURL = searchResults[indexPath.row].owner?.avatar_url ?? ""
        vc.passedRepoName = searchResults[indexPath.row].full_name ?? "Repo"
        vc.passedRepoOwner = searchResults[indexPath.row].owner?.login ?? "Repo Owner"
        vc.repoDescription = searchResults[indexPath.row].description ?? "Repo Description"
        vc.followersCount =  searchResults[indexPath.row].extraInfo?.followers ?? 0
        vc.followingCount =  searchResults[indexPath.row].extraInfo?.following ?? 0
        
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalTransitionStyle = .crossDissolve
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated:true, completion: nil)
    }
    
}
extension ViewController{
    
    func get(_ urlString:String){
//        print(urlString)
        let url = URL(string: urlString) ?? URL(string: "")
        let results = [GitHubUser]()
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["Authorization":anotherToken]
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let users = try JSONDecoder().decode([GitHubUser].self, from: data)
                for user in users {
                    let nilOwner = Owner(login: "", avatar_url: "", url: "")
                    let nilFullName = "Full Name"
                    let nilDescription = ""
//                                   let extra = self.getExtra(url: (user.owner?.url!)!)
                    var currentUser = GitHubUser(full_name: user.full_name ?? nilFullName, owner: user.owner ?? nilOwner,description: user.description ?? nilDescription,extraInfo: ExtraRepoInfo())
                    var profileImage : UIImage?
                    profileImage  = self.setImageFromURL(currentUser.owner?.avatar_url ?? "")
                    self.profileImages.append((profileImage ?? UIImage(named: "Alt"))!)
                    self.searchResults.append(currentUser)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func getExtra(urlString:String)throws -> ExtraRepoInfo?{
        let url = URL(string: urlString ?? "")
        var currentInfo =  ExtraRepoInfo()
        var extraInfoDict =  NSMutableDictionary()
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["Authorization":anotherToken]
        request.allHTTPHeaderFields = ["User-Agent":anotherToken]
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                guard let JSON = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue: 0)) as? NSDictionary else {
                    print("Not a Dictionary")
                    return
                }
                extraInfoDict = NSMutableDictionary(dictionary: JSON)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        task.resume()
        currentInfo.created_at =  extraInfoDict["created_at"] as? String
        currentInfo.location = extraInfoDict["location"] as? String
        currentInfo.followers = extraInfoDict["followers"] as? Int
        currentInfo.following = extraInfoDict["following"] as? Int
        return currentInfo
    }
}

