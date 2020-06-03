//
//  PhoneNumberVerificationViewController.swift
//  tinderClone
//
//  Created by Nishant Thakur on 29/05/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Firebase


class PhoneNumberVerificationViewController: UIViewController {

    let databaseHelper = DatabaseHelper()
    let db = Firestore.firestore()
    //var signInMethod = String()
    var verificationID = String()
    @IBOutlet var verificationNumberTF: SkyFloatingLabelTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }
    @IBAction func back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func `continue`(_ sender: ActualGradientButton) {
        if verificationNumberTF.text == nil{
            print("Enter Verification Code!")
        }else{
            let verificationCode = verificationNumberTF.text!
            let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode)
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
              if let error = error {
                let authError = error as NSError
                if ( authError.code == AuthErrorCode.secondFactorRequired.rawValue) {
                  // The user is a multi-factor user. Second factor challenge is required.
                  let resolver = authError.userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                  var displayNameString = ""
                  for tmpFactorInfo in (resolver.hints) {
                    displayNameString += tmpFactorInfo.displayName ?? ""
                    displayNameString += " "
                  }
                  self.showTextInputPrompt(withMessage: "Select factor to sign in\n\(displayNameString)", completionBlock: { userPressedOK, displayName in
                    var selectedHint: PhoneMultiFactorInfo?
                    for tmpFactorInfo in resolver.hints {
                      if (displayName == tmpFactorInfo.displayName) {
                        selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                      }
                    }
                    PhoneAuthProvider.provider().verifyPhoneNumber(with: selectedHint!, uiDelegate: nil, multiFactorSession: resolver.session) { verificationID, error in
                      if error != nil {
                        print("Multi factor start sign in failed. Error: \(error.debugDescription)")
                      } else {
                        self.showTextInputPrompt(withMessage: "Verification code for \(selectedHint?.displayName ?? "")", completionBlock: { userPressedOK, verificationCode in
                          let credential: PhoneAuthCredential? = PhoneAuthProvider.provider().credential(withVerificationID: verificationID!, verificationCode: verificationCode!)
                          let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator.assertion(with: credential!)
                          resolver.resolveSignIn(with: assertion!) { authResult, error in
                            if error != nil {
                              print("Multi factor finanlize sign in failed. Error: \(error.debugDescription)")
                            } else {
                              self.navigationController?.popViewController(animated: true)
                            }
                          }
                        })
                      }
                    }
                  })
                } else {
                  self.showMessagePrompt(error.localizedDescription)
                  return
                }
                // ...
                return
                }
                LoginViewController.GlobalVariable.signInMethod = "phoneNumber"
                //self.signInMethod = "phoneNumber"
                print("Signed In")
                
                
                var temp = 0
                let myGroup = DispatchGroup()
                let signInMethod = LoginViewController.GlobalVariable.signInMethod
                myGroup.enter()
                self.db.collection("users").getDocuments { (querySnapshot, error) in
                    if error != nil{
                        print(error)

                    }else{
                        let snapshotDocuments = querySnapshot?.documents
                        for doc in snapshotDocuments!{
                            myGroup.enter()
                            let data = doc.data()
                            print(signInMethod)

                            if data["uid"] as? String == Auth.auth().currentUser?.uid{
                                temp+=1
                                print("user already Exists!")
                                LoginViewController.GlobalVariable.currentUserGender = (data["gender"] as? String)!
                            }
                            myGroup.leave()
                        }
                        
                    }
                    myGroup.leave()
                }
                
                myGroup.notify(queue: .main, execute: {
                    print(temp)
                    
                    //MARK:- user already exists or not
                    
                    if temp == 1{
                        //user is already registered
                        print("Y")
                        let swipeVC = self.storyboard?.instantiateViewController(identifier: "SwipeScreenViewController") as? SwipeScreenViewController
                        self.navigationController?.pushViewController(swipeVC!, animated: true)
                        print(Auth.auth().currentUser?.uid)
                    }else if temp == 0{
                        //its a new user and needs to register
                        
                        let registerVC = self.storyboard?.instantiateViewController(withIdentifier: "NewUserRegisterViewController") as? NewUserRegisterViewController
                        self.navigationController?.pushViewController(registerVC!, animated: true)
                    }
                })
                
                //self.signInMethod = "facebook"
                print("signed in")
                print(Auth.auth().currentUser?.email)
                
                
//                self.databaseHelper.checkIfUserAlreadyExists()
//                let RegisterVC = self.storyboard?.instantiateViewController(withIdentifier: "NewUserRegisterViewController") as? NewUserRegisterViewController
//                self.navigationController?.pushViewController(RegisterVC!, animated: true)
//                print(LoginViewController.GlobalVariable.signInMethod)
//                print(Auth.auth().currentUser?.phoneNumber)
              // User is signed in
              // ...
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
