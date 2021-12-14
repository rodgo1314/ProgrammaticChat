//
//  NewConversationVC.swift
//  ProgrammaticChat
//
//  Created by Rodrigo Leyva on 12/3/21.
//

import UIKit
import JGProgressHUD

class NewConversationVC: UIViewController {

    var completion: ((ChatAppUser) -> (Void))?
    
    var results = [ChatAppUser]()
    var hasFetched = false

    let spinner = JGProgressHUD(style: .dark)


    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.placeholder = "Search for Users"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSearchBar()
        setUpTableView()

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    
    func setUpSearchBar(){
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
    }
    
    @objc func dismissSelf(){
        dismiss(animated: true)
    }
    
    func setUpTableView(){
        view.addSubview(tableView)
        tableView.backgroundColor = UIColor(named: "PrimaryBackground")
        tableView.delegate = self
        tableView.dataSource = self
    }

}
extension NewConversationVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = results[indexPath.row].firstName + " " + results[indexPath.row].lastName
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //start new conversation
        let targetUserData = results[indexPath.row]
        
        dismiss(animated: true) { [weak self] in
            self?.completion?(targetUserData)
        }
       
        
    }
}

extension NewConversationVC: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty, !text.replacingOccurrences(of: " ", with: "").isEmpty else{
            return
        }
        searchBar.resignFirstResponder()
        
        results.removeAll()
        
        spinner.show(in: view)
        
        self.searchUsers(query: text)

        
    }
    
    func searchUsers(query: String){
        //check if array has firebase results
        if hasFetched{
            
            filterUsers(with: query)
            
        }else{
            DatabaseManager.shared.getAllUsers {[weak self] result in
                switch result{
                case .success(let usersArr):
                    self?.hasFetched = true
                    var tempArr = [ChatAppUser]()
                    usersArr.forEach({ user in
                        guard let name = user["name"],
                              let email = user["email"],
                              let profileURL = user["profile_url"] else {return}
                        
                        let nameCompenents = name.components(separatedBy: " ")
                        
                        let firstName = nameCompenents[0]
                        let lastName = nameCompenents[1]
                        
                        let chatAppUser = ChatAppUser(id: email, firstName: firstName, lastName: lastName, email: email, profilePictureDownloadURL: profileURL)
                        
                        tempArr.append(chatAppUser)
                              
                    })
                    self?.results = tempArr
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print(error)
                }
            }
        }
        
    }
    
    func filterUsers(with term: String){
        guard hasFetched else{
            return
        }
        self.spinner.dismiss()
        
        print(self.results)
        let results: [ChatAppUser] = self.results.filter({
            let name = $0.firstName + " " + $0.lastName
            let lowName = name.lowercased()
            
            return lowName.hasPrefix(term.lowercased())
        })
        print(results)
        
        self.results = results
        
        updateUI()
        
        
    }
    
    func updateUI(){
        if results.isEmpty{
            //Show empty label
            self.tableView.isHidden = true
        }else{
            self.tableView.isHidden = false
            
            self.tableView.reloadData()
        }
    }
}
