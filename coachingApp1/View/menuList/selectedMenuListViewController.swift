//
//  selectedMenuListViewController.swift
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

class selectedMenuListViewController: UIViewController,UITextViewDelegate {

    @IBOutlet var trainingTitle: UILabel!
    @IBOutlet var memo: UILabel!
    @IBOutlet var sourceURL: UITextView!
    @IBOutlet var date: UILabel!
    @IBOutlet var time: UILabel!
    @IBOutlet var genre: UILabel!
    @IBOutlet var ImageView: UIImageView!

    @IBOutlet var poster: UILabel!
    @IBOutlet var value: UILabel!
    @IBOutlet var target: UILabel!
    @IBOutlet var program: UILabel!
    @IBOutlet var comment: UILabel!
    
    @IBOutlet weak var sourceURLHeight: NSLayoutConstraint!
    @IBOutlet weak var sankouURLHeight: NSLayoutConstraint!

    var selectedMenuID: String?
            
    let imagePickerController = UIImagePickerController()
    var webURL: String?
    
    let currentUid:String = Auth.auth().currentUser!.uid
    let currentUserName:String = Auth.auth().currentUser!.displayName!
    let Ref = Database.database().reference()

    override func viewDidLoad() {

        loadData()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func loadData(){
        
        let ref = Ref.child("trainingMenu").child("\(self.selectedMenuID!)")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["title"] as? String ?? ""
            self.trainingTitle.text = key
        })
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["memo"] as? String ?? ""
            self.memo.text = "~"+key+"~"
            
        })
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["sourceURL"] as? String ?? ""
            self.webURL = key
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
            let key = value?["genre"] as? String ?? ""
            self.genre.text = key
            if key == "基礎"{
                self.genre.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
            }else if key == "短距離"{
                self.genre.backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
            }else if key == "跳躍"{
                self.genre.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
            }else{
                self.genre.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
            }
        })
        let textImage:String = self.selectedMenuID!+".png"
        let refImage = Storage.storage().reference().child("trainingMenu").child("\(self.selectedMenuID!)").child("\(textImage)")
        ImageView.sd_setImage(with: refImage, placeholderImage: nil)

        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["poster"] as? String ?? ""
            self.poster.text = "投稿者：" + key
        })
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["value"] as? String ?? ""
            self.value.text = key
        })
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["target"] as? String ?? ""
            self.target.text = key
        })
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["program"] as? String ?? ""
            self.program.text = key
        })
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["comment"] as? String ?? ""
            self.comment.text = key
        })
        
    }
    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {

        UIApplication.shared.open(URL)

        return false
    }
    @IBAction func buttonTapped(_ sender: Any) {
        performSegue(withIdentifier: "sourceURL", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "sourceURL") {
            if #available(iOS 13.0, *) {
                let nextView: sourceURLViewController = segue.destination as! sourceURLViewController
                    nextView.webURL = self.webURL
            } else {
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
