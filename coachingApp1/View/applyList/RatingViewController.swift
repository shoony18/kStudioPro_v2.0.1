//
//  RatingViewController.swift
//  coachingApp1
//
//  Created by 刈田修平 on 2021/05/05.
//

import UIKit
import Cosmos

class RatingViewController: UIViewController {

    @IBOutlet weak var cosmosStarRating: CosmosView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // star数のデフォルトを3.0に設定
        cosmosStarRating.rating = 3.0

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }

    @objc func endEditing() {
        view.endEditing(true)
    }
}

// textFieldに関する処理
extension RatingViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing()
        return true
    }
}
