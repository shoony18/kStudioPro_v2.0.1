//
//  applyListViewController.swift
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

class applyListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var TableView: UITableView!
    
    var applyIDArray = [String]()
    var dateArray = [String]()
    var timeArray = [String]()
    var answerFlagArray = [String]()
    var memoArray = [String]()
    var applyStatusArray = [String]()

    var applyIDArray_re = [String]()
    var dateArray_re = [String]()
    var timeArray_re = [String]()
    var eventArray_re = [String]()
    var answerFlagArray_re = [String]()
    var memoArray_re = [String]()
    var applyStatusArray_re = [String]()

    var selectedApplyID: String?
    var selectedYYYYMM: String?

    let imagePickerController = UIImagePickerController()
    var cache: String?
    var videoURL: URL?
    var data:Data?
    var pickerview: UIPickerView = UIPickerView()
    
    let currentUid:String = Auth.auth().currentUser!.uid
    let currentUserName:String = Auth.auth().currentUser!.displayName!
    let Ref = Database.database().reference()
    
    var ActivityIndicator: UIActivityIndicatorView!
    var initilizedView: UIView = UIView()
    var noApplyMessage = UILabel()

    override func viewDidLoad() {
        TableView.dataSource = self
        TableView.delegate = self
        loadData()
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.TableView.reloadData()
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
        let viewWidth = UIScreen.main.bounds.width
        let viewHeight = UIScreen.main.bounds.height
        noApplyMessage.text = "申込履歴がありません"
        noApplyMessage.frame = CGRect(x: viewWidth/4, y: 30, width: viewWidth/2, height: 50)
        noApplyMessage.textColor = .gray
        noApplyMessage.textAlignment = NSTextAlignment.center
        //Viewに追加
        TableView.addSubview(noApplyMessage)

        applyIDArray.removeAll()
        dateArray.removeAll()
        timeArray.removeAll()
        answerFlagArray.removeAll()
        memoArray.removeAll()
        
        applyIDArray_re.removeAll()
        dateArray_re.removeAll()
        timeArray_re.removeAll()
        eventArray_re.removeAll()
        answerFlagArray_re.removeAll()
        memoArray_re.removeAll()
        
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "yyyyMM"
        let date_yyyymm = formatter3.string(from: Date())
        selectedYYYYMM = "all"
        
        Ref.child("user").child("\(self.currentUid)").child("myApply").child("\(selectedYYYYMM!)").observeSingleEvent(of: .value, with: { [self](snapshot) in
            if let snapdata = snapshot.value as? [String:NSDictionary]{
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    if let key1 = snap!["applyID"] as? String {
                        self.applyIDArray.append(key1)
                        self.applyIDArray_re = self.applyIDArray.reversed()
                        initilize()
                    }
                    if let key2 = snap!["date"] as? String {
                        self.dateArray.append(key2)
                        self.dateArray_re = self.dateArray.reversed()
                    }
                    if let key3 = snap!["time"] as? String {
                        self.timeArray.append(key3)
                        self.timeArray_re = self.timeArray.reversed()
                    }
                    if let key4 = snap!["answerFlag"] as? String {
                        self.answerFlagArray.append(key4)
                        self.answerFlagArray_re = self.answerFlagArray.reversed()
                    }
                    if let key5 = snap!["memo"] as? String {
                        self.memoArray.append(key5)
                        self.memoArray_re = self.memoArray.reversed()
                    }
                    if let key5 = snap!["applyStatus"] as? String {
                        self.applyStatusArray.append(key5)
                        self.applyStatusArray_re = self.applyStatusArray.reversed()
                        print(self.applyStatusArray_re)
                    }
                    self.TableView.reloadData()
                }
            }
        })
        let ref0 = Ref.child("user").child("\(self.currentUid)").child("profile")
        ref0.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["cache"] as? String ?? ""
            self.cache = key
            if self.cache == "1"{
                SDImageCache.shared.clearMemory()
                SDImageCache.shared.clearDisk()
                let data = ["cache":"0" as Any] as [String : Any]
                ref0.updateChildValues(data)
            }
        })

    }
    
    func numberOfSections(in myTableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ myTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return applyIDArray_re.count
    }
    
    
    func tableView(_ myTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        noApplyMessage.isHidden = true
        
        let cell = self.TableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as? applyListTableViewCell
        cell!.title.text = self.memoArray_re[indexPath.row]
        cell!.date.text = self.dateArray_re[indexPath.row]
        cell!.time.text = self.timeArray_re[indexPath.row]
        cell!.applyStatus.text = self.applyStatusArray_re[indexPath.row]
        if self.answerFlagArray_re[indexPath.row] == "1"{
            cell!.status.text = "解析準備中"
            cell!.status.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
        }else if self.answerFlagArray_re[indexPath.row] == "2"{
            cell!.status.text = "解析済み"
            cell!.status.backgroundColor = #colorLiteral(red: 0.7781245112, green: 0.1633349657, blue: 0.4817854762, alpha: 1)
        }else  if self.answerFlagArray_re[indexPath.row] == "3"{
            cell!.status.text = "取下げ済"
            cell!.status.backgroundColor = #colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1)
        }else  if self.answerFlagArray_re[indexPath.row] == "0"{
            cell!.status.text = "解析待ち"
            cell!.status.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
        }

        let textImage:String = self.applyIDArray_re[indexPath.row]+".png"
        let refImage = Storage.storage().reference().child("user").child("\(self.currentUid)").child("myApply").child("\(selectedYYYYMM!)").child("\(self.applyIDArray_re[indexPath.row])").child("\(textImage)")
        cell!.ImageView.sd_setImage(with: refImage, placeholderImage: nil)
        if indexPath.row == applyIDArray_re.count-1 {
            self.initilizedView.removeFromSuperview()
        }
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedApplyID = applyIDArray_re[indexPath.row]
        performSegue(withIdentifier: "selectedApply", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "selectedApply") {
            if #available(iOS 13.0, *) {
                let nextData: selectedApplyListViewController = segue.destination as! selectedApplyListViewController
                nextData.selectedApplyID = self.selectedApplyID!
                nextData.selectedYYYYMM = self.selectedYYYYMM
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        loadData()
    }
    
    
}
