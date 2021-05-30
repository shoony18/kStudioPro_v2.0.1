//
//  anaResultTableViewCell.swift
//  coachingApp1
//
//  Created by 刈田修平 on 2021/05/29.
//

import UIKit

class anaResultTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var anaCriteriaTitle: UILabel!
    @IBOutlet weak var anaPointValue_text: UILabel!
    @IBOutlet weak var anaCriteriaIcon: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
