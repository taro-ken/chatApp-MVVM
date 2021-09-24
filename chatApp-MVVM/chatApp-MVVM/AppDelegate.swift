//
//  AppDelegate.swift
//  chatApp-MVVM
//
//  Created by 木元健太郎 on 2021/09/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
        var navigationController: UINavigationController?   //Navigation使用時に追加

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //******** StoryBoad使わないのでここでNavigationを設定
                let viewControllerTest: ChatViewController = ChatViewController()
                navigationController = UINavigationController(rootViewController: viewControllerTest)
                
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = navigationController
                self.window?.makeKeyAndVisible()
                return true
    }


}

