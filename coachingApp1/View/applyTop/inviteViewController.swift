//
//  inviteViewController.swift
//  coachingApp1
//
//  Created by 刈田修平 on 2021/02/28.
//

import UIKit
import Firebase
import FirebaseStorage

class inviteViewController: UIViewController {

    @IBOutlet var teamIDTextField: UITextField!
    @IBOutlet var passCodeTextField: UITextField!
    @IBOutlet weak var cautionText: UILabel!
    @IBOutlet weak var homeText1: UILabel!
    @IBOutlet weak var homeText2: UILabel!
    @IBOutlet weak var homeText3: UILabel!
    var teamIDArray = [String]()
    var passCodeArray = [String]()
    var selectedTeamID:String?
    let Ref = Database.database().reference()

    let currentUid:String = Auth.auth().currentUser!.uid
    var ActivityIndicator: UIActivityIndicatorView!
    var initilizedView: UIView = UIView()

    var window: UIWindow?

    override func viewDidLoad() {
        appRuleView()
        initilize()
        loadData()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
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
//            self.homeText1.text = key1
            self.homeText2.text = key1 + "\n" + key2
            self.homeText3.text = key3
            self.initilizedView.removeFromSuperview()
        })
        let ref2 = Ref.child("user").child("\(currentUid)").child("profile")
        ref2.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["teamID"] as? String ?? ""
            self.teamIDTextField.text = key
        })

    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        
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
    @IBAction func closeButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "fromInvite") {
            if #available(iOS 13.0, *) {
                let nextData: applyFormViewController = segue.destination as! applyFormViewController
                nextData.selectedTeamID = self.teamIDTextField.text ?? ""
//                self.teamIDTextField.text = ""
                self.passCodeTextField.text = ""
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
