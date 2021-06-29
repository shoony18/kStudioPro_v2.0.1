//
//  anaResultCollectionViewCell.swift
//  coachingApp1
//
//  Created by 刈田修平 on 2021/06/12.
//

import UIKit

class anaResultCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var numberTitle: UILabel!
    @IBOutlet weak var anaCriteriaTitle: UILabel!
    @IBOutlet weak var anaPointFBContent: UILabel!
    @IBOutlet weak var anaCriteriaIcon: UIImageView!
    @IBOutlet weak var valueBarView: UIView!
    @IBOutlet weak var athleteValueBarView: UIView!
    @IBOutlet weak var userValueBarView: UIView!
    @IBOutlet weak var range_start: UILabel!
    @IBOutlet weak var range_end: UILabel!
    @IBOutlet weak var titleBar: UIView!
    @IBOutlet weak var anaCriteriaView: UIImageView!
    
    let label = UILabel()
    let label1 = UILabel()
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

}
