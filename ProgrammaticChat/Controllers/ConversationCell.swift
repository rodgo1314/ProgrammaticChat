//
//  ConversationCell.swift
//  ProgrammaticChat
//
//  Created by Rodrigo Leyva on 12/9/21.
//

import UIKit

class ConversationCell: UITableViewCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .title1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 3
        label.font = .preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let profileView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 3.0
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        setUpViews()
        
    }
    
    func setUpViews(){
        contentView.addSubview(profileView)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(lastMessageLabel)
        
        NSLayoutConstraint.activate([
            profileView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            profileView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            //profileView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            profileView.widthAnchor.constraint(equalToConstant: 100),
            profileView.heightAnchor.constraint(equalToConstant: 100),
            profileView.trailingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: -30),
            
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        
        ])
    }
    
    func setImage(with: String){
        DatabaseManager.shared.getUserProfileURL(for: with) {[weak self] result in
            switch result{
            case .success(let url):
                print(url)
                self?.profileView.sd_setImage(with: URL(string: url)!, placeholderImage: UIImage(systemName: "person.circle"))
                
                
            case .failure(let error):
                print(error)
            }
        }
    }
    

}

extension UIImageView {
  public func maskCircle(anyImage: UIImage) {
    self.contentMode = UIView.ContentMode.scaleAspectFill
    self.layer.cornerRadius = self.frame.height / 2
    self.layer.masksToBounds = false
    self.clipsToBounds = true

   // make square(* must to make circle),
   // resize(reduce the kilobyte) and
   // fix rotation.
   self.image = anyImage
  }
}
