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
                self.databaseHelper.checkIfUserAlreadyExists()
                let RegisterVC = self.storyboard?.instantiateViewController(withIdentifier: "NewUserRegisterViewController") as? NewUserRegisterViewController
                self.navigationController?.pushViewController(RegisterVC!, animated: true)
                print(LoginViewController.GlobalVariable.signInMethod)
                print(Auth.auth().currentUser?.phoneNumber)
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
