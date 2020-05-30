//
//  NewUserRegisterViewController.swift
//  tinderClone
//
//  Created by Nishant Thakur on 30/05/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Firebase

class NewUserRegisterViewController: UIViewController {
    
    
    let db = Firestore.firestore()
    var age = Int()
    var name = String()
    var gender = String()
    @IBOutlet var image: UIImageView!
    //var signInMethod = String()
    
    @IBOutlet var nameTF: SkyFloatingLabelTextField!
    @IBOutlet var genderTF: SkyFloatingLabelTextField!
    @IBOutlet var ageTF: SkyFloatingLabelTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Mode of SignIn = \(LoginViewController.GlobalVariable.signInMethod)")
        // Do any additional setup after loading the view.
    }
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func `continue`(_ sender: ActualGradientButton) {
        if nameTF.text != "" && genderTF.text != "" && ageTF.text != ""{
            print(nameTF.text)
            if genderTF.text == "M" || genderTF.text == "m" || genderTF.text == "F" || genderTF.text == "f"{
                if let age = Int(ageTF.text!){
                    name = nameTF.text!
                    gender = genderTF.text!
                    print("age:\(age) name:\(name) gender:\(gender)")
                    if LoginViewController.GlobalVariable.signInMethod == "phoneNumber"{
                        db.collection("users").addDocument(data: ["name": name, "age": age, "gender": gender, "phoneNumber": Auth.auth().currentUser?.phoneNumber!]) { (error) in
                            if error != nil{
                                print("Successfully Added Data")
                            }else{
                                print(error)
                            }
                        }
                    }else if LoginViewController.GlobalVariable.signInMethod == "facebook"{
                        db.collection("users").addDocument(data: ["name": name, "age": age, "gender": gender, "email": Auth.auth().currentUser?.email!]) { (error) in
                            if error != nil{
                                print("Successfully Added Data")
                            }else{
                                print(error)
                            }
                        }
                    }
                    
                }
                else{
                    print("Fill age Correctly")
                }
                
            }else{
                print("Gender Should be either M or F only")
            }
        
        }else{
            print("Fill All Fields Correctly")
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
