//
//  MainTableViewCell.swift
//  reign
//
//  Created by Gerardo Villarroel on 31-05-22.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    //MARK: Controls
    @IBOutlet weak var mNewsTitle: UILabel!
    @IBOutlet weak var mAuthorAndTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}
