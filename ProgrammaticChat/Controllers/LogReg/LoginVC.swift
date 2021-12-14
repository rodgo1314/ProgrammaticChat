//
//  LoginVC.swift
//  ProgrammaticChat
//
//  Created by Rodrigo Leyva on 12/3/21.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import FacebookLogin
import JGProgressHUD

class LoginVC: UIViewController {
    
    //MARK: Variables
    private let spinner = JGProgressHUD(style: .dark)
    
    //MARK: UI Elements
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    let scrollViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
        button.backgroundColor = UIColor(named: "TabBarTint")
        button.setTitleColor(UIColor.systemBackground, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(loginPressed), for: .touchUpInside)
        return button
    }()
    
    //MAKE CUSTOM google button with image
    let googleSignInButton: GIDSignInButton = {
        let googleButton = GIDSignInButton()
        googleButton.addTarget(self, action: #selector(googleLoginPressed), for: .touchUpInside)
        
        
        return googleButton
    }()
    
    let facebookLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email", "public_profile"]
        return button
    }()
    
    
    let needAccountLabel: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        let text = NSMutableAttributedString(string: "Don't have an account? ")
        text.addAttribute(NSAttributedString.Key.font, value: UIFont.preferredFont(forTextStyle: .body), range: NSMakeRange(0, text.length))
        let selectablePart = NSMutableAttributedString(string: "Sign up!")
        selectablePart.addAttribute(NSAttributedString.Key.font, value: UIFont.preferredFont(forTextStyle: .body), range: NSMakeRange(0, selectablePart.length))
        
        selectablePart.addAttribute(NSAttributedString.Key.link, value: "register", range: NSMakeRange(0,selectablePart.length))
        
        text.append(selectablePart)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        text.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, text.length))
        
        textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.magenta, NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        // Set the text view to contain the attributed text
        textView.attributedText = text
        
        textView.isEditable = false
        textView.isSelectable = true
        textView.textColor = UIColor.systemGray
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        return textView
    }()
    
    //MARK: Login Logic
    @objc func googleLoginPressed(){
        self.spinner.show(in: self.view)
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            self.spinner.dismiss(animated: true)
            
            if let error = error {
                // ...
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                guard let strongSelf = self else {
                    return
                    
                }
                
                
                
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
                guard let authResult = authResult else {return}
                print(authResult.user.uid)
                
                let currentUserID = authResult.user.uid
                UserDefaults.standard.set(authResult.user.email, forKey: "email")
                UserDefaults.standard.set(authResult.user.displayName, forKey: "name")

            }
            
        }
    }
    
    @objc func loginPressed(){
        
        
        guard let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            // alert user
            alertUser(message: "Don't leave any fields empty and password must be longer and 6 characters.")
            return
        }
        
        //show spinner or loading
        spinner.show(in: self.view)
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
                
            }
            strongSelf.spinner.dismiss(animated: true)
            
            if let error = error{
                print(error.localizedDescription)
                return
            }
            guard let authResult = authResult else {return}
            print(authResult.user.uid)
            
            UserDefaults.standard.set(authResult.user.email, forKey: "email")
            UserDefaults.standard.set(authResult.user.displayName, forKey: "name")
            

        }
        
    }
    
    func alertUser(message: String){
        let alert = UIAlertController(title: "Whoops", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: View lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "PrimaryBackground")
        needAccountLabel.delegate = self
        facebookLoginButton.delegate = self
        setUpViews()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    //MARK: Navigation bar setup
    
    
    func registerButtonClicked(){
        let registerVC = RegisterVC()
        registerVC.title = "Register"
        
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
    //MARK: AutoLayout setup
    
    func setUpViews(){
        setupScrollView()
        setUpBackgroundImage()
        setUpLogoView()
        setUpStackView()
        
    }
    func setupScrollView(){
        view.addSubview(scrollView)
        scrollView.addSubview(scrollViewContainer)
        NSLayoutConstraint.activate([
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scrollViewContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            scrollViewContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollViewContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollViewContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollViewContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
        ])
        
    }
    
    func setUpBackgroundImage(){
        scrollViewContainer.addSubview(backgroundImageView)
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: scrollViewContainer.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: scrollViewContainer.trailingAnchor)
            
        ])
    }
    
    func setUpLogoView(){
        view.addSubview(logoImage)
        NSLayoutConstraint.activate([
            
            logoImage.topAnchor.constraint(equalTo: scrollViewContainer.safeAreaLayoutGuide.topAnchor),
            logoImage.leadingAnchor.constraint(equalTo: scrollViewContainer.leadingAnchor, constant: 50),
            logoImage.trailingAnchor.constraint(equalTo: scrollViewContainer.trailingAnchor, constant: -50),
            logoImage.heightAnchor.constraint(equalToConstant: 150)
            
        ])
        
    }
    
    func setUpStackView() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollViewContainer.addSubview(stackView)
        stackView.addArrangedSubview(emailLabel)
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(passwordLabel)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(loginButton)
        stackView.addArrangedSubview(googleSignInButton)
        stackView.addArrangedSubview(facebookLoginButton)
        stackView.addArrangedSubview(needAccountLabel)
        
        
        NSLayoutConstraint.activate([
            
            stackView.leadingAnchor.constraint(equalTo: scrollViewContainer.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollViewContainer.trailingAnchor, constant: -20),
            
            stackView.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: scrollViewContainer.bottomAnchor, constant: 0),
            stackView.heightAnchor.constraint(equalToConstant: 60 * 8)
        ])
        
    }
    
    
    
    
}
extension LoginVC: UITextViewDelegate{
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        // **Perform sign in action here**
        registerButtonClicked()
        
        return false
    }
}

//MARK: Facebook login
extension LoginVC: LoginButtonDelegate{
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let accessTokenString = AccessToken.current?.tokenString else {return}
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, name"], tokenString: accessTokenString, version: nil, httpMethod: .get)
        
        facebookRequest.start { _, result, error in
            self.spinner.show(in: self.view)

            guard let result = result as? [String: Any], error == nil else {
                print("Failed to make gacebook graph request")
                self.spinner.dismiss(animated: true)

                return
            }
            self.spinner.dismiss(animated: true)
            //Grab user infor from facebook
            guard let userName = result["name"] as? String,
                  let email = result["email"] as? String,
                  let userID = result["id"] as? String else{
                      return
                  }
            
            let nameCompenents = userName.components(separatedBy: " ")
            
            let firstName = nameCompenents[0]
            let lastName = nameCompenents[1]
            let profilePictureUrl = "https://graph.facebook.com/\(userID)/picture?type=large"
            
            let credential = FacebookAuthProvider
                .credential(withAccessToken: accessTokenString)
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                guard let strongSelf = self else {
                    return
                    
                }
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
                guard let authResult = authResult, let isNewUser = authResult.additionalUserInfo?.isNewUser else {return}
                
                print(authResult.user.uid)
                
                let currentUserID = authResult.user.uid
                
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(firstName + " " + lastName, forKey: "name")

                //check if user exits if they don't then register them into the data base
                
                if isNewUser{
                    
                    let user = ChatAppUser(id: currentUserID, firstName: firstName, lastName: lastName, email: email, profilePictureDownloadURL: profilePictureUrl)
                    
                    DatabaseManager.shared.createUser(user: user) { success in
                        if success{
                            print("Succesfully registered user and updated photo url")
                        }else{
                            print("Error creating User")
                        }
                    }
                    
                }
            }
        }

    }
}

//clickable Text Link
extension NSMutableAttributedString {
    
    public func setAsLink(textToFind:String, linkURL:String) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: foundRange)
            return true
        }
        return false
    }
}
