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

class NewUserRegisterViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePicker = UIImagePickerController()
    let db = Firestore.firestore()
    var age = Int()
    var name = String()
    var gender = String()
    var imageURL = String()
    let myGroup = DispatchGroup()
    
    @IBOutlet var image: UIImageView!
    @IBOutlet var tapRec: UITapGestureRecognizer!
    @IBOutlet var nameTF: SkyFloatingLabelTextField!
    @IBOutlet var genderTF: SkyFloatingLabelTextField!
    @IBOutlet var ageTF: SkyFloatingLabelTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        print("Mode of SignIn = \(LoginViewController.GlobalVariable.signInMethod)")
        tapRec.numberOfTapsRequired = 1
        // Do any additional setup after loading the view.
    }
    
    @IBAction func tapPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
            
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary()
    {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    //MARK:-- ImagePicker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            image.contentMode = .scaleAspectFit
            
            if let editedImage = info[.editedImage] as? UIImage{
                image.image = editedImage
            }
            else{
                image.image = pickedImage
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    //MARK:- uploading image to firestore
    
    func uploadImageToFirestore(image: UIImage) -> String {
        var urlString = String()
        var ref = StorageReference()
//        if LoginViewController.GlobalVariable.signInMethod == "facebook"{
//            ref = Storage.storage().reference().child("\((Auth.auth().currentUser?.email as? String)!).png")
//        }else {
//            ref = Storage.storage().reference().child("\((Auth.auth().currentUser?.phoneNumber as? String)!).png")
//        }
        ref = Storage.storage().reference().child("\((Auth.auth().currentUser?.uid as? String)!).png")
        //let dat = image.jpegData(compressionQuality: 0.5)
        if let uploadData = image.jpegData(compressionQuality: 0.5){
            myGroup.enter()
            ref.putData(uploadData, metadata: nil) { (metaData, error) in
                if error != nil{
                    print(error)
                }else{
                    ref.downloadURL { (url, error) in
                        if error != nil{
                            print(error)
                        }else{
                            urlString = url!.absoluteString
                            self.updateImageURLToFirestore(urlString: urlString)
                        }
                    }
                }
            }
            myGroup.leave()
        }
        return urlString
    }
    //MARK:- updating imageUrl
    func updateImageURLToFirestore(urlString: String){
        db.collection("users").getDocuments { (querySnapshot, error) in
            let snapshotDocuments = querySnapshot?.documents
            for doc in snapshotDocuments!{
                let data = doc.data()
//                if LoginViewController.GlobalVariable.signInMethod == "facebook"{
//                    if data["email"] as? String == Auth.auth().currentUser?.email{
//                        self.db.collection("users").document(doc.documentID).setData(["imageURL": urlString], merge: true)
//                        print("Successfully uploades imageurl")
//                    }
//                }else{
//                    if data["phoneNumber"] as? String == Auth.auth().currentUser?.phoneNumber{
//                        if data["email"] as? String == Auth.auth().currentUser?.email{
//                            self.db.collection("users").document(doc.documentID).setData(["imageURL": urlString], merge: true)
//                            print("Successfully uploades imageurl")
//                        }
//                    }
                //                }
                if data["uid"] as? String == Auth.auth().currentUser?.uid{
                    self.db.collection("users").document(doc.documentID).setData(["imageURL": urlString], merge: true)
                    print("Successfully uploades imageurl")
                }
            }
        }
    }
    
    
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func `continue`(_ sender: ActualGradientButton) {
        
        if image.image != nil{
            imageURL = uploadImageToFirestore(image: image.image!)
            if self.nameTF.text != "" && self.genderTF.text != "" && self.ageTF.text != ""{
                print(self.nameTF.text)
                if self.genderTF.text == "M" || self.genderTF.text == "m" || self.genderTF.text == "F" || self.genderTF.text == "f"{
                    if let age = Int(self.ageTF.text!){
                        self.name = self.nameTF.text!
                        self.gender = self.genderTF.text!
                        LoginViewController.GlobalVariable.currentUserGender = self.gender
                        print("age:\(age) name:\(self.name) gender:\(self.gender)")
                        
                        
//                        if LoginViewController.GlobalVariable.signInMethod == "phoneNumber"{
//                            self.db.collection("users").addDocument(data: ["name": self.name, "age": age, "gender": self.gender, "phoneNumber": Auth.auth().currentUser?.phoneNumber!, "imageURL": self.imageURL, "uid": Auth.auth().currentUser?.uid]) { (error) in
//                                if error != nil{
//                                    print("Successfully Added Data")
//                                }else{
//                                    print(error)
//                                }
//                            }
//                        }else if LoginViewController.GlobalVariable.signInMethod == "facebook"{
//                            self.db.collection("users").addDocument(data: ["name": self.name, "age": age, "gender": self.gender, "email": Auth.auth().currentUser?.email!,"uid": Auth.auth().currentUser?.uid]) { (error) in
//                                if error != nil{
//                                    print("Successfully Added Data")
//                                }else{
//                                    print(error)
//                                }
//                            }
//                        }
                        self.db.collection("users").addDocument(data: ["name": self.name, "age": age, "gender": self.gender, "imageURL": self.imageURL, "uid": Auth.auth().currentUser?.uid]) { (error) in
                            if error != nil{
                                print("Successfully Added Data")
                                let swipeVC = self.storyboard?.instantiateViewController(identifier: "SwipeScreenViewController") as? SwipeScreenViewController
                                self.navigationController?.pushViewController(swipeVC!, animated: true)
                            }else{
                                print(error)
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
        else{
            print("Please choose an image")
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
