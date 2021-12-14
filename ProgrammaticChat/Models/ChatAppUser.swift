//
//  ChatAppUser.swift
//  ProgrammaticChat
//
//  Created by Rodrigo Leyva on 12/4/21.
//

import Foundation

enum DatabaseError: Error{
    case failedToFetch
}
//let newConversationData: [String:Any] = [
//    "id": conversationId,
//    "other_user_email": otherUserEmail,
//    "name": name,
//    "latest_message": [
//        "date": dateString,
//        "message": message,
//        "is_read": false,
//
//    ],
//
//]

struct Conversation{
    var id : String
    var name: String
    var otherUserEmail: String
    var latestMessage : LatestMessage
}
struct LatestMessage{
    var date: String
    var text: String
    var isRead: Bool
}

struct ChatAppUser: Codable{
    var id: String
    
    var firstName: String
    var lastName: String
    var email: String
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
    
    var profilePictureDownloadURL: String
    
    var safeEmail: String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
