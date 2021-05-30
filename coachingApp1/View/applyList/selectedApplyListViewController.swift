//
//  selectedApplyListViewController.swift
//  track_online
//
//  Created by 刈田修平 on 2020/10/04.
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
import SDWebImage
import PopupDialog

class selectedApplyListViewController: UIViewController, UITextViewDelegate, UIPopoverPresentationControllerDelegate,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var anaResultTableView: UITableView!
    
    @IBOutlet var userName: UILabel!
    @IBOutlet var memo: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var time: UILabel!
    @IBOutlet var answerFlag: UILabel!
    @IBOutlet var ImageView: UIImageView!
    @IBOutlet var playVideo: UIButton!

    @IBOutlet var answerTitle: UILabel!
    @IBOutlet var goodPoint: UILabel!
    @IBOutlet var badPoint: UILabel!
    @IBOutlet var practice: UILabel!
    @IBOutlet var sankouURL: UITextView!
    @IBOutlet weak var sankouURLHeight: NSLayoutConstraint!
    @IBOutlet var comment: UILabel!
    @IBOutlet weak var review_star_button: UIButton!
    var review_star: String?

    var selectedApplyID: String?
    var selectedYYYYMM: String?
    
    var anaCriteriaIDArray = [String]()
    var anaCriteriaTitleArray = [String]()
    var anaCriteriaScoreArray = [String]()
    var anaPointIDArray = [String]()
    var anaPointValueArray = [String]()
    var anaPointScoreArray = [String]()
    var anaPointFBFlagArray = [String]()
    var anaPointValueDiffArray = [String]()
    var anaPointFBContentArray = [String]()

    var anaCriteria_text_arm: String?
    var anaCriteria_text_leg: String?
    var anaCriteria_text_headPosition: String?
    var anaCriteria_text_axis: String?
    var anaCriteria_text_ground: String?

    let imagePickerController = UIImagePickerController()
    var cache: String?
    var videoURL: URL?
    var playUrl:NSURL?
    var data:Data?
    var pickerview: UIPickerView = UIPickerView()
    
    let currentUid:String = Auth.auth().currentUser!.uid
    let currentUserName:String = Auth.auth().currentUser!.displayName!
    let Ref = Database.database().reference()
    
    var ActivityIndicator: UIActivityIndicatorView!
    var initilizedView: UIView = UIView()

    override func viewDidLoad() {
        anaResultTableView.dataSource = self
        anaResultTableView.delegate = self
        
        print(selectedYYYYMM!)

        UIApplication.shared.applicationIconBadgeNumber = 0
//        fcmStatus()
        initilize()
        loadDataApply()
        download()
        loadDataAnswer()
        loadData_ana()
        review_star_button.isHidden = true
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
        }
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        loadDataAnswer()
//        super.viewWillAppear(animated)
//    }

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
    func fcmStatus(){
        let ref1 = Ref.child("user").child("\(self.currentUid)")
        let ref2 = Ref.child("fcmToken").child("\(self.currentUid)")
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {setting in
            if setting.authorizationStatus == .authorized {
                let token:[String:AnyObject]=["fcmToken":Messaging.messaging().fcmToken,"fcmTokenStatus":"1"] as [String : AnyObject]
                ref1.updateChildValues(token)
                ref2.updateChildValues(token)
                print("許可")
            }
            else {
                let token:[String:AnyObject]=["fcmToken":Messaging.messaging().fcmToken,"fcmTokenStatus":"0"] as [String : AnyObject]
                ref1.updateChildValues(token)
                ref2.updateChildValues(token)
                print("未許可")
            }
        })
    }
    func loadDataApply(){
        let ref0 = Ref.child("user").child("\(self.currentUid)").child("profile")
        ref0.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["userName"] as? String ?? ""
            self.userName.text = key
        })

        let ref = Ref.child("user").child("\(self.currentUid)").child("myApply").child("\(selectedYYYYMM!)").child("\(self.selectedApplyID!)")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["memo"] as? String ?? ""
            self.memo.text = key
            
        })
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["date"] as? String ?? ""
            self.date.text = key
            
        })
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["time"] as? String ?? ""
            self.time.text = key
            
        })
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["answerFlag"] as? String ?? ""
            if key == "1"{
                self.answerFlag.text = "解析準備中"
                self.answerFlag.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
                self.answerTitle.text = "まだ回答はありません"
            }else if key == "2"{
                self.answerFlag.text = "解析あり"
                self.answerFlag.backgroundColor = #colorLiteral(red: 0.7781245112, green: 0.1633349657, blue: 0.4817854762, alpha: 1)
                self.answerTitle.text = "レーダーチャート"
            }else{
                self.answerFlag.text = "解析待ち"
                self.answerFlag.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
                self.answerTitle.text = "まだ解析はありません"
            }
        })
        let textImage:String = self.selectedApplyID!+".png"
        let refImage = Storage.storage().reference().child("user").child("\(self.currentUid)").child("myApply").child("\(selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("\(textImage)")
        ImageView.sd_setImage(with: refImage, placeholderImage: nil)
        playVideo.addTarget(self, action: #selector(playVideo(_:)), for: .touchUpInside)

    }
    func loadDataAnswer(){
        let ref = Ref.child("answer").child("\(self.selectedApplyID!)")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["good"] as? String ?? "-"
            self.goodPoint.text = key
        })
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["bad"] as? String ?? "-"
            self.badPoint.text = key
        })
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["practice"] as? String ?? "-"
            self.practice.text = key
        })
        ref.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["URL"] as? String ?? "-"
            self.sankouURL.isEditable = false
            if key != "-"{
                self.sankouURL.text = key

                let URLs:[String] = key.components(separatedBy: "\n")
                
                let attributedString = NSMutableAttributedString(string: key)
                for url in URLs{
                    attributedString.addAttribute(.link,
                                                  value: url,
                                                  range: NSString(string: key).range(of: url))
                }
                self.sankouURLHeight.constant = CGFloat(35 + URLs.count*12)
                self.sankouURL.font = UIFont.boldSystemFont(ofSize: 20)
                self.sankouURL.attributedText = attributedString
                self.sankouURL.isSelectable = true
                self.sankouURL.delegate = self as UITextViewDelegate
            }
        })
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["comment"] as? String ?? "-"
            self.comment.text = key
            if self.comment.text != "-"{
                self.review_star_button.isHidden = false
            }
        })
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["review_star"] as? String ?? ""
            self.review_star = key
            if self.review_star != ""{
                self.review_star_button.isHidden = true
            }
        })

    }
    
    func loadData_ana(){
//        let ref1 = Ref.child("apply").child("\(self.selectedYYYYMM!)").child("\(self.currentUid)").child("answer").child("analytics").child("criteria")
//        let ref2 = Ref.child("apply").child("\(self.selectedYYYYMM!)").child("\(self.currentUid)").child("answer").child("analytics").child("point")
//
//        ref1.observeSingleEvent(of: .value, with: { [self](snapshot) in
//            if let snapdata = snapshot.value as? [String:NSDictionary]{
//                for key in snapdata.keys.sorted(){
//                    let snap = snapdata[key]
//                    if let key = snap!["anaCriteriaID"] as? String {
//                        self.anaCriteriaIDArray.append(key)
//                        self.anaResultTableView.reloadData()
//                    }
//                }
//                for key in snapdata.keys.sorted(){
//                    let snap = snapdata[key]
//                    if let key = snap!["anaCriteriaTitle"] as? String {
//                        self.anaCriteriaTitleArray.append(key)
//                        self.anaResultTableView.reloadData()
//                    }
//                }
////                for key in snapdata.keys.sorted(){
////                    let snap = snapdata[key]
////                    if let key = snap!["score"] as? String {
////                        self.anaCriteriaScoreArray.append(key)
////                        self.anaResultTableView.reloadData()
////                    }
////                }
//            }
//        })

        anaCriteriaIDArray = ["headPosition","arm","leg","axis","ground"]
        anaCriteriaTitleArray = ["ヘッドポジション","腕振り","レッグ","接地","軸"]
        
        let anaPointIDArray_arm = ["ANGLE_L_ELBOW","ANGLE_R_ELBOW","ANGLE_L_HAND","ANGLE_R_HAND"]
        let anaPointIDArray_axis = ["ANGLE_AXIS"]
        let anaPointIDArray_ground = ["ANGLE_GROUND"]
        let anaPointIDArray_headPosition = ["ANGLE_NECK"]
        let anaPointIDArray_leg = ["ANGLE_R_HIP","ANGLE_L_HIP","ANGLE_R_KNEE","ANGLE_L_KNEE","ANGLE_R_ANKLE","ANGLE_L_ANKLE"]

//        for i in 0..<anaPointIDArray_arm.count{
//            print("\(anaPointIDArray_arm[i])")
//            let ref0 = Ref.child("apply").child("\(self.selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("answer").child("analytics").child("point").child("\(anaPointIDArray_arm[i])")
//            ref0.observeSingleEvent(of: .value, with: { (snapshot) in
//                let value = snapshot.value as? NSDictionary
//                let key0 = value?["fbFlag"] as? String ?? ""
//                let key1 = value?["value"] as? Int ?? 0
//                let key2 = value?["diff"] as? Int ?? 0
//                let key3 = value?["fbContent"] as? String ?? ""
//                print(key0)
//                print(key1)
//                print(key2)
//                print(key3)
//                if key0 == "1" || key0 == "2"{
//                    self.anaCriteria_text_arm = self.anaCriteria_text_arm ?? "" + "\(i+1).　\(String(key1))°（適正範囲との差異 約\(String(key2))°)\n→\(key3)\n"
//                }else{
//                    self.anaCriteria_text_arm = self.anaCriteria_text_arm ?? "" + "\(i+1).　\(String(key1))°（適正範囲内)\n→\(key3)\n"
//                }
//                if i == anaPointIDArray_arm.count-1{
//                    self.anaResultTableView.reloadData()
//                }
//                print(self.anaCriteria_text_arm)
//
//            })
//        }
//        for i in 0..<anaPointIDArray_axis.count{
//            let ref0 = Ref.child("apply").child("\(self.selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("answer").child("analytics").child("point").child("\(anaPointIDArray_axis[i])")
//            ref0.observeSingleEvent(of: .value, with: { (snapshot) in
//                let value = snapshot.value as? NSDictionary
//                let key0 = value?["fbFlag"] as? String ?? ""
//                let key1 = value?["value"] as? Int ?? 0
//                let key2 = value?["diff"] as? Int ?? 0
//                let key3 = value?["fbContent"] as? String ?? ""
//                if key0 == "1" || key0 == "2"{
//                    self.anaCriteria_text_axis = self.anaCriteria_text_axis ?? "" + "\(i+1).　\(String(key1))°（適正範囲との差異 約\(String(key2))°)\n→\(key3)\n"
//                }else{
//                    self.anaCriteria_text_axis = self.anaCriteria_text_axis ?? "" + "\(i+1).　\(String(key1))°（適正範囲内)\n→\(key3)\n"
//                }
//                if i == anaPointIDArray_axis.count-1{
//                    self.anaResultTableView.reloadData()
//                }
//                print(self.anaCriteria_text_axis)
//
//            })
//        }
//        for i in 0..<anaPointIDArray_ground.count{
//            let ref0 = Ref.child("apply").child("\(self.selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("answer").child("analytics").child("point").child("\(anaPointIDArray_ground[i])")
//            ref0.observeSingleEvent(of: .value, with: { (snapshot) in
//                let value = snapshot.value as? NSDictionary
//                let key0 = value?["fbFlag"] as? String ?? ""
//                let key1 = value?["value"] as? Int ?? 0
//                let key2 = value?["diff"] as? Int ?? 0
//                let key3 = value?["fbContent"] as? String ?? ""
//                if key0 == "1" || key0 == "2"{
//                    self.anaCriteria_text_ground = self.anaCriteria_text_ground ?? "" + "\(i+1).　\(String(key1))°（適正範囲との差異 約\(String(key2))°)\n→\(key3)\n"
//                }else{
//                    self.anaCriteria_text_ground = self.anaCriteria_text_ground ?? "" + "\(i+1).　\(String(key1))°（適正範囲内)\n→\(key3)\n"
//                }
//                if i == anaPointIDArray_ground.count-1{
//                    self.anaResultTableView.reloadData()
//                }
//            })
//        }
//        for i in 0..<anaPointIDArray_headPosition.count{
//            let ref0 = Ref.child("apply").child("\(self.selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("answer").child("analytics").child("point").child("\(anaPointIDArray_headPosition[i])")
//            ref0.observeSingleEvent(of: .value, with: { (snapshot) in
//                let value = snapshot.value as? NSDictionary
//                let key0 = value?["fbFlag"] as? String ?? ""
//                let key1 = value?["value"] as? Int ?? 0
//                let key2 = value?["diff"] as? Int ?? 0
//                let key3 = value?["fbContent"] as? String ?? ""
//                if key0 == "1" || key0 == "2"{
//                    self.anaCriteria_text_headPosition = self.anaCriteria_text_headPosition ?? "" + "\(i+1).　\(String(key1))°（適正範囲との差異 約\(String(key2))°)\n→\(key3)\n"
//                }else{
//                    self.anaCriteria_text_headPosition = self.anaCriteria_text_headPosition ?? "" + "\(i+1).　\(String(key1))°（適正範囲内)\n→\(key3)\n"
//                }
//                if i == anaPointIDArray_headPosition.count-1{
//                    self.anaResultTableView.reloadData()
//                }
//            })
//        }
//        for i in 0..<anaPointIDArray_leg.count{
//            let ref0 = Ref.child("apply").child("\(self.selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("answer").child("analytics").child("point").child("\(anaPointIDArray_leg[i])")
//            ref0.observeSingleEvent(of: .value, with: { (snapshot) in
//                let value = snapshot.value as? NSDictionary
//                let key0 = value?["fbFlag"] as? String ?? ""
//                let key1 = value?["value"] as? Int ?? 0
//                let key2 = value?["diff"] as? Int ?? 0
//                let key3 = value?["fbContent"] as? String ?? ""
//                if key0 == "1" || key0 == "2"{
//                    self.anaCriteria_text_leg = self.anaCriteria_text_leg ?? "" + "\(i+1).　\(String(key1))°（適正範囲との差異 約\(String(key2))°)\n→\(key3)\n"
//                }else{
//                    self.anaCriteria_text_leg = self.anaCriteria_text_leg ?? "" + "\(i+1).　\(String(key1))°（適正範囲内)\n→\(key3)\n"
//                }
//                if i == anaPointIDArray_leg.count-1{
//                    self.anaResultTableView.reloadData()
//                }
//            })
//        }

        let ref0 = Ref.child("apply").child("\(self.selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("answer").child("analytics").child("point").child("\(anaCriteriaIDArray[0])")
        let ref1 = Ref.child("apply").child("\(self.selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("answer").child("analytics").child("point").child("\(anaCriteriaIDArray[1])")
        let ref2 = Ref.child("apply").child("\(self.selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("answer").child("analytics").child("point").child("\(anaCriteriaIDArray[2])")
        let ref3 = Ref.child("apply").child("\(self.selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("answer").child("analytics").child("point").child("\(anaCriteriaIDArray[3])")
        let ref4 = Ref.child("apply").child("\(self.selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("answer").child("analytics").child("point").child("\(anaCriteriaIDArray[4])")

        print(ref0)
        print(ref1)
        print(ref2)
        print(ref3)
        print(ref4)
        ref0.observeSingleEvent(of: .value, with: { [self](snapshot) in
            if let snapdata = snapshot.value as? [String:NSDictionary]{
                var i = 1
                var str = ""
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    let key0 = snap?["fbFlag"] as? String ?? ""
                    let key1 = snap?["value"] as? Int ?? 0
                    let key2 = snap?["diff"] as? Int ?? 0
                    let key3 = snap?["fbContent"] as? String ?? ""
                    let num = convertEnclosedNumber(num: i)
                     
                    if key0 == "1" || key0 == "2"{
                        str.append("\(num!) \(String(key1))°（適正範囲との差異 約\(String(key2))°)\n→\(key3)\n\n")
                        self.anaCriteria_text_headPosition = str
                    }else{
                        str.append("\(num!) \(String(key1))°（適正範囲内)\n→\(key3)\n\n")
                        self.anaCriteria_text_headPosition = str
                    }
                    i+=1
                    self.anaResultTableView.reloadData()
                }
            }
        })
        ref1.observeSingleEvent(of: .value, with: { [self](snapshot) in
            if let snapdata = snapshot.value as? [String:NSDictionary]{
                var i = 2
                var str = ""
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    let key0 = snap?["fbFlag"] as? String ?? ""
                    let key1 = snap?["value"] as? Int ?? 0
                    let key2 = snap?["diff"] as? Int ?? 0
                    let key3 = snap?["fbContent"] as? String ?? ""
                    let num = convertEnclosedNumber(num: i)
                    if key0 == "1" || key0 == "2"{
                        str.append("\(num!) \(String(key1))°（適正範囲との差異 約\(String(key2))°)\n→\(key3)\n\n")
                        self.anaCriteria_text_arm = str
                    }else{
                        str.append("\(num!) \(String(key1))°（適正範囲内)\n→\(key3)\n\n")
                        self.anaCriteria_text_arm = str
                    }
                    i+=1
                    self.anaResultTableView.reloadData()
                }
            }
        })
        ref2.observeSingleEvent(of: .value, with: { [self](snapshot) in
            if let snapdata = snapshot.value as? [String:NSDictionary]{
                var i = 6
                var str = ""
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    let key0 = snap?["fbFlag"] as? String ?? ""
                    let key1 = snap?["value"] as? Int ?? 0
                    let key2 = snap?["diff"] as? Int ?? 0
                    let key3 = snap?["fbContent"] as? String ?? ""
                    let num = convertEnclosedNumber(num: i)
                    if key0 == "1" || key0 == "2"{
                        str.append("\(num!) \(String(key1))°（適正範囲との差異 約\(String(key2))°)\n→\(key3)\n\n")
                        self.anaCriteria_text_leg = str
                    }else{
                        str.append("\(num!) \(String(key1))°（適正範囲内)\n→\(key3)\n\n")
                        self.anaCriteria_text_leg = str
                    }
                    i+=1
                    self.anaResultTableView.reloadData()
                }
            }
        })
        ref3.observeSingleEvent(of: .value, with: { [self](snapshot) in
            if let snapdata = snapshot.value as? [String:NSDictionary]{
                var i = 12
                var str = ""
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    let key0 = snap?["fbFlag"] as? String ?? ""
                    let key1 = snap?["value"] as? Int ?? 0
                    let key2 = snap?["diff"] as? Int ?? 0
                    let key3 = snap?["fbContent"] as? String ?? ""
                    let num = convertEnclosedNumber(num: i)
                    if key0 == "1" || key0 == "2"{
                        str.append("\(num!) \(String(key1))°（適正範囲との差異 約\(String(key2))°)\n→\(key3)\n\n")
                        self.anaCriteria_text_axis = str
                    }else{
                        str.append("\(num!) \(String(key1))°（適正範囲内)\n→\(key3)\n\n")
                        self.anaCriteria_text_axis = str
                    }
                    i+=1
                    self.anaResultTableView.reloadData()
                }
            }
        })
        ref4.observeSingleEvent(of: .value, with: { [self](snapshot) in
            if let snapdata = snapshot.value as? [String:NSDictionary]{
                var i = 13
                var str = ""
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    let key0 = snap?["fbFlag"] as? String ?? ""
                    let key1 = snap?["value"] as? Int ?? 0
                    let key2 = snap?["diff"] as? Int ?? 0
                    let key3 = snap?["fbContent"] as? String ?? ""
                    let num = convertEnclosedNumber(num: i)
                    if key0 == "1" || key0 == "2"{
                        str.append("\(num!) \(String(key1))°（適正範囲との差異 約\(String(key2))°)\n→\(key3)\n\n")
                        self.anaCriteria_text_ground = str
                    }else{
                        str.append("\(num!) \(String(key1))°（適正範囲内)\n→\(key3)\n\n")
                        self.anaCriteria_text_ground = str
                    }
                    i+=1
                    self.anaResultTableView.reloadData()
                }
            }
        })
//        ref2.observeSingleEvent(of: .value, with: { [self](snapshot) in
//            if let snapdata = snapshot.value as? [String:NSDictionary]{
//                for key in snapdata.keys.sorted(){
//                    let snap = snapdata[key]
//                    if let key = snap!["anaPointID"] as? String {
//                        self.anaPointIDArray.append(key)
//                        self.anaResultTableView.reloadData()
//                    }
//                }
//                for key in snapdata.keys.sorted(){
//                    let snap = snapdata[key]
//                    if let key = snap!["value"] as? String {
//                        self.anaPointValueArray.append(key)
//                        self.anaResultTableView.reloadData()
//                    }
//                }
//                for key in snapdata.keys.sorted(){
//                    let snap = snapdata[key]
//                    if let key = snap!["score"] as? String {
//                        self.anaPointScoreArray.append(key)
//                        self.anaResultTableView.reloadData()
//                    }
//                }
//                for key in snapdata.keys.sorted(){
//                    let snap = snapdata[key]
//                    if let key = snap!["fbFlag"] as? String {
//                        self.anaPointFBFlagArray.append(key)
//                        self.anaResultTableView.reloadData()
//                    }
//                }
//                for key in snapdata.keys.sorted(){
//                    let snap = snapdata[key]
//                    if let key = snap!["fbContent"] as? String {
//                        self.anaPointFBContentArray.append(key)
//                        self.anaResultTableView.reloadData()
//                    }
//                }
//                for key in snapdata.keys.sorted(){
//                    let snap = snapdata[key]
//                    if let key = snap!["diff"] as? String {
//                        self.anaPointValueDiffArray.append(key)
//                        self.anaResultTableView.reloadData()
//                    }
//                }
//            }
//        })
        
    }
    private func convertEnclosedNumber(num: Int) -> String? {
        if num < 0 || 50 < num {
            return nil
        }
            
        var char: String? = nil
        if 0 == num {
            let ch = 0x24ea
            char = String(UnicodeScalar(ch)!)
        } else if 0 < num && num <= 20 {
            let ch = 0x2460 + (num - 1)
            char = String(UnicodeScalar(ch)!)
        } else if 21 <= num && num <= 35 {
            let ch = 0x3251 + (num - 21)
            char = String(UnicodeScalar(ch)!)
        } else if 36 <= num && num <= 50 {
            let ch = 0x32b1 + (num - 36)
            char = String(UnicodeScalar(ch)!)
        }
        return char
    }
    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {

        UIApplication.shared.open(URL)

        return false
    }
    @objc func playVideo(_ sender: UIButton) {
        let player = AVPlayer(url: playUrl! as URL
        )
        
        let controller = AVPlayerViewController()
        controller.player = player
        
        present(controller, animated: true) {
            controller.player!.play()
        }
    }
    
    func download(){
        
        let textVideo:String = selectedApplyID!+".mp4"
        let refVideo = Storage.storage().reference().child("user").child("\(self.currentUid)").child("myApply").child("\(selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("\(textVideo)")
        refVideo.downloadURL{ url, error in
            if (error != nil) {
            } else {
                self.playUrl = url as NSURL?
                print("download success!! URL:", url!)
            }
            self.initilizedView.removeFromSuperview()
        }
        let ref = Ref.child("user").child("\(self.currentUid)")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["cache"] as? String ?? ""
            self.cache = key
            if self.cache == "1"{
                SDImageCache.shared.clearMemory()
                SDImageCache.shared.clearDisk()
                let data = ["cache":"0" as Any] as [String : Any]
                ref.updateChildValues(data)
            }
//            self.initilizedView.removeFromSuperview()
        })
        
    }
    
    func numberOfSections(in myTableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ myTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return anaCriteriaTitleArray.count
    }
    
    
    func tableView(_ myTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = self.anaResultTableView.dequeueReusableCell(withIdentifier: "anaResultCell", for: indexPath as IndexPath) as? anaResultTableViewCell
        cell!.anaCriteriaTitle.text = self.anaCriteriaTitleArray[indexPath.row]
        if anaCriteriaTitleArray[indexPath.row] == "ヘッドポジション"{
            cell!.anaPointValue_text.text = self.anaCriteria_text_headPosition
        }else if anaCriteriaTitleArray[indexPath.row] == "腕振り"{
            cell!.anaPointValue_text.text = self.anaCriteria_text_arm
        }else if anaCriteriaTitleArray[indexPath.row] == "レッグ"{
            cell!.anaPointValue_text.text = self.anaCriteria_text_leg
        }else if anaCriteriaTitleArray[indexPath.row] == "接地"{
            cell!.anaPointValue_text.text = self.anaCriteria_text_ground
        }else if anaCriteriaTitleArray[indexPath.row] == "軸"{
            cell!.anaPointValue_text.text = self.anaCriteria_text_axis
        }
        
        cell!.anaCriteriaIcon.image = UIImage(named: "good")

        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ModalSegue"){
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            // "popoverVC"はポップアップ用のVCに後ほど設定
            let vc = storyboard.instantiateViewController(withIdentifier: "popoverVC") as! PopoverViewController
    //        vc.delegate = self
            vc.modalPresentationStyle = UIModalPresentationStyle.popover

            let popover: UIPopoverPresentationController = vc.popoverPresentationController!
            popover.delegate = self

            if sender != nil {
                if let button = sender {
                    // UIButtonからポップアップが出るように設定
                    popover.sourceRect = (button as! UIButton).bounds
                    popover.sourceView = (sender as! UIView)
                }
            }
            self.present(vc, animated: true, completion:nil)
        }else if answerFlag.text == "回答待ち"{
            if (segue.identifier == "selectedApplyEdit") {
                if #available(iOS 13.0, *) {
                    let nextData: selectedApplyListEditViewController = segue.destination as! selectedApplyListEditViewController
                    nextData.selectedApplyID = self.selectedApplyID!
                } else {
                    // Fallback on earlier versions
                }
            }
        }else{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "回答準備中またはアドバイスを既にもらっているため申請内容を編集できません", preferredStyle:  UIAlertController.Style.alert)
            
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
            
        }
    }
    func showCustomDialog(animated: Bool = true) {

        // Create a custom view controller
        let ratingVC = RatingViewController(nibName: "RatingViewController", bundle: nil)

        // Create the dialog
        let popup = PopupDialog(viewController: ratingVC,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceDown,
                                tapGestureDismissal: true,
                                panGestureDismissal: false)

        // Create first button
        let buttonOne = CancelButton(title: "キャンセル", height: 60) {
            print("-")
        }

        // Create second button
        let buttonTwo = DefaultButton(title: "送信する", height: 60) {
//            self.starLabel.text = "You rated \(ratingVC.cosmosStarRating.rating) stars"
            let ref = self.Ref.child("answer").child("\(self.selectedApplyID!)")
            let data = ["review_star":"\(ratingVC.cosmosStarRating.rating)" as Any] as [String : Any]
            ref.updateChildValues(data)
            self.review_star_button.isHidden = true
        }

        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo])

        // Present dialog
        present(popup, animated: animated, completion: nil)
    }


    @IBAction func showCustomDialogTapped(_ sender: Any) {
        showCustomDialog()
    }
    
    // 表示スタイルの設定
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // .noneを設定することで、設定したサイズでポップアップされる
        return .none
    }
}
