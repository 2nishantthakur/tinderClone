//
//  SwipeScreenVCExtension.swift
//  tinderClone
//
//  Created by Nishant Thakur on 04/06/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import Foundation
import Firebase

extension SwipeScreenViewController{
    func likeThisUser(UID: String, Name: String){
        //set uid:0 indicates that current user liked certain user
        //uid:1 indicates that certain user likes current user
        //uid:2 indicates that its a match and both users like each other
        
        let ref = db.collection("likes").document((Auth.auth().currentUser?.uid)!)
        print((Auth.auth().currentUser?.uid)!)
        ref.getDocument { (document, error) in
            if let document = document{
                let val = document.get(UID)
                if val == nil{
                    self.db.collection("likes").document(UID).setData([(Auth.auth().currentUser?.uid)!: 1], merge: true)
                    self.db.collection("likes").document("\((Auth.auth().currentUser?.uid)!)").setData(["\(UID)": 0], merge: true)
                }else if val as? Int == 1 || val as? Int == 2{
                    //MARK:- its A Match
                    print("Its A Match!")
                    self.db.collection("likes").document(UID).setData([(Auth.auth().currentUser?.uid)!: 2], merge: true)
                    self.db.collection("likes").document("\((Auth.auth().currentUser?.uid)!)").setData(["\(UID)": 2], merge: true)
                    let alert = UIAlertController(title: "Congratulations!", message: "You Matched With  \(Name)", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    func getCurrentUserLikes(){
        let docRef = db.collection("likes").document("\(Auth.auth().currentUser?.uid)")

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                
                //currentUserLikes
            } else {
                print("Document does not exist")
            }
        }
    }
}
