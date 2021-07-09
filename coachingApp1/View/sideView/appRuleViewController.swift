//
//  appRuleViewController.swift
//  track_online
//
//  Created by 刈田修平 on 2019/12/01.
//  Copyright © 2019 刈田修平. All rights reserved.
//

import UIKit
import WebKit
import Firebase

class appRuleViewController: UIViewController {
    var window: UIWindow?
    let currentUid:String = Auth.auth().currentUser!.uid

    override func viewDidLoad() {
        self.navigationItem.hidesBackButton = true
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        let ref = Database.database().reference().child("user").child("\(self.currentUid)").child("profile")
        let data = ["appRuleFlag":"1" as Any] as [String : Any]
        ref.updateChildValues(data, withCompletionBlock:{error,ref in if error == nil{
//            print("コメントをアップロードしました")
        }else{
            }
        })
//        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
//        self.window = UIWindow(frame: UIScreen.main.bounds)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let initialViewController = storyboard.instantiateViewController(withIdentifier:"mainView")
//        self.window?.rootViewController = initialViewController
//        self.window?.makeKeyAndVisible()
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
