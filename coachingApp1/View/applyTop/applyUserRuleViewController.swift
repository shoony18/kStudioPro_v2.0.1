//
//  applyUserRuleViewController.swift
//  track_online
//
//  Created by 刈田修平 on 2020/10/24.
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
import StoreKit

class applyUserRuleViewController: UIViewController,SKProductsRequestDelegate,SKPaymentTransactionObserver {
    
    var myProduct:SKProduct?
    var purchaseExpiresDate: Int?
    var latestExpireDate:Int = 0
    
    @IBOutlet var ruleText: UILabel!
    @IBOutlet var approveFlagButton: UIButton!
    @IBOutlet var goToButton: UIButton!
    @IBOutlet var closePageButton: UIBarButtonItem!
    @IBOutlet var homeText: UILabel!
    
    var approveFlag:Int = 0
    var backFlag:String?
    let Ref = Database.database().reference()
    let currentUid:String = Auth.auth().currentUser!.uid
    
    override func viewDidLoad() {
        fetchProducts()
        fetchPurchaseStatus()
        loadData()
        goToButton.isEnabled = false
        super.viewDidLoad()
    }
    func loadData(){
        let ref = Ref.child("setting").child("inAppText")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["homeText4"] as? String ?? ""
            self.homeText.text = key
        })
    }
    @IBAction func tapApproveFlagButton(_ sender: Any) {
        if approveFlag == 0{
            approveFlag = 1
            let picture = UIImage(named: "checkFlag_fill")
            self.approveFlagButton.setImage(picture, for: .normal)
            goToButton.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            goToButton.backgroundColor = UIColor(red: 83/255, green: 166/255, blue: 165/255, alpha: 1)
            goToButton.isEnabled = true
        }else if approveFlag == 1{
            approveFlag = 0
            let picture = UIImage(named: "checkFlag")
            self.approveFlagButton.setImage(picture, for: .normal)
            goToButton.tintColor = UIColor(red: 83/255, green: 166/255, blue: 165/255, alpha: 1)
            goToButton.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            goToButton.isEnabled = false
        }
    }
    
    @IBAction func closePage(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func fetchPurchaseStatus(){
        receiptValidation(url: "https://buy.itunes.apple.com/verifyReceipt")
        let ref = Ref.child("user").child("\(self.currentUid)")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["purchaseExpiresDate"] as? Int ?? 0
            self.purchaseExpiresDate = key
        })
    }
    func fetchProducts(){
        let productIdentifier:Set = ["com.kStudioPro.AutoRenewingSubscription_basic"]
        // 製品ID
        let productsRequest: SKProductsRequest = SKProductsRequest.init(productIdentifiers: productIdentifier)
        productsRequest.delegate = self
        productsRequest.start()
        
    }
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products.first{
            myProduct = product
            print(myProduct)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .failed:
                queue.finishTransaction(transaction)
                print("Transaction Failed \(transaction)")
                self.closePageButton.isEnabled = true
                self.approveFlagButton.isEnabled = true
                self.goToButton.setTitle("購入する", for: .normal)
                goToButton.borderColor = UIColor(red: 83/255, green: 166/255, blue: 165/255, alpha: 1)
                self.goToButton.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
                self.goToButton.backgroundColor = UIColor(red: 83/255, green: 166/255, blue: 165/255, alpha: 1)
            case .purchased:
                self.closePageButton.isEnabled = true
                self.approveFlagButton.isEnabled = false
                self.goToButton.isEnabled = true
                self.goToButton.setTitle("トップページに戻る", for: .normal)
                self.goToButton.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
                self.goToButton.backgroundColor = UIColor(red: 83/255, green: 166/255, blue: 165/255, alpha: 1)
                self.backFlag = "1"
                
                receiptValidation(url: "https://buy.itunes.apple.com/verifyReceipt")
                queue.finishTransaction(transaction)
                print("Transaction purchased: \(transaction)")
                print("Transaction purchased できたよ")
            case .restored:
                self.closePageButton.isEnabled = true
                self.approveFlagButton.isEnabled = true
                self.goToButton.setTitle("購入する", for: .normal)
                self.goToButton.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
                self.goToButton.backgroundColor = UIColor(red: 83/255, green: 166/255, blue: 165/255, alpha: 1)
                
                //                receiptValidation(url: "https://buy.itunes.apple.com/verifyReceipt")
                queue.finishTransaction(transaction)
                print("Transaction restored: \(transaction)")
                self.performSegue(withIdentifier: "applyFormNavigationSegue", sender: nil)
            case .deferred, .purchasing:
                print("Transaction in progress: \(transaction)")
            @unknown default:
                break
            }
        }
    }
    // Appleサーバーに問い合わせてレシートを取得
    func receiptValidation(url: String) {
        print("sandbox_receiptValidation")
        
        let receiptUrl = Bundle.main.appStoreReceiptURL
        guard let receiptData = try? Data(contentsOf: receiptUrl!) else {
            print("error")
            return
        }
        
        let requestContents = [
            "receipt-data": receiptData.base64EncodedString(options: .endLineWithCarriageReturn),
            "password": "d6eb0bc554844ce6b6774924b66e8359" // appstoreconnectからApp 用共有シークレットを取得しておきます
        ]
        
        let requestData = try! JSONSerialization.data(withJSONObject: requestContents, options: .init(rawValue: 0))
        
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"content-type")
        request.timeoutInterval = 5.0
        request.httpMethod = "POST"
        request.httpBody = requestData
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { [self](data, response, error) -> Void in
            
            guard let jsonData = data else {
                return
            }
            
            do {
                let json:Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: jsonData, options: .init(rawValue: 0)) as! Dictionary<String, AnyObject>
                
                let status:Int = json["status"] as! Int
                if status == receiptErrorStatus.invalidReceiptForProduction.rawValue {
                    print(status)
                    self.receiptValidation(url: "https://sandbox.itunes.apple.com/verifyReceipt")
                    print("sandboxだよ")
                }
                
                guard let receipts:Dictionary<String, AnyObject> = json["receipt"] as? Dictionary<String, AnyObject> else {
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
    private func provideFunctions(receipts:Dictionary<String, AnyObject>) {
        let in_apps = receipts["in_app"] as! Array<Dictionary<String, AnyObject>>
        
        for in_app in in_apps {
            let receiptExpireDateMs = Int(in_app["expires_date_ms"] as? String ?? "") ?? 0
            let receiptExpireDateS = receiptExpireDateMs / 1000
            if receiptExpireDateS > latestExpireDate {
                latestExpireDate = receiptExpireDateS
            }
        }
        UserDefaults.standard.set(latestExpireDate, forKey: "expireDate")
        print(latestExpireDate)
        let timeInterval = NSDate().timeIntervalSince1970
        if Int(timeInterval) < self.latestExpireDate{
            let data = ["purchaseExpiresDate":latestExpireDate,"purchaseStatus":"プレミアム課金中"] as [String : Any]
            let ref = self.Ref.child("user").child("\(self.currentUid)").child("profile")
            ref.updateChildValues(data)
        }else{
            let data = ["purchaseExpiresDate":latestExpireDate,"purchaseStatus":"課金なし"] as [String : Any]
            let ref = self.Ref.child("user").child("\(self.currentUid)").child("profile")
            ref.updateChildValues(data)
        }
    }
    @IBAction func restore(_ sender: Any) {
        
        let alert: UIAlertController = UIAlertController(title: "確認", message: "以前購入した情報を復元しますか？", preferredStyle:  UIAlertController.Style.alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ [self]
            (action: UIAlertAction!) -> Void in
            self.closePageButton.isEnabled = false
            self.approveFlagButton.isEnabled = false
            self.goToButton.isEnabled = false
            print(self.latestExpireDate)
            let timeInterval = NSDate().timeIntervalSince1970
            if Int(timeInterval) < self.latestExpireDate{
                let request = SKReceiptRefreshRequest()
                request.delegate = self
                request.start()
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().restoreCompletedTransactions()
            }else{
                let alert: UIAlertController = UIAlertController(title: "確認", message: "有効な購入履歴はありません。", preferredStyle:  UIAlertController.Style.alert)
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.closePageButton.isEnabled = true
                    self.approveFlagButton.isEnabled = true
                })
                alert.addAction(defaultAction)
                present(alert, animated: true, completion: nil)
            }
        })
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            self.closePageButton.isEnabled = true
            self.approveFlagButton.isEnabled = true
            print("Cancel")
        })
        
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
    @IBAction func tappedButton(_ sender: Any) {
        if self.backFlag == "1"{
            self.dismiss(animated: true, completion: nil)
        }else{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "ベーシックプランに加入しますか？初回1ヶ月無料トライアル、以降月額1,950円です。", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ [self]
                (action: UIAlertAction!) -> Void in
                self.closePageButton.isEnabled = false
                self.approveFlagButton.isEnabled = false
                
                self.goToButton.setTitle("課金処理準備中", for: .normal)
                goToButton.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                goToButton.backgroundColor = #colorLiteral(red: 0.3729103804, green: 0.6191056967, blue: 0.9580503106, alpha: 1)
                
                guard  let myProduct = self.myProduct else {
                    return
                }
                if SKPaymentQueue.canMakePayments(){
                    let payment = SKPayment(product: myProduct)
                    SKPaymentQueue.default().add(self)
                    SKPaymentQueue.default().add(payment)
                }
            })
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                (action: UIAlertAction!) -> Void in
                self.closePageButton.isEnabled = true
                self.approveFlagButton.isEnabled = true
                self.goToButton.setTitle("購入する", for: .normal)
                self.goToButton.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
                self.goToButton.backgroundColor = UIColor(red: 83/255, green: 166/255, blue: 165/255, alpha: 1)
                print("Cancel")
            })
            
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "applyFormNavigationSegue") {
            if #available(iOS 13.0, *) {
                let nc: applyFormNavigationViewController = segue.destination as! applyFormNavigationViewController
                let nextView = nc.topViewController as! applyFormViewController
                nextView.viaAppRuleFlag = "1"
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
}
