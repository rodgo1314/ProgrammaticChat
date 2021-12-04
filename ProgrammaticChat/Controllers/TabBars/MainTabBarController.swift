//
//  MainTabBarController.swift
//  ProgrammaticChat
//
//  Created by Rodrigo Leyva on 12/3/21.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "PrimaryBackground")
        viewControllers = [createHomeVC(),createProfileVC()]

    }
    
    
    func createHomeVC() -> UINavigationController{
        let viewController = ViewController()
        viewController.title = "Home"
        viewController.tabBarItem = UITabBarItem(title: "Messages", image: UIImage(systemName: "message.fill"), tag: 0)
        return UINavigationController(rootViewController: viewController)
    }
    
    func createProfileVC() -> UINavigationController{
        let profileVC = ProfileVC()
        profileVC.title = "Profile"
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.fill"), tag: 1)
        return UINavigationController(rootViewController: profileVC)
    }
    
    

   
}
