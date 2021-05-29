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
    var teamIDArray = [String]()
    var passCodeArray = [String]()
    var selectedTeamID:String?
    let Ref = Database.database().reference()

    let currentUid:String = Auth.auth().currentUser!.uid

    override func viewDidLoad() {
        loadData()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        
        if teamIDArray.contains("\(teamIDTextField.text ?? "")"){
            let int:Int = teamIDArray.firstIndex(of: teamIDTextField.text ?? "")!
            if passCodeArray[int] == passCodeTextField.text{
                let ref1 = Ref.child("user").child("\(currentUid)").child("profile")
                let data = ["teamID":"\(teamIDTextField.text ?? "")","passcode":"\(passCodeTextField.text ?? "")"]
                ref1.updateChildValues(data)

                performSegue(withIdentifier: "fromInvite", sender: nil)
            }
        }else{
            let alert: UIAlertController = UIAlertController(title: "確認", message: "団体IDとパスコードが一致しません。もう一度入力して下さい。", preferredStyle:  UIAlertController.Style.alert)
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
            } else {
                // Fallback on earlier versions
            }
        }
    }
}
