//
//  anaResultTableViewCell.swift
//  coachingApp1
//
//  Created by 刈田修平 on 2021/05/29.
//

import UIKit

class anaResultTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var numberTitle: UILabel!
    @IBOutlet weak var anaCriteriaTitle: UILabel!
    @IBOutlet weak var anaPointFBContent: UILabel!
    @IBOutlet weak var anaCriteriaIcon: UIImageView!
    @IBOutlet weak var valueBarView: UIView!
    @IBOutlet weak var athleteValueBarView: UIView!
    @IBOutlet weak var range_start: UILabel!
    @IBOutlet weak var range_end: UILabel!
    
    let label = UILabel()
    let label1 = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
