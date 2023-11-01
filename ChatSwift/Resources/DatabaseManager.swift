//
//  DatabaseManager.swift
//  ChatSwift
//
//  Created by Yogesh Lamba on 27/10/23.
//


//Allow us to perform operation database regardless of which viewcontroller we are in
import Foundation
import FirebaseDatabase

//Class that can't be subclassed
final class DatabaseManager{
    static let shared=DatabaseManager() //singleton for easy access
    
    private let database=Database.database().reference()
}

//MARK: - Account Management
extension DatabaseManager{
    /*
     As it is NOSQL database so it stores data in form of JSON i.e key-value pair
     e.g.{
            "key" : {
                    values
                }
         }
     */
    
    public func userExists(with email:String, completion: @escaping ((Bool)->Void)){
        let safeEmail=email.replacingOccurrences(of: ".", with: "-")
        safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? String != nil else{
                completion(false)
                return
            }
            completion(true)
        }
    }
     
    /// Insert new user to database
    public func insertUser(with user:ChatAppUser){
        database.child(user.safeEmail).setValue(["first_name":user.firstName,"last_name":user.lastName])
    }
}

struct ChatAppUser{
    let firstName:String
    let lastName:String
    let emailAddress:String
    // let profilePictureUrl:String
    
    var safeEmail:String {
        let safeEmail=emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
