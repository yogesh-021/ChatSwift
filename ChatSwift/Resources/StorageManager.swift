//
//  StorageManager.swift
//  ChatSwift
//
//  Created by Yogesh Lamba on 08/11/23.
//

import Foundation
import FirebaseStorage

final class StorageManager{
    static let shared=StorageManager()
    private let storage=Storage.storage().reference()
    
    ///Uploads data to firebase storage and returns completion with url string to download
    public func uploadProfilePicture(with data:Data,fileName:String,completion: @escaping(Result<String,Error>)->Void){
        storage.child("images/\(fileName)").putData(data) { metadata,error in
            guard error==nil else{
                completion(.failure(StorageError.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url=url else{
                    completion(.failure(StorageError.failedToGetDownURL))
                    return
                }
                
                let urlString=url.absoluteString
                completion(.success(urlString))
                
            }
        }
    }
    
    public enum StorageError:Error{
        case failedToUpload
        case failedToGetDownURL
    }
    
    public func downloadURL(for path:String,completion: @escaping(Result<URL,Error>)->Void){
        let reference=storage.child(path)
        reference.downloadURL { url, error in
            guard let url=url,error==nil else{
                print("here")
                completion(.failure(StorageError.failedToGetDownURL))
                return
            }
            completion(.success(url))
        }
    }
}
