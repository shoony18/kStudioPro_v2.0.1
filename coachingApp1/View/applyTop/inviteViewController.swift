//
//  inviteViewController.swift
//  coachingApp1
//
//  Created by 刈田修平 on 2021/02/28.
//

import UIKit
import Firebase
import FirebaseStorage
import StoreKit

class inviteViewController: UIViewController,SKProductsRequestDelegate,SKPaymentTransactionObserver {

    @IBOutlet var teamIDTextField: UITextField!
    @IBOutlet var passCodeTextField: UITextField!
    @IBOutlet weak var cautionText: UILabel!
    @IBOutlet weak var homeText1: UILabel!
    @IBOutlet weak var homeText2: UILabel!
    @IBOutlet weak var homeText3: UILabel!
    @IBOutlet weak var homeText4: UILabel!
    @IBOutlet weak var personalUseButton: UIButton!
    @IBOutlet weak var userStatusLabel: UILabel!
    @IBOutlet weak var userStatusView: UIView!
    var teamIDArray = [String]()
    var passCodeArray = [String]()
    var selectedTeamID:String?
    var applyStatus:String?
    var userStatus:String?

    let Ref = Database.database().reference()

    let currentUid:String = Auth.auth().currentUser!.uid
    var ActivityIndicator: UIActivityIndicatorView!
    var initilizedView: UIView = UIView()

    var myProduct:SKProduct?
    var purchaseExpiresDate: Int?

    var window: UIWindow?

    override func viewDidLoad() {
        initilize()
        fetchPurchaseStatus()
        fetchProducts()
        appRuleView()
        loadData()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        fetchPurchaseStatus()
        super.viewWillAppear(animated)
    }
    
    func appRuleView(){
        let ref1 = Database.database().reference().child("user").child("\(currentUid)").child("profile")
        ref1.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["appRuleFlag"] as? String ?? ""
            if key == "1"{
            }else{
                self.performSegue(withIdentifier: "goAppRule", sender: nil)
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
        let ref = Ref.child("team").child("list")
        ref.observeSingleEvent(of: .value, with: { [self](snapshot) in
            if let snapdata = snapshot.value as? [String:NSDictionary]{
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    if let key = snap!["teamID"] as? String {
                        self.teamIDArray.append(key)
                        print(self.teamIDArray)
                    }
                }
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    if let key = snap!["passcode"] as? String {
                        self.passCodeArray.append(key)
                        print(self.passCodeArray)
                    }
                }
            }
        })
        let ref1 = Ref.child("setting").child("inAppText")
        ref1.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key1 = value?["homeText1"] as? String ?? ""
            let key2 = value?["homeText2"] as? String ?? ""
            let key3 = value?["homeText3"] as? String ?? ""
            let key4 = value?["homeText4"] as? String ?? ""
//            self.homeText1.text = key1
            self.homeText2.text = key1 + "\n" + key2
            self.homeText3.text = key3
            self.homeText4.text = key4
            self.initilizedView.removeFromSuperview()
        })
        let ref2 = Ref.child("user").child("\(currentUid)").child("profile")
        ref2.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["teamID"] as? String ?? ""
            self.teamIDTextField.text = key
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
                self.personalUseButton.setTitle("ベージックプランに加入する", for: .normal)
                self.personalUseButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                self.personalUseButton.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.3294117647, blue: 0.3215686275, alpha: 1)
            case .purchased:
                self.userStatusLabel.text = "ベージックプラン加入中"
                self.userStatusView.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.3294117647, blue: 0.3215686275, alpha: 1)
                self.userStatus = "1"
                self.personalUseButton.setTitle("個人利用で解析申込", for: .normal)
                self.personalUseButton.backgroundColor = #colorLiteral(red: 0.8, green: 0.6078431373, blue: 0.07843137255, alpha: 1)

                receiptValidation(url: "https://buy.itunes.apple.com/verifyReceipt")
                queue.finishTransaction(transaction)
                print("Transaction purchased: \(transaction)")
                print("Transaction purchased できたよ")
            case .restored:
                self.userStatusLabel.text = "ベージックプラン加入中"
                self.userStatusView.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.3294117647, blue: 0.3215686275, alpha: 1)
                self.userStatus = "1"
                self.personalUseButton.setTitle("個人利用で解析申込", for: .normal)
                self.personalUseButton.backgroundColor = #colorLiteral(red: 0.8, green: 0.6078431373, blue: 0.07843137255, alpha: 1)

                //                receiptValidation(url: "https://buy.itunes.apple.com/verifyReceipt")
                queue.finishTransaction(transaction)
                print("Transaction restored: \(transaction)")
//                self.performSegue(withIdentifier: "applyFormNavigationSegue", sender: nil)
            case .deferred, .purchasing:
                print("Transaction in progress: \(transaction)")
            @unknown default:
                break
            }
        }
    }
    
    func fetchPurchaseStatus(){
        self.userStatus = "0"
        self.userStatusLabel.text = "現在、加入中の課金プランはありません"
        self.userStatusView.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        let ref = Ref.child("user").child("\(self.currentUid)").child("profile")
        ref.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["purchaseExpiresDate"] as? Int
            if key != nil{
                self.purchaseExpiresDate = key
                let timeInterval = NSDate().timeIntervalSince1970
                if Int(timeInterval) > self.purchaseExpiresDate ?? 0{
                    self.userStatus = "0"
                    self.receiptValidation(url: "https://buy.itunes.apple.com/verifyReceipt")
                }else{
                    self.userStatusLabel.text = "ベージックプラン加入中"
                    self.userStatusView.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.3294117647, blue: 0.3215686275, alpha: 1)
                    self.userStatus = "1"
                    self.personalUseButton.setTitle("個人利用で解析申込", for: .normal)
                    self.personalUseButton.backgroundColor = #colorLiteral(red: 0.8, green: 0.6078431373, blue: 0.07843137255, alpha: 1)
                }
            }
            self.initilizedView.removeFromSuperview()
        })
    }

    func receiptValidation(url: String) {
        let receiptUrl = Bundle.main.appStoreReceiptURL
        guard let receiptData = try? Data(contentsOf: receiptUrl!) else {
            print("error")
                return
        }
        let requestContents = [
            "receipt-data": receiptData.base64EncodedString(options: .endLineWithCarriageReturn),
            "password": "07db20daaee04e8cabebc5a7be9ef3bf" // appstoreconnectからApp 用共有シークレットを取得しておきます
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
            self.userStatus = "1"
            let data = ["purchaseExpiresDate":latestExpireDate,"purchaseStatus":"課金中"] as [String : Any]
            let ref = self.Ref.child("user").child("\(self.currentUid)").child("profile")
            ref.updateChildValues(data)
        }else{
            self.userStatus = "0"
            let data = ["purchaseExpiresDate":latestExpireDate,"purchaseStatus":"課金なし"] as [String : Any]
            let ref = self.Ref.child("user").child("\(self.currentUid)").child("profile")
            ref.updateChildValues(data)
        }
        //        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func buttonTapped(_ sender: Any) {
        applyStatus = "団体利用"
        self.view.endEditing(true)
        if teamIDArray.contains("\(teamIDTextField.text ?? "")"){
            let int:Int = teamIDArray.firstIndex(of: teamIDTextField.text ?? "")!
            if passCodeArray[int] == passCodeTextField.text{
                let ref1 = Ref.child("user").child("\(currentUid)").child("profile")
                let data = ["teamID":"\(teamIDTextField.text ?? "")","passcode":"\(passCodeTextField.text ?? "")"]
                ref1.updateChildValues(data)
                performSegue(withIdentifier: "fromInvite", sender: nil)
            }else{
                let alert: UIAlertController = UIAlertController(title: "確認", message: "団体IDとパスコードが一致しません。もう一度入力して下さい。", preferredStyle:  UIAlertController.Style.alert)
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                    (action: UIAlertAction!) -> Void in

                })
                alert.addAction(defaultAction)
                present(alert, animated: true, completion: nil)
            }
        }else{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "団体IDが存在しません。もう一度入力して下さい。", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in

            })
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func buttonTapped2(_ sender: Any) {
        applyStatus = "個人利用"
        if userStatus == "0"{
            performSegue(withIdentifier: "toAppRule", sender: nil)
        }else if userStatus == "1"{
            performSegue(withIdentifier: "fromInvite", sender: nil)
        }
    }
    
    
    @IBAction func closeButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toAppRule") {
            if #available(iOS 13.0, *) {
//                let nextData: applyFormViewController = segue.destination as! applyFormViewController
            } else {
                // Fallback on earlier versions
            }
        }
        if (segue.identifier == "fromInvite") {
            if #available(iOS 13.0, *) {
                let nextData: applyFormViewController = segue.destination as! applyFormViewController
                if applyStatus == "団体利用"{
                    nextData.selectedTeamID = self.teamIDTextField.text ?? ""
                }else if applyStatus == "個人利用"{
                    nextData.selectedTeamID = ""
                }
                self.passCodeTextField.text = ""
                nextData.selectedApplyStatus = self.applyStatus
            } else {
                // Fallback on earlier versions
            }
        }
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
