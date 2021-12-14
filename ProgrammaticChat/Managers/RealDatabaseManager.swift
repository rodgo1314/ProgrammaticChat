//
//  RealDatabaseManager.swift
//  ProgrammaticChat
//
//  Created by Rodrigo Leyva on 12/4/21.
//

import Foundation
import FirebaseDatabase
import MessageKit
import UIKit

final class DatabaseManager{
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress: String) -> String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    func createUser(user: ChatAppUser, completion: @escaping(Bool)->Void ){
        
        
        database.child(user.safeEmail).setValue([
            "first_name" : user.firstName,
            "last_name" : user.lastName,
            "profile_url" : user.profilePictureDownloadURL
        ]) { error, reference in
            guard  error == nil else{
                print("error in database ")
                return
            }
            /*
             users => [
             ]
             */
            
            self.database.child("users").observeSingleEvent(of: .value) { snapShot in
                if var usersCollection = snapShot.value as? [[String: String]]{
                    //append to users
                    let newElement = ["name" : user.firstName + " " + user.lastName,
                                      "email" : user.safeEmail,
                                      "profile_url" : user.profilePictureDownloadURL
                    ]
                    usersCollection.append(newElement)
                    
                    self.database.child("users").setValue(usersCollection) { error, _ in
                        guard error == nil else{
                            completion(false)
                            
                            return
                        }
                        
                        completion(true)
                    }
                    
                }else{
                    //create that array
                    let newCollection: [[String:String]] = [
                        ["name" : user.firstName + " " + user.lastName,
                         "email" : user.safeEmail,
                         "profile_url" : user.profilePictureDownloadURL
                        ]
                    ]
                    self.database.child("users").setValue(newCollection) { error, ref in
                        guard error == nil else{
                            completion(false)
                            
                            return
                        }
                        completion(true)
                    }
                }
            }
            
            completion(true)
        }
        
    }
    
    
}

// MARK: - account management
extension DatabaseManager {
    
    public func userExists(with email:String, completion: @escaping ((Bool) -> Void)) {
        // will return true if the user email does not exist
        
        // firebase allows you to observe value changes on any entry in your NoSQL database by specifying the child you want to observe for, and what type of observation you want
        // let's observe a single event (query the database once)
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            // snapshot has a value property that can be optional if it doesn't exist
            
            guard snapshot.value as? String != nil else {
                // otherwise... let's create the account
                completion(false)
                return
            }
            
            // if we are able to do this, that means the email exists already!
            
            completion(true) // the caller knows the email exists already
        }
    }
    
    public func getUserProfileURL(for userEmail: String, completion: @escaping (Result<String,Error>) -> Void){
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: userEmail)
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapShot in
            
            guard let user = snapShot.value as? [String: Any],
                  let profileURL = user["profile_url"] as? String else {
                      completion(.failure(DatabaseError.failedToFetch))
                      return
                  }
            
            completion(.success(profileURL))
            
        }
        
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void){
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
            
        }
    }
    public enum DatabaseError: Error {
        case failedToFetch
    }
}

// MARK: - Sending Messages / conversations
extension DatabaseManager {
    
    /*  "conversation_id" {
     "messages": [
     {
     "id": String,
     "type": text, photo, video
     "content": String,
     "date": Date(),
     "sender_email": String,
     "isRead": true/false,
     }
     ]
     }
     
     
     conversation => [
     [
     "conversation_id":
     "other_user_email":
     "latest_message": => {
     "date": Date()
     "latest_message": "message"
     "is_read": true/false
     }
     
     ],
     
     ]
     
     */
    
    /// creates a new conversation with target user email and first message sent
    public func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (String?) -> Void) {
        // put conversation in the user's conversation collection, and then 2. once we create that new entry, create the root convo with all the messages in it
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String
        else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail) // cant have certain characters as keys
        
        // find the conversation collection for the given user (might not exist if user doesn't have any convos yet)
        
        let ref = database.child("\(safeEmail)")
        // use a ref so we can write to this as well
        
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            // what we care about is the conversation for this user
            guard var userNode = snapshot.value as? [String: Any] else {
                // we should have a user
                completion(nil)
                print("user not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatVC.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationId = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String:Any] = [
                "id": conversationId,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false,
                    
                ],
                
            ]
            
            //
            let recipient_newConversationData: [String:Any] = [
                "id": conversationId,
                "other_user_email": safeEmail, // us, the sender email
                "name": currentName,  // self for now, will cache later
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false,
                    
                ],
                
            ]
            // update recipient conversation entry
            
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    // append
                    conversations.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversationId)
                }else {
                    // reciepient user doesn't have any conversations, we create them
                    // create
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                }
            }
            
            
            // update current user conversation entry
            
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // conversation array exits for current user, you should append
                
                // points to an array of a dictionary with quite a few keys and values
                // if we have this conversations pointer, we would like to append to it
                
                conversations.append(newConversationData)
                
                userNode["conversations"] = conversations // we appended a new one
                
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(nil)
                        return
                    }
                    self?.finishCreatingConversation(name: name, conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                }
            }else {
                // create this conversation
                // conversation array doesn't exist
                
                userNode["conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(nil)
                        return
                    }
                    self?.finishCreatingConversation(name: name, conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                }
                
            }
            
        }
        
    }
    
    private func finishCreatingConversation(name: String, conversationID:String, firstMessage: Message, completion: @escaping (String?) -> Void){
        //        {
        //            "id": String,
        //            "type": text, photo, video
        //            "content": String,
        //            "date": Date(),
        //            "sender_email": String,
        //            "isRead": true/false,
        //        }
        
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatVC.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(nil)
            return
        }
        
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false,
            "name": name,
        ]
        
        let value: [String:Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        print("adding convo: \(conversationID)")
        database.child("\(conversationID)").setValue(value) { error, _ in
            guard error == nil else {
                completion(nil)
                return
            }
            
            completion(conversationID)
        }
        
    }
    /// Fetches and returns all conversations for the user with
    
    
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        database.child("\(email)/conversations").observe(.value) { snapshot in
            // new conversation created? we get a completion handler called
            guard let value = snapshot.value as? [[String:Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let conversations: [Conversation] = value.compactMap { dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                          return nil
                      }
                
                // create model
                
                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                
                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)
            }
            
            completion(.success(conversations))
            
        }
    }
    
    
    /// gets all messages from a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(.value) { snapshot in
            // new conversation created? we get a completion handler called
            guard let value = snapshot.value as? [[String:Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let messages: [Message] = value.compactMap { dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageID = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let date = ChatVC.dateFormatter.date(from: dateString)
                else {
                    return nil
                }
                var kind: MessageKind?
                
                if type == "photo"{
                    guard let imageURL = URL(string: content), let placeHolder = UIImage(systemName: "plus") else {
                        return nil
                    }
                    let media = Media(url: imageURL, image: nil, placeholderImage: placeHolder, size: CGSize(width: 300, height: 300))
                    kind = .photo(media)
                }else{
                    kind = .text(content)
                }
                
                guard let finalKind = kind else {
                    return nil
                }
                
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                
                return Message(sender: sender, messageId: messageID, sentDate: date,
                               kind: finalKind)
                
            }
            
            completion(.success(messages))
            
        }
    }
    
    ///// Sends a message with target conversation and message
    public func sendMessage(to conversation: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        // return bool if successful
        
        // add new message to messages
        // update sender latest message
        // update recipient latest message
        
        self.database.child("\(conversation)/messages").observeSingleEvent(of: .value) { [weak self] snapshot in
            
            guard let strongSelf = self else {
                return
            }
            
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = ChatVC.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString{
                    message = targetUrlString
                }
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }
            
            let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
            
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,
                "is_read": false,
                "name": name,
            ]
            
            currentMessages.append(newMessageEntry)
            
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
                
            }
            
        }
        
    }
    
}

