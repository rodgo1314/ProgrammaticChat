//
//  ChatVC.swift
//  ProgrammaticChat
//
//  Created by Rodrigo Leyva on 12/5/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage

// message model
struct Message: MessageType {
    public var sender: SenderType // sender for each message
    public var messageId: String // id to de duplicate
    public var sentDate: Date // date time
    public var kind: MessageKind // text, photo, video, location, emoji
}
// sender model
struct Sender: SenderType {
    public var photoURL: String // extend with photo URL
    public var senderId: String
    public var displayName: String
}

struct Media: MediaItem{
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

class ChatVC: MessagesViewController  {
    
    //MARK: Variables
    public let otherUserEmail: String
    private let conversationId: String?
    public var isNewConversation = false
    
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            // we cache the user email
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        return Sender(photoURL: "", senderId: safeEmail, displayName: "Me")
    }
    
    //MARK: Initalizer
    init(with email: String, id: String?) {
        self.conversationId = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
        
        // creating a new conversation, there is no identifier
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init    (coder:) has not been implemented")
    }
    
    //MARK: UI Elements
    public static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    //MARK: View lifecyle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        messageInputBar.delegate = self
        setUpInputButton()
    }
    
    func setUpInputButton(){
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 35, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func presentInputActionSheet(){
        let actionSheet = UIAlertController(title: "Attach Media", message: "What would you like to attach", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoInputActionsheet()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] _ in
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: { [weak self] _ in
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    private func presentPhotoInputActionsheet(){
        let actionSheet = UIAlertController(title: "Attach Photo", message: "Where would you like to attach photo from?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            self?.present(picker, animated: true)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            self?.present(picker, animated: true)
        }))
        
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        
        if let conversationId = conversationId {
            listenForMessages(id:conversationId, shouldScrollToBottom: true)
        }
    }
    
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id) { [weak self] result in
            switch result {
            case .success(let messages):
                print("success in getting messages: \(messages)")
                guard !messages.isEmpty else {
                    print("messages are empty")
                    return
                }
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToLastItem()
                        
                    }
                    
                }
                
            case .failure(let error):
                print("failed to get messages: \(error)")
            }
        }
    }


}
extension ChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let imageData = image.pngData(), let messageID = createMessageId(), let conversationID = conversationId, let name = self.title, let selfSender = selfSender else{
            print("error here when sending photo")
            return
        }
        
        let fileName = "photo_message_" + messageID.replacingOccurrences(of: " ", with: "-") + ".png"
        //upload image
        StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName) {[weak self] result in
            
            guard let strongSelf = self else {
                return
            }
            switch result{
            case .success(let urlString):
                print(urlString)
                //ready to send message
                print("Uploading messaage photo \(urlString)")
                guard let url = URL(string: urlString),
                      let placeHolder = UIImage(systemName: "plus") else {
                          return
                      }
                
                let mediaItem = Media(url: url, image: nil, placeholderImage: placeHolder, size: .zero)
                
                let message = Message(sender: selfSender, messageId: messageID, sentDate: Date(), kind: .photo(mediaItem))
                
                DatabaseManager.shared.sendMessage(to: conversationID, name: name, newMessage: message) { success in
                    if success{
                        print("sent phhoto message")
                    }else{
                        print("error sending photo")
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
        //send image
    }
    
    
}
extension ChatVC: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let selfSender = self.selfSender, let messageId = createMessageId()  else {
            return
        }
        
        print("sending \(text)")
        
        let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
        
        // Send message
        if isNewConversation {
            // create convo in database
            // message ID should be a unique ID for the given message, unique for all the message
            // use random string or random number
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message) { [weak self] success in
                if let conversationID = success {
                    print("message sent")
                    self?.isNewConversation = false
                    self?.listenForMessages(id: conversationID, shouldScrollToBottom: true)
                    inputBar.inputTextView.text = ""
                }else{
                    print("failed to send")
                    inputBar.inputTextView.text = ""


                }
            }
            
        }else {
            guard let conversationId = conversationId, let name = self.title else {
                return
            }
            
            // append to existing conversation data
            DatabaseManager.shared.sendMessage(to: conversationId, name: name, newMessage: message) { success in
                if success {
                    print("message sent")
                    inputBar.inputTextView.text = ""


                }else {
                    print("failed to send")
                    inputBar.inputTextView.text = ""


                }
            }
            
        }
        
    }
    private func createMessageId() -> String? {
        // date, otherUserEmail, senderEmail, randomInt possibly
        // capital Self because its static
    
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        
    
        print("created message id: \(newIdentifier)")
        return newIdentifier
        
    }
}

extension ChatVC: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        // show the chat bubble on right or left?
        if let sender = selfSender {
            return sender
        }
        fatalError("Self sender is nil, email should be cached")
        return Sender(photoURL: "", senderId: "12", displayName: "")
        
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        
        
        return messages[indexPath.section] // message kit framework uses section to separate every single message
        // a message on screen might have mulitple pieces (cleaner to have a single section per message)
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        guard let message = message as? Message else {
            return
        }
        
        switch message.kind{
        case .photo(let media ):
            guard let imageURL = media.url else {
                return
            }
            imageView.sd_setImage(with: imageURL, completed: nil)
            
        default:
            break
        }
    }
    
    

    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        DatabaseManager.shared.getUserProfileURL(for: messages[indexPath.section].sender.senderId) { result in
            switch result{
            case .success(let url):
                print(url)
                avatarView.sd_setImage(with: URL(string: url)!, placeholderImage: UIImage(systemName: "person.circle"))
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
}

extension ChatVC: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let message = messages[indexPath.section]
        
        switch message.kind{
        case .photo(let media ):
            guard let imageURL = media.url else {
                return
            }
            let vc = PhotoViewerVC(with: imageURL)
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true)
            
        default:
            break
        }
    }
    
    
}


extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}
