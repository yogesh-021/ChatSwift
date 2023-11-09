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
    
    static func safeEmail(emailAddress:String)->String{
        var safeEmail=emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail=safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
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
        var safeEmail=email.replacingOccurrences(of: ".", with: "-")
        safeEmail=safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? String != nil else{
                completion(false)
                return
            }
            completion(true)
        }
    }
     
    /// Insert new user to database
    public func insertUser(with user:ChatAppUser,completion: @escaping(Bool)->Void){
        database.child(user.safeEmail).setValue(["first_name":user.firstName,"last_name":user.lastName]) { error, _ in
            guard error==nil else{
                completion(false)
                return
            }
            
            //In the users feed we want to get all users so we have to create an array of users if not exitst,otherwise append
            //to existing one.(This is done as we are saving individual users,so we want them together also to get them in one call).
            
            /*
             users => [
                 [
                    "name":
                    "email":
                 ]
                 [
                     "name":
                     "email":
                 ]
             ]
             
             */
            self.database.child("users").observeSingleEvent(of: .value) { snapshot,_  in
                if var usersCollection=snapshot.value as? [[String:String]]{
                    //append to user dictionary
                    let newElement=[
                        "name":user.firstName+" "+user.lastName,
                        "email":user.safeEmail
                    ]
                    usersCollection.append(newElement)
                    self.database.child("users").setValue(usersCollection) { Error, _ in
                        guard error==nil else{
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
                else{
                    //create that array
                    let newCollection:[[String:String]]=[
                        [
                            "name":user.firstName+" "+user.lastName,
                            "email":user.safeEmail
                        ]
                    ]
                    self.database.child("users").setValue(newCollection) { Error, _ in
                        guard error==nil else{
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
    
    public func getAllUsers(completion:@escaping (Result<[[String:String]],Error>)->Void){
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value=snapshot.value as? [[String:String]] else{
                completion(.failure(DataBaseError.FailedToFetch))
                return
            }
            completion(.success(value))
        }
    }
    
    public enum DataBaseError:Error{
        case FailedToFetch
    }
}



struct ChatAppUser{
    let firstName:String
    let lastName:String
    let emailAddress:String
    
//    The period (.) is used to separate different parts of the URL, such as the domain and path.
//    The at symbol (@) can be used in some cases for authentication purposes in URLs.
//    To include an email address directly in a URL, you must make sure that these special characters don't interfere with the URL structure.
    var safeEmail:String {
        var safeEmail=emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail=safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFileName: String{
        return "\(safeEmail)_profile_picture.png"
    }
}
