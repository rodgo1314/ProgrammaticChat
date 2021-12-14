//
//  ProfileVC.swift
//  ProgrammaticChat
//
//  Created by Rodrigo Leyva on 12/3/21.
//

import UIKit
import FirebaseAuth
import SwiftUI
import FacebookLogin
import JGProgressHUD
import SDWebImage

class ProfileVC: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "Background02")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    let profilePictureView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 3.0
        imageView.layer.shadowRadius = 30
        imageView.layer.shadowColor = UIColor.systemGray.cgColor
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.systemPurple.cgColor
        imageView.layer.cornerRadius = 75
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .title1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let profileView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        view.backgroundColor = UIColor(named: "BlurBackground")
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.layer.cornerRadius = 12
        blurView.clipsToBounds = true
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        return blurView
    }()
    
    let logOutButton: UIButton = {
        let button = UIButton(frame: .zero)
        
        button.setTitle("Log Out", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        button.setTitleColor(UIColor.systemBackground, for: .normal)
        button.backgroundColor = UIColor(named: "TabBarTint")
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(logOutPressed), for: .touchUpInside)
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBackgroundImage()
        setUpProfileView()
        getImageAndName()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true

    }
    
    func getImageAndName(){
        guard let email = UserDefaults.standard.value(forKey: "email") as? String,
              let name = UserDefaults.standard.value(forKey: "name") as? String else {
                  return
              }
        DatabaseManager.shared.getUserProfileURL(for: email) {[weak self] result in
            switch result{
            case .success(let urlString):
                guard let url = URL(string: urlString) else {
                    return
                }
                
                self?.profilePictureView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person"))
                self?.nameLabel.text = name
                
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    func setUpProfileView(){
        view.addSubview(profileView)
        blurView.frame = profileView.bounds
        profileView.addSubview(blurView)
        view.addSubview(profilePictureView)
        profileView.addSubview(nameLabel)
        profileView.addSubview(logOutButton)
        
        NSLayoutConstraint.activate([
            profileView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            profileView.heightAnchor.constraint(equalToConstant: 300),
            profileView.widthAnchor.constraint(equalToConstant: 300),
            
            profilePictureView.heightAnchor.constraint(equalToConstant: 150),
            profilePictureView.widthAnchor.constraint(equalToConstant: 150),
            profilePictureView.topAnchor.constraint(equalTo: profileView.topAnchor, constant: -50),
            profilePictureView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameLabel.centerXAnchor.constraint(equalTo: profileView.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: profileView.centerYAnchor),
            
            logOutButton.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 30),
            logOutButton.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -30),
            logOutButton.bottomAnchor.constraint(equalTo: profileView.bottomAnchor, constant: -35)

        
        ])
    }
    func setUpBackgroundImage(){
        view.addSubview(backgroundImageView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        ])
        
    }
    
    
    @objc func logOutPressed(){
        spinner.textLabel.text = "Logging Out"
        spinner.show(in: self.view)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            do{
                UserDefaults.standard.removeObject(forKey: "email")
                UserDefaults.standard.removeObject(forKey: "name")

                FBSDKLoginKit.LoginManager().logOut()
                try Auth.auth().signOut()
                self.spinner.dismiss(animated: true)

            }catch{
                
            }
        }
    }
}


