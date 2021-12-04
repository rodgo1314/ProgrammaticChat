//
//  LoginVC.swift
//  ProgrammaticChat
//
//  Created by Rodrigo Leyva on 12/3/21.
//

import UIKit

class LoginVC: UIViewController {
    
    //MARK: UI Elements
        
    
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "Background01")
        imageView.contentMode = .bottomRight
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    let logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "Illustration 1")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emailTextField: UITextField = {
        let textfield = UITextField()
        
        textfield.placeholder = "abc@gmail.com"
        textfield.font = UIFont.preferredFont(forTextStyle: .title2)
        textfield.translatesAutoresizingMaskIntoConstraints = false
        return textfield
    }()
    
    let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Password"
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let passwordTextField: UITextField = {
        let textfield = UITextField()
        
        textfield.placeholder = "********"
        textfield.font = UIFont.preferredFont(forTextStyle: .title2)
        textfield.translatesAutoresizingMaskIntoConstraints = false

        
        return textfield
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(frame: .zero)
        
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        button.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.5)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(loginPressed), for: .touchUpInside)
        return button
    }()
    @objc func loginPressed(){
        print("login")
    }
    
    //MARK: View lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    //MARK: AutoLayout setup

    func setUpViews(){
        setUpBackgroundImage()
        setUpLogoView()
        setUpStackView()

    }
    
    func setUpBackgroundImage(){
        view.addSubview(backgroundImageView)
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            
        ])
    }
    
    func setUpLogoView(){
        view.addSubview(logoImage)
        NSLayoutConstraint.activate([

            logoImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            logoImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            logoImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            logoImage.heightAnchor.constraint(equalToConstant: 150)
        
        ])
        
    }
    
    func setUpStackView() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 20.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(emailLabel)
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(passwordLabel)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(loginButton)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalToConstant: 300),
            stackView.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 0)
        ])
        
    }
    
    
    
    
}
