//
//  loginViewController.swift
//  track_online
//
//  Created by 刈田修平 on 2019/11/04.
//  Copyright © 2019 刈田修平. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import FirebaseMessaging

class loginViewController: UIViewController,FUIAuthDelegate {
    
    @IBOutlet weak var AuthButton: UIButton!
    var authUI: FUIAuth { get { return FUIAuth.defaultAuthUI()!}}
    var firstLogin:String?
    
    let providers: [FUIAuthProvider] = [
        FUIEmailAuth()
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.authUI.delegate = self
        self.authUI.providers = providers
        AuthButton.addTarget(self,action: #selector(self.AuthButtonTapped(sender:)),for: .touchUpInside)
    }
    
    @objc func AuthButtonTapped(sender : AnyObject) {
        let authViewController = self.authUI.authViewController()
        authViewController.modalPresentationStyle = .fullScreen
        self.present(authViewController, animated: true, completion: nil)
    }
    public func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?){
        if error == nil {
            self.performSegue(withIdentifier: "goHome", sender: self)
            if let bundlePath = Bundle.main.path(forResource: "FirebaseAuthUI", ofType: "strings") {
                let bundle = Bundle(path: bundlePath)
                authUI.customStringsBundle = bundle
            }
            let currentUid:AnyObject = Auth.auth().currentUser!.uid as AnyObject
            let currentName:AnyObject = Auth.auth().currentUser!.displayName! as AnyObject
            let currentEmail:AnyObject = Auth.auth().currentUser!.email! as AnyObject
            
            UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {setting in
                if setting.authorizationStatus == .authorized {
                    let data1:[String:AnyObject]=["fcmToken":Messaging.messaging().fcmToken,"fcmTokenStatus":"1"] as [String : AnyObject]
                    let data2:[String:AnyObject]=["userName":"\(currentName)","email":"\(currentEmail)","uid":"\(currentUid)","appRuleFlag":"0","purchaseExpiresDate":0,"purchaseStatus":"課金なし"] as [String : AnyObject]
                    
                    let dbRef = Database.database().reference()
                    dbRef.child("user").child(currentUid as! String).child("notification").updateChildValues(data1)
                    dbRef.child("user").child(currentUid as! String).child("profile").updateChildValues(data2)
                    print("許可")
                }
                else {
                    let data1:[String:AnyObject]=["fcmToken":Messaging.messaging().fcmToken,"fcmTokenStatus":"0"] as [String : AnyObject]
                    let data2:[String:AnyObject]=["userName":"\(currentName)","email":"\(currentEmail)","uid":"\(currentUid)","appRuleFlag":"0","purchaseExpiresDate":0,"purchaseStatus":"課金なし"] as [String : AnyObject]
                    
                    let dbRef = Database.database().reference()
                    dbRef.child("user").child(currentUid as! String).child("notification").updateChildValues(data1)
                    dbRef.child("user").child(currentUid as! String).child("profile").updateChildValues(data2)
                    print("未許可")
                }
            })
            
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "goAppRule" {
            let nextData: appRuleViewController = segue.destination as! appRuleViewController
            nextData.modalPresentationStyle = .fullScreen
        } else {
            // Fallback on earlier versions
        }
        
        
        if segue.identifier == "goHome" {
            if let vc = segue.destination as? tabbarViewController {
                vc.modalPresentationStyle = .fullScreen
            }
        }
    }
    //    func postToken(data:[String: AnyObject]){
    //        let currentUid:String = Auth.auth().currentUser!.uid
    //
    //        print("FCM Token:\(Token)")
    //        let dbRef = Database.database().reference()
    //        dbRef.child("user").child(currentUid).updateChildValues(Token)
    //        dbRef.child("fcmToken").child(currentUid).updateChildValues(Token)
    //    }
}
