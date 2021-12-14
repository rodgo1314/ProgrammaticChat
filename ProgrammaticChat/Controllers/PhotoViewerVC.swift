//
//  PhotoViewerVC.swift
//  ProgrammaticChat
//
//  Created by Rodrigo Leyva on 12/9/21.
//

import UIKit
import SDWebImage

class PhotoViewerVC: UIViewController {

    private var url: URL
    
    init(with url: URL){
        self.url = url

        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "PrimaryBackground")
        
        setUpNavigationBar()

        
        view.addSubview(imageView)
        
        self.imageView.sd_setImage(with: url, completed: nil)

        // Do any additional setup after loading the view.
    }
    func setUpNavigationBar(){
        title = "Photo"
        navigationController?.navigationBar.prefersLargeTitles = true

        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(dismissSelf))
        
    }
    @objc func dismissSelf(){
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
    }
    
    
    
    
    
    
    
    

}
