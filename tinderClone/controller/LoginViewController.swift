//
//  LoginViewController.swift
//  tinderClone
//
//  Created by Nishant Thakur on 29/05/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet var loginWithFB: UIButton!
    @IBOutlet var loginWithNumber: UIButton!
    //var signInMethod = String()
    struct GlobalVariable{
        static var signInMethod = String()
    }
    let databaseHelper = DatabaseHelper()
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButtonProperties()
         
        navigationController?.isNavigationBarHidden = true
        
        // Do any additional setup after loading the view.
    }
    @IBAction func loginWithFacebookButton(_ sender: UIButton) {
         let fbLoginManager : LoginManager = LoginManager()
        //        fbLoginManager.loginBehavir = .web
                fbLoginManager.logOut()
                fbLoginManager.logIn(permissions: ["email"], from: self) { (result, error) -> Void in
                  if (error == nil){
                    let fbloginresult : LoginManagerLoginResult = result!
                    print(result)
                    // if user cancel the login
                    if (result?.isCancelled)!{
                            return
                    }
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        print("logged in")
//                      self.getFBUserData()
                        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                        
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
                            //MARK:- Facebook connected
                            
                            LoginViewController.GlobalVariable.signInMethod = "facebook"
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

                                        if data["email"] as? String == Auth.auth().currentUser?.email{
                                            temp+=1
                                            print("user already Exists1")
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
                                }else if temp == 0{
                                    //its a new user and needs to register
                                    
                                    let registerVC = self.storyboard?.instantiateViewController(withIdentifier: "NewUserRegisterViewController") as? NewUserRegisterViewController
                                    self.navigationController?.pushViewController(registerVC!, animated: true)
                                }
                            })
                            
                            //self.signInMethod = "facebook"
                            print("signed in")
                            print(Auth.auth().currentUser?.email)
                          // User is signed in
                          // ...
                        }
                    }
                  }
                  else{
                    print(error)
                    }
                }
    }
    @IBAction func loginWithPhoneNumberButton(_ sender: Any) {
    }
    
    
    
    func setButtonProperties(){
        loginWithFB.layer.cornerRadius = loginWithFB.frame.height/2
        loginWithNumber.layer.cornerRadius = loginWithNumber.frame.height/2
        loginWithNumber.layer.borderWidth = 2
        loginWithNumber.layer.borderColor = UIColor.white.cgColor
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
