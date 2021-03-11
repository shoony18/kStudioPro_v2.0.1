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
    @IBOutlet var inviteCodeTextField: UITextField!
    var teamIDArray = [String]()
    var inviteCodeArray = [String]()
    let Ref = Database.database().reference()

    override func viewDidLoad() {
        loadData()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    func loadData(){
        let ref = Ref.child("team")
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
                    if let key = snap!["inviteCode"] as? String {
                        self.inviteCodeArray.append(key)
                        print(self.inviteCodeArray)
                    }
                }
            }
        })
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        
        if teamIDArray.contains("\(teamIDTextField.text ?? "")"){
            let int:Int = teamIDArray.firstIndex(of: teamIDTextField.text ?? "")!
            if inviteCodeArray[int] == inviteCodeTextField.text{
                performSegue(withIdentifier: "fromInvite", sender: nil)
            }
        }else{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "団体IDと招待コードが一致しません。もう一度入力して下さい。", preferredStyle:  UIAlertController.Style.alert)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
