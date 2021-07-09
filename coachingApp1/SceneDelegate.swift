//
//  SceneDelegate.swift
//  coachingApp1
//
//  Created by 刈田修平 on 2021/01/24.
//

import UIKit
import Firebase
import FirebaseUI
import FirebaseAuth
import AVFoundation
import AVKit
import Messages
import UserNotifications
import StoreKit
//import FBSDKCoreKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
//        guard let _ = (scene as? UIWindowScene) else { return }

//        let currentUid:String = Auth.auth().currentUser!.uid

        let windows = UIWindow(windowScene: scene as! UIWindowScene)
        self.window = windows
        windows.makeKeyAndVisible()
        let sb = UIStoryboard(name: "Main", bundle: Bundle.main)

        let ref = Database.database().reference().child("setting").child("maintenance")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = value?["flag"] as? String ?? ""
            if key == "1"{
                let vc = sb.instantiateViewController(withIdentifier: "maintenanceView")
                self.window!.rootViewController = vc
            }
        })

        if Auth.auth().currentUser == nil {
            let vc = sb.instantiateViewController(withIdentifier: "loginView")
            window!.rootViewController = vc
        } else {
            let vc = sb.instantiateViewController(withIdentifier: "mainView")
            self.window!.rootViewController = vc
        }
    }
    
    
//    func scene(_ scene:UIScene, openURLContexts URLContexts:Set<UIOpenURLContext>){
//        guard let url = URLContexts.first?.url else {
//            return
//        }
////        ApplicationDelegate.shared.application( UIApplication.shared, open: url, sourceApplication: nil, annotation: [UIApplication.OpenURLOptionsKey.annotation]
////        )
//    }

        

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}
//func maintenanceCheck(){
//    let sb = UIStoryboard(name: "Main", bundle: Bundle.main)
//
//    let window = UIWindow(frame: UIScreen.main.bounds)
//    window.makeKeyAndVisible()
//
//    let ref = Database.database().reference().child("setting").child("maintenance")
//    ref.observeSingleEvent(of: .value, with: { (snapshot) in
//        let value = snapshot.value as? NSDictionary
//        let key = value?["flag"] as? String ?? ""
//        if key == "1"{
//            let vc = sb.instantiateViewController(withIdentifier: "maintenanceView")
//            window.rootViewController = vc
//        }
//    })
//}
