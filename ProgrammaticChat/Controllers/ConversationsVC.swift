//
//  ViewController.swift
//  ProgrammaticChat
//
//  Created by Rodrigo Leyva on 12/3/21.
//

import UIKit
import JGProgressHUD

class ConversationsVC: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    private var conversations = [Conversation]()


    //MARK: UI Elements
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "Background02")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundView = UIImageView(image: UIImage(named: "Background02")!)
        table.register(ConversationCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No conversations"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    //MARK: View lifcyle methods 
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "AccentColor")
        //setUpBackgroundImage()
        setupTableView()
        fetchConversations()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    @objc private func didTapComposeButton(){
        // present new conversation view controller
        // present in a nav controller
        
        let vc = NewConversationVC()
        vc.title = "New Convo"
        vc.view.backgroundColor = UIColor(named: "PrimaryBackground")
        
        vc.completion = {[weak self] result in
            print(result)
            self?.createNewConversation(result: result)
            self?.fetchConversations()
            
        }
        
        let nav = UINavigationController(rootViewController: vc)
        
        present(nav, animated: true)
        
    }
    
    private func createNewConversation(result: ChatAppUser){
        
    
        let name = result.firstName + " " + result.lastName
        //let email = result.email
        
        let vc = ChatVC(with: result.safeEmail , id: nil)
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
    }
    private func setupTableView(){
        view.addSubview(tableView)
        tableView.backgroundColor = UIColor(named: "PrimaryBackground")
        tableView.delegate = self
        tableView.dataSource = self
        
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
    
    private func fetchConversations(){
        // fetch from firebase and either show table or label
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.shared.getAllConversations(for: safeEmail) {[weak self] result in
            switch result{
            case.success(let converstations):
                self?.conversations = converstations
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("could get convos ")
                print(error.localizedDescription)
                
            }
        }
    }


}

extension ConversationsVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ConversationCell
        cell.nameLabel.text = conversations[indexPath.row].name
        cell.lastMessageLabel.text = conversations[indexPath.row].latestMessage.text
        cell.setImage(with: conversations[indexPath.row].otherUserEmail)
        cell.backgroundColor = UIColor(named: "BlurBackground")
        return cell
    }
    
    // when user taps on a cell, we want to push the chat screen onto the stack
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let conversation = conversations[indexPath.row]
        let vc = ChatVC(with: conversation.otherUserEmail, id: conversation.id)
        vc.title = conversation.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
}

