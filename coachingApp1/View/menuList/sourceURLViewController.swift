//
//  sourceURLViewController.swift
//  coachingApp1
//
//  Created by 刈田修平 on 2021/03/14.
//

import UIKit
import WebKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class sourceURLViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!

    var webURL: String?
    let Ref = Database.database().reference()
    let currentUid:String = Auth.auth().currentUser!.uid

    override func viewDidLoad() {
        let url = URL(string: "\(webURL ?? "")")
        let request = URLRequest(url:  url!)
        webView.load(request)
        super.viewDidLoad()

        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
