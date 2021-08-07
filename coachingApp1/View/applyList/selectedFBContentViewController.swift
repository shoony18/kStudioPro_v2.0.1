//
//  selectedFBContentViewController.swift
//  coachingApp1
//
//  Created by 刈田修平 on 2021/08/07.
//

import UIKit
import Firebase
import FirebaseDatabase
import youtube_ios_player_helper

class selectedFBContentViewController: UIViewController,YTPlayerViewDelegate {

    @IBOutlet weak var movieView: YTPlayerView!
    @IBOutlet weak var anaCriteriaTitle: UILabel!
    @IBOutlet weak var point: UILabel!
    @IBOutlet weak var practice: UILabel!
    var selectedAnaCriteriaID: String?
    let currentUid:String = Auth.auth().currentUser!.uid
    let currentUserName:String = Auth.auth().currentUser!.displayName!
    let Ref = Database.database().reference()

    var ActivityIndicator: UIActivityIndicatorView!
    var initilizedView: UIView = UIView()

    override func viewDidLoad() {
        initilize()
        loadData()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        let ref0 = Ref.child("analytics").child("feedback").child("\(selectedAnaCriteriaID!)")
        ref0.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["anaCriteriaTitle"] as? String ?? ""
            self.anaCriteriaTitle.text = key
        })
        ref0.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["point"] as? String ?? ""
            self.point.text = key
        })
        ref0.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["practice"] as? String ?? ""
            self.practice.text = key
        })
        ref0.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["movieID"] as? String ?? ""
            self.movieView.delegate = self
            self.movieView.load(withVideoId: "\(key)")
            self.initilizedView.removeFromSuperview()
        })

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
