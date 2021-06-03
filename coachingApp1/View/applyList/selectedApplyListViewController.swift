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
import Charts

class selectedApplyListViewController: UIViewController, UITextViewDelegate, UIPopoverPresentationControllerDelegate,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var anaResultTableView: UITableView!
    @IBOutlet weak var RadarChartView: RadarChartView!

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
    var anaCriteriaTitleArray2 = [String]()
    var anaCriteriaScoreArray = [Double]()
    var anaPointIDArray = [String]()
    var anaPointValueArray = [Int]()
    var anaPointDiffArray = [Int]()
    var anaPointScoreArray = [Int]()
    var anaPointFBFlagArray = [String]()
    var anaPointValueDiffArray = [Int]()
    var anaPointFBContentArray = [String]()
    var rangeStartArray = [Int]()
    var rangeEndArray = [Int]()

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
        loadData_chart()
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
        let ref = Ref.child("apply").child("\(self.selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("answer").child("summury")
//        ref.observeSingleEvent(of: .value, with: { (snapshot) in
//            let value = snapshot.value as? NSDictionary
//            let key = value?["good"] as? String ?? "-"
//            self.goodPoint.text = key
//        })
//        ref.observeSingleEvent(of: .value, with: { (snapshot) in
//            let value = snapshot.value as? NSDictionary
//            let key = value?["bad"] as? String ?? "-"
//            self.badPoint.text = key
//        })
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

    func loadData_chart(){
        let scWid: CGFloat = UIScreen.main.bounds.width     //画面の幅
        let scHei: CGFloat = UIScreen.main.bounds.height    //画面の高さ
        RadarChartView.frame = CGRect(x: -scWid*0.06 ,y: 0 ,width: scWid*1.0 ,height: scWid*1.0)
        
        let ref0 = Ref.child("apply").child("\(self.selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("answer").child("analytics").child("criteria")
        ref0.observeSingleEvent(of: .value, with: { [self](snapshot) in
            if let snapdata = snapshot.value as? [String:NSDictionary]{
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    if let key = snap!["anaCriteriaTitle"] as? String {
                        self.anaCriteriaTitleArray2.append(key)
                        print(self.anaCriteriaTitleArray2)
//                        self.setChart(self.anaCriteriaTitleArray, values: self.anaCriteriaScoreArray)
                    }
                }
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    if let key = snap!["score"] as? Int {
                        self.anaCriteriaScoreArray.append(Double(key))
                        print(self.anaCriteriaScoreArray)
                        if self.anaCriteriaScoreArray.count == 5{
                            self.setChart(self.anaCriteriaTitleArray2, values: self.anaCriteriaScoreArray)
                        }
                    }
                }

            }
        })
    }
    func loadData_ana(){
//        anaCriteriaIDArray = ["headPosition","arm","leg","axis","ground"]
//        anaCriteriaTitleArray = ["ヘッドポジション","腕振り","レッグ","軸","接地"]

        
//        let anaPointIDArray_arm = ["ANGLE_L_ELBOW","ANGLE_R_ELBOW","ANGLE_L_HAND","ANGLE_R_HAND"]
//        let anaPointIDArray_axis = ["ANGLE_AXIS"]
//        let anaPointIDArray_ground = ["ANGLE_GROUND"]
//        let anaPointIDArray_headPosition = ["ANGLE_NECK"]
//        let anaPointIDArray_leg = ["ANGLE_R_HIP","ANGLE_L_HIP","ANGLE_R_KNEE","ANGLE_L_KNEE","ANGLE_R_ANKLE","ANGLE_L_ANKLE"]

        let ref0 = Ref.child("apply").child("\(self.selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("answer").child("analytics").child("point")
        let ref1 = Ref.child("analytics").child("feedback")
        ref1.observeSingleEvent(of: .value, with: { [self](snapshot) in
            if let snapdata = snapshot.value as? [String:NSDictionary]{
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    let key0 = snap?["range_start"] as? Int ?? 0
                    let key1 = snap?["range_end"] as? Int ?? 0
                    self.rangeStartArray.append(key0)
                    self.rangeEndArray.append(key1)
                    print(self.rangeEndArray)
                }
            }
        })
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
                    let key4 = snap?["anaCriteriaID"] as? String ?? ""
                    let key5 = snap?["anaPointID"] as? String ?? ""
                    let num = convertEnclosedNumber(num: i)
                     
                    self.anaPointFBFlagArray.append(key0)
                    self.anaPointValueArray.append(key1)
                    self.anaPointDiffArray.append(key2)
                    self.anaPointFBContentArray.append(key3)
                    self.anaCriteriaIDArray.append(key4)
                    self.anaPointIDArray.append(key5)
                    self.anaResultTableView.reloadData()
                    
//                    if key0 == "1" || key0 == "2"{
//                        str.append("\(num!) \(String(key1))°（適正範囲との差異 約\(String(key2))°)\n→\(key3)\n\n")
//                        self.anaCriteria_text_headPosition = str
//                    }else{
//                        str.append("\(num!) \(String(key1))°（適正範囲内)\n→\(key3)\n\n")
//                        self.anaCriteria_text_headPosition = str
//                    }
//                    i+=1
//                    self.anaResultTableView.reloadData()
                }
            }
        })
        
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
        return anaPointIDArray.count
    }
    
    
    func tableView(_ myTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.anaResultTableView.dequeueReusableCell(withIdentifier: "anaResultCell", for: indexPath as IndexPath) as? anaResultTableViewCell
        let num = convertEnclosedNumber(num: indexPath.row+1)
        cell!.numberTitle.text = "ポイント\(num!)"
        cell!.anaPointFBContent.text = self.anaPointFBContentArray[indexPath.row]
        if anaCriteriaIDArray[indexPath.row] == "headPosition"{
            cell!.anaCriteriaTitle.text = "ヘッドポジション"
        }else if anaCriteriaIDArray[indexPath.row] == "arm"{
            cell!.anaCriteriaTitle.text = "腕振り"
        }else if anaCriteriaIDArray[indexPath.row] == "leg"{
            cell!.anaCriteriaTitle.text = "レッグ"
        }else if anaCriteriaIDArray[indexPath.row] == "ground"{
            cell!.anaCriteriaTitle.text = "接地"
        }else if anaCriteriaIDArray[indexPath.row] == "axis"{
            cell!.anaCriteriaTitle.text = "軸"
        }
        if anaPointFBFlagArray[indexPath.row] == "0"{
            cell!.anaCriteriaIcon.image = UIImage(named: "good")
        }else{
            cell!.anaCriteriaIcon.image = UIImage(named: "bad")
        }
        cell!.range_start.text = String(rangeStartArray[indexPath.row]) + "°"
        cell!.range_end.text = String(rangeEndArray[indexPath.row]) + "°"

        let length = rangeEndArray[indexPath.row] - rangeStartArray[indexPath.row]
        let diff = anaPointValueArray[indexPath.row] - rangeStartArray[indexPath.row]
        var x_userValue = 0
        if diff * 160/length>40 && diff * 160/length<210{
            x_userValue = diff * 160/length
        }else if diff * 160/length < -40{
            x_userValue = -40
        }else if diff * 160/length > 210{
            x_userValue = 210
        }
        cell!.label.frame = CGRect(x: x_userValue, y: 0, width: 10, height: 10)
        print(length)
        print(cell!.label)
        cell!.label1.frame = CGRect(x: x_userValue, y: -15, width: 10, height: 10)
        cell!.label.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        cell!.label1.text = String(anaPointValueArray[indexPath.row]) + "°"
        cell!.label1.textColor = .black
        // 表示する
        cell!.athleteValueBarView.addSubview(cell!.label1)
        cell!.athleteValueBarView.addSubview(cell!.label)

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
    func setChart(_ dataPoints: [String], values: [Double]) {

        RadarChartView.noDataText = "You need to provide data for the chart."
        //点数を入れる配列
        var dataEntries: [ChartDataEntry] = []
        //点数を格納
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        //y軸のラベルを作る
        let chartDataSet = RadarChartDataSet(entries: dataEntries, label: "スコア")
        
        RadarChartView.xAxis.valueFormatter = RadarChartFormatter(labels: dataPoints)
        
        //チャートを塗りつぶす
        chartDataSet.drawFilledEnabled = true
        //チャートの外の線の色
        chartDataSet.setColor(#colorLiteral(red: 1, green: 0.3732917905, blue: 0.4048495591, alpha: 1))
        //塗りつぶしの色
        chartDataSet.fillColor = #colorLiteral(red: 1, green: 0.3732917905, blue: 0.4048495591, alpha: 1)
        //ラベルの値を非表示
        chartDataSet.drawValuesEnabled = false

        //x軸とy軸をセット
        let chartData = RadarChartData(dataSet: chartDataSet)
        //レーダーチャートの回転禁止
        RadarChartView.rotationEnabled = false
        //タップ時にデータを選択できないようにする
        RadarChartView.highlightPerTapEnabled = false
        // グラフの余白
        RadarChartView.setExtraOffsets(left: 0, top: 0, right: 0, bottom: 0)
        //レーダーチャートのy軸の最小値と最大値
        RadarChartView.yAxis.axisMinimum = 0
        RadarChartView.yAxis.axisMaximum = 100
        RadarChartView.yAxis.drawAxisLineEnabled = true
        //レーダーチャートのラベルのフォントは非表示（フォント0にして）
//        RadarChartView.yAxis.labelFont = UIFont.systemFont(ofSize: scInch*3)
//        RadarChartView.sizeToFit()]
        RadarChartView.xAxis.labelFont = UIFont(name: "ヒラギノ角ゴシック W3", size: 10.0)!
//        RadarChartView.xAxis.labelFont = UIFont.systemFont(ofSize: 15)
        RadarChartView.backgroundColor = #colorLiteral(red: 0.9961728454, green: 0.9902502894, blue: 1, alpha: 1)
//        RadarChartView.xAxis.labelFont = UIFont(name: "Verdana", size: 18)!
//        RadarChartView.yAxis.labelFont = UIFont(name: "Verdana", size: 18)!
//        RadarChartView.legend.font = UIFont(name: "Verdana", size: 18)!
        //レーダーチャートの表示
        RadarChartView.data = chartData
    }
}
private class RadarChartFormatter: NSObject, IAxisValueFormatter {
    
    var labels: [String] = []
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if Int(value) < labels.count {
            return labels[Int(value)]
        }else{
            return String("")
        }
    }
    
    init(labels: [String]) {
        super.init()
        self.labels = labels
    }
}
