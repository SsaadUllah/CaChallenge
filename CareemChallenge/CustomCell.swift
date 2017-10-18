//
//  CustomCell.swift
//  CareemChallenge
//
//  Created by SSaad Ullah on 10/17/17.
//  Copyright © 2017 SSaad Ullah. All rights reserved.
//

import UIKit
import Cosmos

class CustomCell: UITableViewCell {

   
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var movieName: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var votesCount: UILabel!
    @IBOutlet weak var overView: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
