//
//  RepoViewController.swift
//  GitHub Explorer
//
//  Created by Daniel Wahby on 21/04/2021.
//

import UIKit

class RepoViewController: UIViewController {
    
    @IBOutlet weak var repoImage: UIImageView!
    @IBOutlet weak var descriptionLabel:UILabel!
    @IBOutlet weak var ownerLabel:UILabel!
    @IBOutlet weak var followersLabel:UILabel!
    @IBOutlet weak var followingLabel:UILabel!
    var passedRepoName = ""
    var passedRepoOwner = ""
    var passedImageURL = ""
    var repoDescription = ""
    var followersCount = 0
    var followingCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = passedRepoName
        self.repoImage.image = self.setImageFromURL(passedImageURL)
        self.ownerLabel.text = "Owned by: \(passedRepoOwner)"
        self.descriptionLabel.text = repoDescription
        self.followersLabel.text = "\(followersCount) follower(s)"
        self.followingLabel.text = "\(followersCount) following"
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReposListScreen") as! ViewController
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalTransitionStyle = .crossDissolve
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated:true, completion: nil)
    }
}
