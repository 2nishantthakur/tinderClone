//
//  DatabaseHelper.swift
//  tinderClone
//
//  Created by Nishant Thakur on 30/05/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import Foundation
import Firebase

struct DatabaseHelper{
    let db = Firestore.firestore()
    
    
    func checkIfUserAlreadyExists() -> Bool{
        var temp = 0
        let signInMethod = LoginViewController.GlobalVariable.signInMethod
        db.collection("users").getDocuments { (querySnapshot, error) in
            if error != nil{
                print(error)
                
            }else{
                let snapshotDocuments = querySnapshot?.documents
                for doc in snapshotDocuments!{
                    let data = doc.data()
                    print(signInMethod)
                    if signInMethod == "facebook"{
                        if data["email"] as? String == Auth.auth().currentUser?.email{
                            temp+=1
                            print("user already Exists1")
                        
                        }
                    }else if signInMethod == "phoneNumber"{
                        if data["phoneNumber"] as? String == Auth.auth().currentUser?.phoneNumber{
                            print("user already Exists1")
                            temp+=1
                        }
                    }
                }
            }
        }
        
        print (temp)
        if temp == 0{
            return false
        }
        else{
            return true
        }
    }
}
