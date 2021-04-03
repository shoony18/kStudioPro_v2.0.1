//
//  menuListTableViewCell.swift
//  coachingApp1
//
//  Created by 刈田修平 on 2021/03/13.
//

import UIKit

class menuListTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var memo: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet var poster: UILabel!
    @IBOutlet var ImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
