//
//  StorageManager.swift
//  ProgrammaticChat
//
//  Created by Rodrigo Leyva on 12/4/21.
//

import Foundation
import FirebaseStorage

final class StorageManager{
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String,Error>)-> Void
    ///Uploads picture to firebase storage and returns URL where located in Firebase Storeage
    ///
    func uploadProfilePicture(with data: Data, fileName: String, completionHandler: @escaping UploadPictureCompletion){
        
        storage.child(fileName).putData(data, metadata: nil) { storageMetaData, error in
            
            guard error == nil else{
                completionHandler(.failure(StorageError.failedUpload))
                return
            }
            
            self.downloadURL(for: fileName) { result in
                switch result{
                case .success(let url):
                    let urlString = url.absoluteString
                    completionHandler(.success(urlString))
                case .failure(let error):
                    print("Error\(error)")
                    completionHandler(.failure(error))
                
                }
            }
            
            
            
        }
        
    }
    ///Upload image that will be send in a conversation message
    func uploadMessagePhoto(with data: Data, fileName: String, completionHandler: @escaping UploadPictureCompletion){
        
        storage.child("message_images/\(fileName)").putData(data, metadata: nil) { storageMetaData, error in
            
            guard error == nil else{
                completionHandler(.failure(StorageError.failedUpload))
                return
            }
            
            self.downloadURL(for: "message_images/\(fileName)") { result in
                switch result{
                case .success(let url):
                    let urlString = url.absoluteString
                    completionHandler(.success(urlString))
                case .failure(let error):
                    print("Error\(error)")
                    completionHandler(.failure(error))
                
                }
            }
            
            
            
        }
        
    }
    
    func downloadURL(for path: String, completion: @escaping (Result<URL,Error>)->Void){
        self.storage.child(path).downloadURL { downloadUrl, error in
            print(path)
            guard let url = downloadUrl else{
                completion(.failure(StorageError.failedToGetDownloadURL))
                return
            }
            
            completion(.success(url))
        }
    }
    
    
    
    enum StorageError: Error{
        case failedUpload
        
        case failedToGetDownloadURL
    }
}
