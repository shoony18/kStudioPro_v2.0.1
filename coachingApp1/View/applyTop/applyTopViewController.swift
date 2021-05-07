//
//  applyTopViewController.swift
//  track_online
//
//  Created by 刈田修平 on 2020/08/18.
//  Copyright © 2020 刈田修平. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class applyTopViewController: UIViewController {

    var purchaseExpiresDate: Int?
    var ActivityIndicator: UIActivityIndicatorView!
    var initilizedView: UIView = UIView()

    let currentUid:String = Auth.auth().currentUser!.uid
    let currentUserName:String = Auth.auth().currentUser!.displayName ?? ""
    let currentUserEmail:String = Auth.auth().currentUser!.email ?? ""
    let Ref = Database.database().reference()
    @IBOutlet var name1: UILabel!
    @IBOutlet var intro1: UILabel!
    @IBOutlet var name2: UILabel!
    @IBOutlet var intro2: UILabel!
    @IBOutlet var homeText1: UILabel!
    @IBOutlet var homeText2: UILabel!
    @IBOutlet weak var homeText3: UILabel!
    
    override func viewDidLoad() {
        fcmStatus()
        initilize()
        loadData()
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        fetchPurchaseStatus()
        super.viewWillAppear(animated)
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
        let ref1 = Ref.child("coach").child("1")
        let ref2 = Ref.child("coach").child("2")
        let ref3 = Ref.child("setting")
        ref1.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key1 = value?["name"] as? String ?? ""
            let key2 = value?["intro"] as? String ?? ""
            self.name1.text = key1
            self.intro1.text = key2
        })
        ref2.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key1 = value?["name"] as? String ?? ""
            let key2 = value?["intro"] as? String ?? ""
            self.name2.text = key1
            self.intro2.text = key2
        })
        ref3.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key1 = value?["homeText1"] as? String ?? ""
            let key2 = value?["homeText2"] as? String ?? ""
            let key3 = value?["homeText3"] as? String ?? ""
            self.homeText1.text = key1
            self.homeText2.text = key2
            self.homeText3.text = key3
        })
    }
    func fcmStatus(){
        let ref1 = Ref.child("user").child("\(self.currentUid)")
        let ref2 = Ref.child("fcmToken").child("\(self.currentUid)")
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {setting in
            if setting.authorizationStatus == .authorized {
                let token:[String:AnyObject]=["userName":"\(self.currentUserName)","email":"\(self.currentUserEmail)","uid":"\(self.currentUid)","fcmToken":Messaging.messaging().fcmToken,"fcmTokenStatus":"1"] as [String : AnyObject]
                ref1.updateChildValues(token)
                ref2.updateChildValues(token)
                print("許可")
            }
            else {
                let token:[String:AnyObject]=["userName":"\(self.currentUserName)","email":"\(self.currentUserEmail)","uid":"\(self.currentUid)","fcmToken":Messaging.messaging().fcmToken,"fcmTokenStatus":"0"] as [String : AnyObject]
                ref1.updateChildValues(token)
                ref2.updateChildValues(token)
                print("未許可")
            }
        })
    }
    func fetchPurchaseStatus(){
        let ref = Ref.child("user").child("\(self.currentUid)")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["purchaseExpiresDate"] as? Int
            if key != nil{
                self.purchaseExpiresDate = key
                let timeInterval = NSDate().timeIntervalSince1970
                if Int(timeInterval) > self.purchaseExpiresDate ?? 0{
                    self.receiptValidation(url: "https://buy.itunes.apple.com/verifyReceipt")
                }
            }
            self.initilizedView.removeFromSuperview()
        })
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        let timeInterval = NSDate().timeIntervalSince1970
        if Int(timeInterval) < purchaseExpiresDate ?? 0{
            print("期限内")
            performSegue(withIdentifier: "purchasing", sender: nil)
        }else{
            print("期限切れ")
            performSegue(withIdentifier: "needToPurchase", sender: nil)
        }
    }
//    @IBAction func inviteButtonTapped(_ sender: Any) {
//
//        performSegue(withIdentifier: "toInvite", sender: nil)
//    }

    func receiptValidation(url: String) {
        let receiptUrl = Bundle.main.appStoreReceiptURL
        guard let receiptData = try? Data(contentsOf: receiptUrl!) else {
            print("error")
                return
        }
        let requestContents = [
            "receipt-data": receiptData.base64EncodedString(options: .endLineWithCarriageReturn),
            "password": "d6eb0bc554844ce6b6774924b66e8359" // appstoreconnectからApp 用共有シークレットを取得しておきます
        ]
//        print(requestContents)
        
        let requestData = try! JSONSerialization.data(withJSONObject: requestContents, options: .init(rawValue: 0))
        
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"content-type")
        request.timeoutInterval = 5.0
        request.httpMethod = "POST"
        request.httpBody = requestData
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            
            guard let jsonData = data else {
                return
            }
            
            do {
                let json:Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: jsonData, options: .init(rawValue: 0)) as! Dictionary<String, AnyObject>
                
                let status:Int = json["status"] as! Int
                if status == receiptErrorStatus.invalidReceiptForProduction.rawValue {
                    self.receiptValidation(url: "https://sandbox.itunes.apple.com/verifyReceipt")
                }
                
                guard let receipts:Array<Dictionary<String, AnyObject>> = json["latest_receipt_info"] as? Array<Dictionary<String, AnyObject>> else {
                    return
                }
                
                // 機能開放
                self.provideFunctions(receipts: receipts)
            } catch let error {
                print("SKPaymentManager : Failure to validate receipt: \(error)")
            }
        })
        task.resume()
    }
    enum receiptErrorStatus: Int {
        case invalidJson = 21000
        case invalidReceiptDataProperty = 21002
        case authenticationError = 21003
        case commonSecretKeyMisMatch = 21004
        case receiptServerNotWorking = 21005
        case invalidReceiptForProduction = 21007
        case invalidReceiptForSandbox = 21008
        case unknownError = 21010
    }
    func provideFunctions(receipts:Array<Dictionary<String, AnyObject>>) {
//        let in_apps = receipts["latest_receipt_info"] as! Array<Dictionary<String, AnyObject>>
        
        var latestExpireDate:Int = 0
        for receipt in receipts {
            let receiptExpireDateMs = Int(receipt["expires_date_ms"] as? String ?? "") ?? 0
            let receiptExpireDateS = receiptExpireDateMs / 1000
            if receiptExpireDateS > latestExpireDate {
                latestExpireDate = receiptExpireDateS
                print(latestExpireDate)
            }
            let demodata = receipt["expires_date"] as? String ?? ""
            print("demodata:\(demodata)")
        }
        UserDefaults.standard.set(latestExpireDate, forKey: "expireDate")
        let timeInterval = NSDate().timeIntervalSince1970
        self.purchaseExpiresDate = latestExpireDate
//        print(latestExpireDate)
        if Int(timeInterval) < latestExpireDate {
            let data = ["purchaseExpiresDate":latestExpireDate,"purchaseStatus":"プレミアム課金中"] as [String : Any]
            let ref = self.Ref.child("user").child("\(self.currentUid)")
            ref.updateChildValues(data)
        }else{
            let data = ["purchaseExpiresDate":latestExpireDate,"purchaseStatus":"課金なし"] as [String : Any]
            let ref = self.Ref.child("user").child("\(self.currentUid)")
            ref.updateChildValues(data)
        }
        //        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func logoutView(_ sender: Any) {

                let alert: UIAlertController = UIAlertController(title: "確認", message: "ログアウトしていいですか？", preferredStyle:  UIAlertController.Style.alert)

                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                    (action: UIAlertAction!) -> Void in

                    do{
                        try Auth.auth().signOut()

                        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)

                    }catch let error as NSError{
                        print(error)
                    }
                    print("OK")
                })
                let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("Cancel")
                })
                alert.addAction(cancelAction)
                alert.addAction(defaultAction)
                present(alert, animated: true, completion: nil)
            
    }
}
