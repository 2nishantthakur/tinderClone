//
//  LoginWithPhoneNumberViewController.swift
//  tinderClone
//
//  Created by Nishant Thakur on 29/05/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Firebase

class LoginWithPhoneNumberViewController: UIViewController {
    
    @IBOutlet var phoneNumberTF: SkyFloatingLabelTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumberTF.titleFont = UIFont(name: "AppleSDGothicNeo-Thin", size: 20)!
        phoneNumberTF.frame = CGRect(x: phoneNumberTF.frame.minX, y: phoneNumberTF.frame.minY, width: phoneNumberTF.frame.width, height: 60)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func continut(_ sender: ActualGradientButton) {
        if phoneNumberTF.text != nil{
            PhoneAuthProvider.provider().verifyPhoneNumber("+91\(phoneNumberTF.text!)", uiDelegate: nil) { (verificationID, error) in
                if let error = error {
                    print("+91\(self.phoneNumberTF.text!)")
                    print(error.localizedDescription)
                    return
                }else{
                    print("Message Sent")
                    UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                    let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
                    print(verificationID)
                }
                
                let phoneNumberVerificationVC = self.storyboard?.instantiateViewController(withIdentifier: "PhoneNumberVerificationViewController") as? PhoneNumberVerificationViewController
                phoneNumberVerificationVC?.verificationID = verificationID!
                
                if verificationID != nil{
                    self.navigationController?.pushViewController(phoneNumberVerificationVC!, animated: true)
                }
                
                
                // Sign in using the verificationID and the code sent to the user
                // ...
            }
            
        }
        else{
            print("Enter a Phone Number!")
        }
    }
    @IBAction func back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
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
