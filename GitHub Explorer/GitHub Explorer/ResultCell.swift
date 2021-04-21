//
//  ResultCell.swift
//  GitHub Explorer
//
//  Created by Daniel Wahby on 19/04/2021.
//

import UIKit

class ResultCell: UITableViewCell {

//    MARK: IBOutlet
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var repositoryName: UILabel!
    
    @IBOutlet weak var repositoryOwner: UILabel!
    @IBOutlet weak var creationDate: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
