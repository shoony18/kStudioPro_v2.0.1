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

class selectedApplyListViewController: UIViewController, UITextViewDelegate, UIPopoverPresentationControllerDelegate{
    
    
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
        UIApplication.shared.applicationIconBadgeNumber = 0
        fcmStatus()
        initilize()
        loadDataApply()
        download()
        loadDataAnswer()
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
        let ref0 = Ref.child("user").child("\(self.currentUid)")
        ref0.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["userName"] as? String ?? ""
            self.userName.text = key
        })

        let ref = Ref.child("myApply").child("\(self.currentUid)").child("\(self.selectedApplyID!)")
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
        let refImage = Storage.storage().reference().child("myApply").child("\(self.currentUid)").child("\(self.selectedApplyID!)").child("\(textImage)")
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
        let refVideo = Storage.storage().reference().child("myApply").child("\(self.currentUid)").child("\(self.selectedApplyID!)").child("\(textVideo)")
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
