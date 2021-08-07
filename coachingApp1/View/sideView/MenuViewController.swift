//
//  MenuViewController.swift
//
//  Created by 刈田修平 on 2020/11/21.
//  Copyright © 2020 刈田修平. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Firebase
import FirebaseStorage
import FirebaseMessaging
import Photos
import MobileCoreServices
import AssetsLibrary

class MenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var menuArray = ["プロフィール情報","利用規約","プライバシーポリシー","通知設定"]
    var purchaseExpiresDate: Int?
    
    var ActivityIndicator: UIActivityIndicatorView!
    var initilizedView: UIView = UIView()

    @IBOutlet var menuView: UIView!
    @IBOutlet var TableView: UITableView!
    @IBOutlet var userName: UILabel!
    @IBOutlet weak var purchaseStatusLabel: UILabel!
    @IBOutlet weak var purchaseStatusView: UIView!

//    @IBOutlet var purchaseStatus: UILabel!
    
    let currentUid:String = Auth.auth().currentUser!.uid
    let Ref = Database.database().reference()

    override func viewDidLoad() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        initilize()
        TableView.dataSource = self
        TableView.delegate = self
        loadData()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fcmStatus()
        self.TableView.reloadData()
        super.viewWillAppear(animated)
        
    }
    func fcmStatus(){
        let ref1 = Ref.child("user").child("\(self.currentUid)").child("notification")
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {setting in
            if setting.authorizationStatus == .authorized {
                self.menuArray[3] = "通知設定：現在ON"
                let token:[String:AnyObject]=["fcmToken":Messaging.messaging().fcmToken,"fcmTokenStatus":"1"] as [String : AnyObject]
                ref1.updateChildValues(token)
                print("許可")
            }
            else {
                self.menuArray[3] = "通知設定：現在OFF"
                let token:[String:AnyObject]=["fcmToken":Messaging.messaging().fcmToken,"fcmTokenStatus":"0"] as [String : AnyObject]
                ref1.updateChildValues(token)
                print("未許可")
            }
        })
    }

    func initilize(){
        let viewWidth = UIScreen.main.bounds.width
        let viewHeight = UIScreen.main.bounds.height
        initilizedView.frame = CGRect.init(x: 0, y: 0, width: viewWidth, height: viewHeight)
        initilizedView.backgroundColor = .white
        
        ActivityIndicator = UIActivityIndicatorView()
        ActivityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        ActivityIndicator.center = self.view.center
        ActivityIndicator.color = .gray
        ActivityIndicator.startAnimating()

        // クルクルをストップした時に非表示する
        ActivityIndicator.hidesWhenStopped = true

        //Viewに追加
        initilizedView.addSubview(ActivityIndicator)
        view.addSubview(initilizedView)
    }

    func loadData(){
        
//        self.purchaseStatus.text = "課金なし"
//        self.purchaseStatus.backgroundColor = #colorLiteral(red: 0.01579796895, green: 0.756948173, blue: 0.4846590757, alpha: 1)
        let ref = Ref.child("user").child("\(self.currentUid)").child("profile")
        ref.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key1 = value?["userName"] as? String ?? ""
            self.userName.text = "ようこそ、 "+"\(key1)"+" さん"
        })
        ref.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["purchaseExpiresDate"] as? Int
            if key != nil{
                self.purchaseExpiresDate = key
                let timeInterval = NSDate().timeIntervalSince1970
                if Int(timeInterval) > self.purchaseExpiresDate ?? 0{
                    self.purchaseStatusLabel.text = "現在加入中の課金プランはありません"
                    self.purchaseStatusView.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                }else{
                    self.purchaseStatusLabel.text = "ベージックプラン加入中"
                    self.purchaseStatusView.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.3294117647, blue: 0.3215686275, alpha: 1)
                }
            }
        })
        self.initilizedView.removeFromSuperview()

    }
    
    func numberOfSections(in myTableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ myTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count
    }
                
       
    func tableView(_ myTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = self.TableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath as IndexPath) as? menuTableViewCell
        cell!.menu.text = self.menuArray[indexPath.row]
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            performSegue(withIdentifier: "myProfile", sender: nil)
        }else if indexPath.row == 1{
            performSegue(withIdentifier: "appRule", sender: nil)
        }else if indexPath.row == 2{
            performSegue(withIdentifier: "privacyPolicy", sender: nil)
        }else{
            // OSの通知設定画面へ遷移
            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    // iOS10以降
                    UIApplication.shared.open(url, options: [: ], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
    }

    // メニューエリア以外タップ時の処理
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            if touch.view?.tag == 1 {
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0,
                    options: .curveEaseIn,
                    animations: {
                        self.menuView.layer.position.x = -self.menuView.frame.width
                },
                    completion: { bool in
                        self.dismiss(animated: true, completion: nil)
                }
                )
            }
        }
    }
}
