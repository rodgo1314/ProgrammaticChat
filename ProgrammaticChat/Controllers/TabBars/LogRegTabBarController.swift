//
//  LogRegTabBarController.swift
//  ProgrammaticChat
//
//  Created by Rodrigo Leyva on 12/3/21.
//

import UIKit

class LogRegTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "PrimaryBackground")
        
        viewControllers = [createLoginVC(), createRegVC()]


    }
    
    
    
   
    
    func createLoginVC() -> UINavigationController{
        let loginVC = LoginVC()
        loginVC.title = "Login"
        loginVC.tabBarItem = UITabBarItem(title: "Login", image: UIImage(systemName: "person.fill.checkmark"), tag: 0)
        return UINavigationController(rootViewController: loginVC)
    }
    
    func createRegVC() -> UINavigationController{
        let registerVC = RegisterVC()
        registerVC.title = "Register"
        registerVC.tabBarItem = UITabBarItem(title: "Register", image: UIImage(systemName: "person.fill.questionmark"), tag: 1)
        return UINavigationController(rootViewController: registerVC)
    }
    

    

}
