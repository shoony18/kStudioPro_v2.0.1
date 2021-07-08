//
//  practiceURLViewController.swift
//  coachingApp1
//
//  Created by 刈田修平 on 2021/07/04.
//

import UIKit
import WebKit

class practiceURLViewController: UIViewController {
    
    var practiceURL: String?
    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        let url = URL(string: "\(practiceURL!)")
        let request = URLRequest(url:  url!)
        webView.load(request)
        super.viewDidLoad()
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
