//
//  RegisterVC.swift
//  ProgrammaticChat
//
//  Created by Rodrigo Leyva on 12/3/21.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterVC: UIViewController {
    
    //MARK: Variables
    var selectedProfileImage: UIImage?
    private let spinner = JGProgressHUD(style: .dark)



    //MARK: UI Elements
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
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
        imageView.image = #imageLiteral(resourceName: "Background02")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "camera.viewfinder")
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
    let firstNameLabel: UILabel = {
        let label = UILabel()
        label.text = "First Name"
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let firstNameTextField: UITextField = {
        let textfield = UITextField()
        
        textfield.placeholder = "Johnny"
        textfield.font = UIFont.preferredFont(forTextStyle: .title2)
        textfield.translatesAutoresizingMaskIntoConstraints = false

        
        return textfield
    }()
    
    let lastNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Last Name"
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let lastNameTextField: UITextField = {
        let textfield = UITextField()
        
        textfield.placeholder = "Appleseed"
        textfield.font = UIFont.preferredFont(forTextStyle: .title2)
        textfield.translatesAutoresizingMaskIntoConstraints = false

        
        return textfield
    }()
    
    let registerButton: UIButton = {
        let button = UIButton(frame: .zero)
        
        button.setTitle("Register", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        button.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.5)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(registerPressed), for: .touchUpInside)
        return button
    }()
    
    //MARK: Register Logic
    
    @objc func registerPressed(){
        guard let email = emailTextField.text?.lowercased(), let password = passwordTextField.text, !email.isEmpty, !password.isEmpty, password.count >= 6, let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let profileImage = selectedProfileImage else {
            
            // alert user
            alertUser(message: "Don't leave any fields empty, please select a profile image, and password must be longer than 6 characters.")
            return
        }
        
        
        
        self.spinner.show(in: view)
        
        
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            //show loading screen
            
            
            if let error = error{
                self?.alertUser(message: error.localizedDescription)
                return
            }
            
            guard let userID = authResult?.user.uid else{
                return
            }
            
            //compress image for smaller size to upload
            guard let data = profileImage.jpegData(compressionQuality: 0.25) else{
                return
            }
            
            
            let fileName = "images/\(userID)_profile_picture.png"
            StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) {[weak self] result in
                
                self?.spinner.dismiss()
                switch result{
                case .success(let downloadURL):
                    print(downloadURL)
                    let user = ChatAppUser(id: userID, firstName: firstName, lastName: lastName, email: email, profilePictureDownloadURL: downloadURL)
                    
                    DatabaseManager.shared.createUser(user: user) { success in
                        if success{
                            UserDefaults.standard.set(email.lowercased(), forKey: "email")
                            UserDefaults.standard.set(firstName + " " + lastName, forKey: "name")


                            print("Succesfully registered user and updated photo url")
                        }else{
                            print("Error creating User")
                        }
                    }
//                    UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
//                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
//                    UserDefaults.standard.set(email, forKey: "email")
//                    UserDefaults.standard.set(userID, forKey: "uid")
                    
                case .failure(let error):
                    print(error)
                }
            }
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
        setUpViews()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    //MARK: AutoLayout setup
    
    func setUpViews(){
        setUpBackgroundImage()
        setUpScrollView()
        setUpLogoView()
        setUpStackView()
        

    }
    
    func setUpScrollView(){
        view.addSubview(scrollView)
        scrollView.addSubview(scrollViewContainer)
        NSLayoutConstraint.activate([
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            scrollViewContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            scrollViewContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollViewContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 50),
            scrollViewContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollViewContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
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
    func setUpLogoView(){
        scrollViewContainer.addSubview(logoImage)
        NSLayoutConstraint.activate([

            logoImage.topAnchor.constraint(equalTo: scrollViewContainer.safeAreaLayoutGuide.topAnchor),
            logoImage.leadingAnchor.constraint(equalTo: scrollViewContainer.leadingAnchor, constant: 50),
            logoImage.trailingAnchor.constraint(equalTo: scrollViewContainer.trailingAnchor, constant: -50),
            logoImage.heightAnchor.constraint(equalToConstant: 150)
        
        ])
        logoImage.isUserInteractionEnabled = true

        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(chooseImagePressed))
        logoImage.addGestureRecognizer(gesture)
        
    }
    
    @objc func chooseImagePressed(){
        presentImagePickerActionSheet()

    }
    
    func setUpStackView(){
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
        stackView.addArrangedSubview(firstNameLabel)
        stackView.addArrangedSubview(firstNameTextField)
        stackView.addArrangedSubview(lastNameLabel)
        stackView.addArrangedSubview(lastNameTextField)
        stackView.addArrangedSubview(registerButton)
        
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollViewContainer.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollViewContainer.trailingAnchor, constant: -20),
            
            stackView.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: scrollViewContainer.bottomAnchor)
        ])
    }
  

}

extension RegisterVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func presentImagePickerActionSheet(){
        
        let alertSheet = UIAlertController(title: "Select profile image", message: "How would you like to select image?", preferredStyle: .actionSheet)
        
        alertSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            
            self?.presentCamera()
        }))
        
        alertSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            
            self?.presentLibrary()
            
        }))
        
        present(alertSheet, animated: true, completion: nil)
        
        
    }
    
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true, completion: nil)
    }
    
    func presentLibrary(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.selectedProfileImage = selectedImage
        
        logoImage.image = selectedImage
        logoImage.contentMode = .scaleAspectFill
        logoImage.clipsToBounds = true
        logoImage.layer.cornerRadius = 30
        logoImage.layer.borderWidth = 2
        logoImage.layer.borderColor = UIColor.lightGray.cgColor
        
        picker.dismiss(animated: true, completion: nil)
        
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
