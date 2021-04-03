//
//  menuListViewController.swift
//  coachingApp1
//
//  Created by 刈田修平 on 2021/03/13.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseMessaging
import Photos
import MobileCoreServices
import AssetsLibrary
import SDWebImage

class menuListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var TableView: UITableView!
    
    var menuIDArray = [String]()
    var titleArray = [String]()
    var memoArray = [String]()
    var dateArray = [String]()
    var timeArray = [String]()
    var genreArray = [String]()
    var posterArray = [String]()

    var selectedMenuID: String?

    let imagePickerController = UIImagePickerController()

    let currentUid:String = Auth.auth().currentUser!.uid
    let currentUserName:String = Auth.auth().currentUser!.displayName!
    let Ref = Database.database().reference()

    override func viewDidLoad() {
        TableView.dataSource = self
        TableView.delegate = self
        loadData()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func loadData(){

        menuIDArray.removeAll()
        dateArray.removeAll()
        timeArray.removeAll()
        genreArray.removeAll()

        Ref.child("trainingMenu").observeSingleEvent(of: .value, with: { [self](snapshot) in
            if let snapdata = snapshot.value as? [String:NSDictionary]{
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    if let key = snap!["menuID"] as? String {
                        self.menuIDArray.append(key)
                        self.TableView.reloadData()
                    }
                }
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    if let key = snap!["title"] as? String {
                        self.titleArray.append(key)
                        self.TableView.reloadData()
                    }
                }
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    if let key = snap!["memo"] as? String {
                        self.memoArray.append(key)
                        self.TableView.reloadData()
                    }
                }
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    if let key = snap!["date"] as? String {
                        self.dateArray.append(key)
                        self.TableView.reloadData()
                    }
                }
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    if let key = snap!["time"] as? String {
                        self.timeArray.append(key)
                        self.TableView.reloadData()
                    }
                }
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    if let key = snap!["genre"] as? String {
                        self.genreArray.append(key)
                        self.TableView.reloadData()
                    }
                }
                for key in snapdata.keys.sorted(){
                    let snap = snapdata[key]
                    if let key = snap!["poster"] as? String {
                        self.posterArray.append(key)
                        self.TableView.reloadData()
                    }
                }
            }
        })
    }
    
    func numberOfSections(in myTableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ myTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuIDArray.count
    }
    
    
    func tableView(_ myTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.TableView.dequeueReusableCell(withIdentifier: "trainingCell", for: indexPath as IndexPath) as? menuListTableViewCell
        cell!.title.text = self.titleArray[indexPath.row]
        cell!.memo.text = "~"+self.memoArray[indexPath.row]+"~"
        cell!.date.text = self.dateArray[indexPath.row]
        cell!.time.text = self.timeArray[indexPath.row]
        if self.genreArray[indexPath.row] == "基礎"{
            cell!.genre.text = self.genreArray[indexPath.row]
            cell!.genre.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
        }else if self.genreArray[indexPath.row] == "短距離"{
            cell!.genre.text = self.genreArray[indexPath.row]
            cell!.genre.backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        }else if self.genreArray[indexPath.row] == "跳躍"{
            cell!.genre.text = self.genreArray[indexPath.row]
            cell!.genre.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
        }else{
            cell!.genre.text = self.genreArray[indexPath.row]
            cell!.genre.backgroundColor = #colorLiteral(red: 0.7781245112, green: 0.1633349657, blue: 0.4817854762, alpha: 1)
        }
        cell!.poster.text = self.posterArray[indexPath.row]

        let textImage:String = self.menuIDArray[indexPath.row]+".png"
        let refImage = Storage.storage().reference().child("trainingMenu").child("\(self.menuIDArray[indexPath.row])").child("\(textImage)")
        cell!.ImageView.sd_setImage(with: refImage, placeholderImage: nil)
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMenuID = menuIDArray[indexPath.row]
        performSegue(withIdentifier: "selectedTrainingMenu", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "selectedTrainingMenu") {
            if #available(iOS 13.0, *) {
                let nextData: selectedMenuListViewController = segue.destination as! selectedMenuListViewController
                nextData.selectedMenuID = self.selectedMenuID!
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        loadData()
    }
}
