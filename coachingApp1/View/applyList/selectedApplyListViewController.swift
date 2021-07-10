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

class selectedApplyListViewController: UIViewController, UITextViewDelegate, UIPopoverPresentationControllerDelegate,UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var anaResultCollectionView: UICollectionView!
    @IBOutlet var anaResultTableView: UITableView!
    @IBOutlet weak var RadarChartView: RadarChartView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet var userName: UILabel!
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet var memo: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var time: UILabel!
    @IBOutlet var answerFlag: UILabel!
    @IBOutlet var ImageView: UIImageView!
    @IBOutlet var playVideo: UIButton!
    
    //    @IBOutlet var answerTitle: UILabel!
    @IBOutlet var goodPoint: UILabel!
    @IBOutlet var badPoint: UILabel!
    @IBOutlet var practice: UILabel!
    @IBOutlet var sankouURL: UITextView!
    @IBOutlet weak var sankouURLHeight: NSLayoutConstraint!
    @IBOutlet var comment: UILabel!
    @IBOutlet weak var review_star_button: UIButton!
    
    @IBOutlet weak var totalPoint: UILabel!
    @IBOutlet weak var headPosition: UILabel!
    @IBOutlet weak var arm: UILabel!
    @IBOutlet weak var leg: UILabel!
    @IBOutlet weak var ground: UILabel!
    @IBOutlet weak var axis: UILabel!
    @IBOutlet weak var statusLabelView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var anaImage1: UIImageView!
    @IBOutlet weak var anaImage2: UIImageView!
    
    @IBOutlet weak var scoreTitleView: UIView!
    @IBOutlet weak var angleTitleView: UIView!
    @IBOutlet weak var anaResultTitleView: UIView!

    @IBOutlet weak var scoreView: UIView!
    @IBOutlet weak var angleImageView: UIView!
    @IBOutlet weak var angleView: UIView!
    @IBOutlet weak var anaResultView: UIView!

    var review_star: String?
    var x_userValue:Int?
    
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
    var anaPointPracticeArray = [String]()
    var anaPointPracticeURLArray = [String]()
    
    var anaCriteriaIDArray_re = [String]()
    var anaPointIDArray_re = [String]()
    var anaPointValueArray_re = [Int]()
    var anaPointDiffArray_re = [Int]()
    var anaPointScoreArray_re = [Int]()
    var anaPointFBFlagArray_re = [String]()
    var anaPointValueDiffArray_re = [Int]()
    var anaPointFBContentArray_re = [String]()
    var rangeStartArray_re = [Int]()
    var rangeEndArray_re = [Int]()
    var anaPointPracticeArray_re = [String]()
    var anaPointPracticeURLArray_re = [String]()
    
    var anaCriteria_text_arm: String?
    var anaCriteria_text_leg: String?
    var anaCriteria_text_headPosition: String?
    var anaCriteria_text_axis: String?
    var anaCriteria_text_ground: String?
    
    var practiceURL: String?
    
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
    
    var transRotate1 = CGAffineTransform()
    var transRotate2 = CGAffineTransform()
    
    var viewWidth: CGFloat!
    var viewHeight: CGFloat!
    var cellWitdh: CGFloat!
    var cellHeight: CGFloat!
    var cellOffset: CGFloat!
    var navHeight: CGFloat!
    
    override func viewDidLoad() {
        //        anaResultTableView.dataSource = self
        //        anaResultTableView.delegate = self
        anaResultCollectionView.dataSource = self
        anaResultCollectionView.delegate = self
        
        viewWidth = view.frame.width
        viewHeight = view.frame.height
        //ナビゲーションバーの高さ
        navHeight = self.navigationController?.navigationBar.frame.size.height
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        //        fcmStatus()
        setPageControl()
        initilize()
        loadDataApply()
        download()
        loadDataAnswer()
        loadData_ana()
        loadData_chart()
        statusLabelLotation()
        review_star_button.isHidden = true
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
        }
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        loadDataAnswer()
    //        super.viewWillAppear(animated)
    //    }
    
    func statusLabelLotation(){
        let angle1 = 315 * CGFloat.pi / 180
        transRotate1 = CGAffineTransform(rotationAngle: CGFloat(angle1));
        statusLabelView.transform = transRotate1
    }
    func setPageControl() {
        pageControl.currentPage = 0
        pageControl.numberOfPages = 13
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSet = scrollView.contentOffset.x
        let width = scrollView.frame.width
        let horizontalCenter = width / 2
        
        pageControl.currentPage = Int(offSet + horizontalCenter) / Int(width)
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
    
    func noDataText(){
        let width = UIScreen.main.bounds.size.width
        let noDataText = UILabel()
        noDataText.frame = CGRect(x: 0, y: 50, width: width, height: 20)
        noDataText.text = "まだ解析データはありません"
        noDataText.font = UIFont(name:"Hiragino Sans", size: 15)
        noDataText.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        noDataText.textAlignment = .center
        let noDataText2 = UILabel()
        noDataText2.frame = CGRect(x: 0, y: 50, width: width, height: 20)
        noDataText2.text = "まだ解析データはありません"
        noDataText2.font = UIFont(name:"Hiragino Sans", size: 15)
        noDataText2.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        noDataText2.textAlignment = .center
        let noDataText3 = UILabel()
        noDataText3.frame = CGRect(x: 0, y: 50, width: width, height: 20)
        noDataText3.text = "まだ解析データはありません"
        noDataText3.font = UIFont(name:"Hiragino Sans", size: 15)
        noDataText3.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        noDataText3.textAlignment = .center
        let noDataText4 = UILabel()
        noDataText4.frame = CGRect(x: 0, y: 50, width: width, height: 20)
        noDataText4.text = "まだ解析データはありません"
        noDataText4.font = UIFont(name:"Hiragino Sans", size: 15)
        noDataText4.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        noDataText4.textAlignment = .center
        scoreView.backgroundColor = .white
        angleView.backgroundColor = .white
        angleImageView.backgroundColor = .white
        anaResultView.backgroundColor = .white
        scoreView.addSubview(noDataText)
        angleView.addSubview(noDataText2)
        angleImageView.addSubview(noDataText3)
        anaResultView.addSubview(noDataText4)
    }
    func loadDataApply(){
        
        let angle1 = 315 * CGFloat.pi / 180
        transRotate1 = CGAffineTransform(rotationAngle: CGFloat(angle1));
        
        let ref0 = Ref.child("user").child("\(self.currentUid)").child("profile")
        ref0.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["userName"] as? String ?? ""
            self.userName.text = key
        })
        
        let ref = Ref.child("user").child("\(self.currentUid)").child("myApply").child("\(selectedYYYYMM!)").child("\(self.selectedApplyID!)")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["teamName"] as? String ?? ""
            self.teamName.text = "("+key+")"
            
        })
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
        ref.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["answerFlag"] as? String ?? ""
            if key == "1"{
                self.answerFlag.text = "解析準備中"
                self.answerFlag.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
                self.statusLabelView.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
                self.statusLabelView.transform = self.transRotate1
                self.statusLabel.text = "解析準備中"
                
                //                self.answerTitle.text = "まだ回答はありません"
            }else if key == "2"{
                self.answerFlag.text = "解析済み"
                self.answerFlag.backgroundColor = #colorLiteral(red: 0.7781245112, green: 0.1633349657, blue: 0.4817854762, alpha: 1)
                self.statusLabelView.backgroundColor = #colorLiteral(red: 0.7781245112, green: 0.1633349657, blue: 0.4817854762, alpha: 1)
                self.statusLabelView.transform = self.transRotate1
                self.statusLabel.text = "解析済み"
                //                self.answerTitle.text = "レーダーチャート"
            }else{
                self.noDataText()
                self.answerFlag.text = "解析待ち"
                self.answerFlag.backgroundColor = #colorLiteral(red: 0.3959373832, green: 0.5591574311, blue: 1, alpha: 1)
                self.statusLabelView.backgroundColor = #colorLiteral(red: 0.3959373832, green: 0.5591574311, blue: 1, alpha: 1)
                self.statusLabelView.transform = self.transRotate1
                self.statusLabel.text = "解析待ち"
                //                self.answerTitle.text = "まだ解析はありません"
            }
        })
        let textImage:String = self.selectedApplyID!+".png"
        let refImage = Storage.storage().reference().child("user").child("\(self.currentUid)").child("myApply").child("\(selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("\(textImage)")
        ImageView.sd_setImage(with: refImage, placeholderImage: nil)
        playVideo.addTarget(self, action: #selector(playVideo(_:)), for: .touchUpInside)
        
        let image1:String = "anaImage_1_"+self.selectedApplyID!+".png"
        let image2:String = "anaImage_2_"+self.selectedApplyID!+".png"
        let refImage_ana1 = Storage.storage().reference().child("user").child("\(self.currentUid)").child("myApply").child("\(selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("\(image1)")
        let refImage_ana2 = Storage.storage().reference().child("user").child("\(self.currentUid)").child("myApply").child("\(selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("\(image2)")
        anaImage1.sd_setImage(with: refImage_ana1, placeholderImage: nil)
        anaImage2.sd_setImage(with: refImage_ana2, placeholderImage: nil)
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
        //        ref.observeSingleEvent(of: .value, with: { (snapshot) in
        //            let value = snapshot.value as? NSDictionary
        //            let key = value?["practice"] as? String ?? "-"
        //            self.practice.text = key
        //        })
        //        ref.observeSingleEvent(of: .value, with: { [self] (snapshot) in
        //            let value = snapshot.value as? NSDictionary
        //            let key = value?["URL"] as? String ?? "-"
        //            self.sankouURL.isEditable = false
        //            if key != "-"{
        //                self.sankouURL.text = key
        //
        //                let URLs:[String] = key.components(separatedBy: "\n")
        //
        //                let attributedString = NSMutableAttributedString(string: key)
        //                for url in URLs{
        //                    attributedString.addAttribute(.link,
        //                                                  value: url,
        //                                                  range: NSString(string: key).range(of: url))
        //                }
        //                self.sankouURLHeight.constant = CGFloat(35 + URLs.count*12)
        //                self.sankouURL.font = UIFont.boldSystemFont(ofSize: 20)
        //                self.sankouURL.attributedText = attributedString
        //                self.sankouURL.isSelectable = true
        //                self.sankouURL.delegate = self as UITextViewDelegate
        //            }
        //        })
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
        
        let ref0 = Ref.child("apply").child("\(self.selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("answer").child("analytics").child("total")
        let ref1 = Ref.child("apply").child("\(self.selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("answer").child("analytics").child("criteria").child("headPosition")
        let ref2 = Ref.child("apply").child("\(self.selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("answer").child("analytics").child("criteria").child("arm")
        let ref3 = Ref.child("apply").child("\(self.selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("answer").child("analytics").child("criteria").child("leg")
        let ref4 = Ref.child("apply").child("\(self.selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("answer").child("analytics").child("criteria").child("ground")
        let ref5 = Ref.child("apply").child("\(self.selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("answer").child("analytics").child("criteria").child("axis")
        ref0.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["score"] as? String ?? "-"
            self.totalPoint.text = key
        })
        ref1.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["score"] as? Int ?? 0
            self.headPosition.text = String(key)
        })
        ref2.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["score"] as? Int ?? 0
            self.arm.text = String(key)
        })
        ref3.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["score"] as? Int ?? 0
            self.leg.text = String(key)
        })
        ref4.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["score"] as? Int ?? 0
            self.ground.text = String(key)
        })
        ref5.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["score"] as? Int ?? 0
            self.axis.text = String(key)
        })
    }
    func loadData_ana(){
        
        
        let ref0 = Ref.child("apply").child("\(self.selectedYYYYMM!)").child("\(self.selectedApplyID!)").child("answer").child("analytics").child("point")
        //        let ref1 = Ref.child("analytics").child("feedback")
        ref0.observeSingleEvent(of: .value, with: { [self](snapshot) in
            if let snapdata = snapshot.value as? [String:NSDictionary]{
                //                var i = 1
                //                var str = ""
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    let key0 = snap?["fbFlag"] as? String ?? ""
                    let key1 = snap?["value"] as? String ?? ""
                    let key2 = snap?["diff"] as? String ?? ""
                    let key3 = snap?["fbContent"] as? String ?? ""
                    let key4 = snap?["anaCriteriaID"] as? String ?? ""
                    let key5 = snap?["anaPointID"] as? String ?? ""
                    let key6 = snap?["range_start"] as? String ?? ""
                    let key7 = snap?["range_end"] as? String ?? ""
                    let key8 = snap?["practice"] as? String ?? ""
                    let key9 = snap?["practiceURL"] as? String ?? ""
                    
                    self.anaPointFBFlagArray.append(key0)
                    self.anaPointValueArray.append(Int(key1)!)
                    self.anaPointDiffArray.append(Int(key2)!)
                    self.anaPointFBContentArray.append(key3)
                    self.anaCriteriaIDArray.append(key4)
                    self.anaPointIDArray.append(key5)
                    self.rangeStartArray.append(Int(key6)!)
                    self.rangeEndArray.append(Int(key7)!)
                    self.anaPointPracticeArray.append(key8)
                    self.anaPointPracticeURLArray.append(key9)
                    if anaPointValueArray.count == 13 && rangeStartArray.count == 13{
                        anaPointIDArray_re = ["ANGLE_NECK","ANGLE_R_SHOULDER","ANGLE_L_SHOULDER","ANGLE_R_ELBOW","ANGLE_L_ELBOW","ANGLE_STRIDE","ANGLE_L_HIP","ANGLE_R_KNEE","ANGLE_L_KNEE","ANGLE_R_ANKLE","ANGLE_L_ANKLE","ANGLE_R_COM","ANGLE_AXIS"]
                        for key in anaPointIDArray_re{
                            let number = anaPointIDArray.firstIndex(of: key) ?? 0
                            anaCriteriaIDArray_re.append(anaCriteriaIDArray[number])
                            anaPointValueArray_re.append(anaPointValueArray[number])
                            anaPointDiffArray_re.append(anaPointDiffArray[number])
                            anaPointFBFlagArray_re.append(anaPointFBFlagArray[number])
                            anaPointValueDiffArray_re.append(anaPointValueArray[number])
                            anaPointFBContentArray_re.append(anaPointFBContentArray[number])
                            rangeStartArray_re.append(rangeStartArray[number])
                            rangeEndArray_re.append(rangeEndArray[number])
                            anaPointPracticeArray_re.append(anaPointPracticeArray[number])
                            anaPointPracticeURLArray_re.append(anaPointPracticeURLArray[number])
                            if key == anaPointIDArray_re.last{
                                self.anaResultCollectionView.reloadData()
                            }
                        }
                    }
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return anaPointIDArray_re.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.anaResultCollectionView.dequeueReusableCell(withReuseIdentifier: "anaResultCell", for: indexPath as IndexPath) as? anaResultCollectionViewCell
        let num = convertEnclosedNumber(num: indexPath.row+1)
        cell!.titleBar.layer.cornerRadius = 10
        cell!.titleBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        cell!.numberTitle.text = "角度\(num!)"
        cell!.anaPointFBContent.text = self.anaPointFBContentArray_re[indexPath.row]
        //        if anaCriteriaIDArray_re[indexPath.row] == "headPosition"{
        //            cell!.anaCriteriaView.image = UIImage(named: "icon_prod_headPosition")
        //        }else if anaCriteriaIDArray_re[indexPath.row] == "arm"{
        //            cell!.anaCriteriaView.image = UIImage(named: "icon_prod_arm")
        //        }else if anaCriteriaIDArray_re[indexPath.row] == "leg"{
        //            cell!.anaCriteriaView.image = UIImage(named: "icon_prod_leg")
        //        }else if anaCriteriaIDArray_re[indexPath.row] == "ground"{
        //            cell!.anaCriteriaView.image = UIImage(named: "icon_prod_ground")
        //        }else if anaCriteriaIDArray_re[indexPath.row] == "axis"{
        //            cell!.anaCriteriaView.image = UIImage(named: "icon_prod_axis")
        //        }
        if anaPointFBFlagArray_re[indexPath.row] == "0"{
            cell!.anaCriteriaIcon.image = UIImage(named: "prod_good")
            cell!.recommendIcon.isHidden = true
            cell!.practice.isHidden = true
        }else{
            cell!.anaCriteriaIcon.image = UIImage(named: "bad")
            cell!.recommendIcon.isHidden = false
            cell!.practice.isHidden = false
        }
        cell!.range_start.text = String(rangeStartArray_re[indexPath.row]) + "°"
        cell!.range_end.text = String(rangeEndArray_re[indexPath.row]) + "°"
        cell?.practice.tag = indexPath.row
        cell?.practice.addTarget(self, action: #selector(buttonEvent1(_:)), for: .touchUpInside)
        cell!.practice.setTitle("\(anaPointPracticeArray_re[indexPath.row])", for: .normal)
        
        let length = rangeEndArray_re[indexPath.row] - rangeStartArray_re[indexPath.row]
        print("length:\(length)")
        
        let diff = anaPointValueArray_re[indexPath.row] - rangeStartArray_re[indexPath.row]
        if diff * 160/length >= -40 && diff * 160/length <= 210{
            x_userValue = diff * 160/length
        }else if diff * 160/length < -40{
            x_userValue = -40
        }else{
            x_userValue = 210
        }
        print("x_userValue:\(x_userValue ?? 0)")
        cell!.label.frame = CGRect(x: x_userValue!-5, y: 0, width: 10, height: 10)
        cell!.label1.frame = CGRect(x: x_userValue!-15, y: 0, width: 30, height: 10)
        cell!.label.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        cell!.label1.text = String(anaPointValueArray_re[indexPath.row]) + "°"
        cell!.label1.font = UIFont(name:"Hiragino Sans", size: 10)
        cell!.label1.textColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        cell!.label1.textAlignment = .center
        cell!.athleteValueBarView.addSubview(cell!.label)
        cell!.userValueBarView.addSubview(cell!.label1)
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    // セルの大きさ
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWitdh = view.frame.width-15
        //        let cellHeight = 230
        //        return CGSize(width: cellWitdh, height: cellHeight)
        return CGSize(width: cellWitdh, height: 300)
    }
    
    // セルの余白
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    @objc func buttonEvent1(_ sender: UIButton) {
        practiceURL = anaPointPracticeURLArray_re[sender.tag]
        performSegue(withIdentifier: "practiceURL", sender: nil)
    }
    @IBAction func editButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "editButtonTapped", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "practiceURL"){
            if #available(iOS 13.0, *) {
                let nextData: practiceURLViewController = segue.destination as! practiceURLViewController
                nextData.practiceURL = self.practiceURL!
                
            } else {
                // Fallback on earlier versions
            }
        }else if (segue.identifier == "editButtonTapped"){
            if answerFlag.text == "解析待ち"{
                if #available(iOS 13.0, *) {
                    let nextData: selectedApplyListEditViewController = segue.destination as! selectedApplyListEditViewController
                    nextData.selectedApplyID = self.selectedApplyID!
                } else {
                    // Fallback on earlier versions
                }
            }else{
                let alert: UIAlertController = UIAlertController(title: "確認", message: "回答準備中またはアドバイスを既にもらっているため申請内容を編集できません", preferredStyle:  UIAlertController.Style.alert)
                
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                    (action: UIAlertAction!) -> Void in
                })
                alert.addAction(defaultAction)
                present(alert, animated: true, completion: nil)
            }
        }else{
            
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
//extension ViewController:  UICollectionViewDelegateFlowLayout {
////    セル間の間隔を指定
//    private func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimunLineSpacingForSectionAt section: Int) -> CGFloat {
//        print("yeah")
//        return 100
//    }
//    // セルの大きさ
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let cellWitdh = view.frame.width-15
////        let cellHeight = 230
//        print("wowow")
////        return CGSize(width: cellWitdh, height: cellHeight)
//        return CGSize(width: cellWitdh, height: 230)
//    }
//
//    // セルの余白
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
//
//    // ヘッダーのサイズ
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: self.view.frame.size.width, height:50)
//    }
//}
