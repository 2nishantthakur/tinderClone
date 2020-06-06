//
//  SwipeScreenViewController.swift
//  tinderClone
//
//  Created by Nishant Thakur on 02/06/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import UIKit
import Firebase

class SwipeScreenViewController: UIViewController {
    
    @IBOutlet var imageShown: UIImageView!
    @IBOutlet var dislikeButton: UIButton!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var shownUserName: UILabel!
    @IBOutlet var shownUserAge: UILabel!
    @IBOutlet var thumbImageView: UIImageView!
    @IBOutlet var secondUserShownImage: UIImageView!
    @IBOutlet var secondUserShownName: UILabel!
    @IBOutlet var secondUserShownAge: UILabel!
    
    var usersShown = [UsersShown]()
    let db = Firestore.firestore()
    var currentuserGender = String()
    let myGroup = DispatchGroup()
    var image = UIImage()
    var shownUserIndex = 1
    var currentUserLikes = [String: Int]()
    
    var users = [[String(), Int(), UIImage(), String()]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageShown.layer.cornerRadius = 10
        secondUserShownImage.layer.cornerRadius = 10
        loadUsersToShow()
        dislikeButton.layer.cornerRadius = dislikeButton.frame.height/2
        likeButton.imageView?.layer.cornerRadius = dislikeButton.layer.cornerRadius

        // Do any additional setup after loading the view.
    }
    func loadUsersToShow(){
        db.collection("users").getDocuments { (querysnapshot, error) in
            let snapshotDocument = querysnapshot?.documents
            for doc in snapshotDocument!{
                let data = doc.data()
                if data["uid"] as? String == Auth.auth().currentUser?.uid {
                    print("CurrentUser")
                }else{
                    let queue = DispatchQueue.global(qos: .background)
                    let user : [UsersShown] = []
                    self.myGroup.enter()
                    queue.async {
                        if let url = URL(string: (data["imageURL"] as? String)!){
                            
                            //MARK:- 2>CREATE A URLSession
                            let session = URLSession(configuration: .default)
                            
                            //MARK:- 3>GIVE the session a task
                            
                            let task = session.dataTask(with: url) { (imageData, response, error) in
                                if error != nil{
                                    print(error)
                                    return
                                }
                                DispatchQueue.main.async {
                                   // self.image = UIImage(data: imageData!)!
                                    if (LoginViewController.GlobalVariable.currentUserGender == "M" && data["gender"] as? String == "F") || (LoginViewController.GlobalVariable.currentUserGender == "F" && data["gender"] as? String == "M"){
                                        self.users.append([data["name"] as? String, data["age"] as? Int, UIImage(data: imageData!)!, data["uid"] as? String])
                                        if self.users.count == 2{
                                            self.imageShown.image = self.users[1][2] as! UIImage
                                            self.shownUserAge.text = String(self.users[1][1] as! Int)
                                            self.shownUserName.text = self.users[1][0] as! String
                                        }
                                    }
                                    
                                    
                                    //self.usersShown.append(user(name: data["name"],age: data["age"], image: UIImage(data: image!)))
                                    
                                }
                                
                            }
                            
                            //MARK:- 4>Start the Task
                            task.resume()
                        }
                        self.myGroup.leave()
                    }
                    
                    
                    
//                    myGroup.notify(queue: queue) {
//
//                    }
                    
                }
            }
        }
    }
    @IBAction func dislikeButton(_ sender: UIButton) {
        print(users.count)
        print(users)
    }
    @IBAction func likeButton(_ sender: UIButton) {
    }
    
    @IBAction func showProfile(_ sender: Any) {
    }
    @IBAction func chats(_ sender: Any) {
        let chatsVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatsViewController") as? ChatsViewController
        navigationController?.pushViewController(chatsVC!, animated: true)
    }
    
    @IBAction func swipeGesture(_ sender: UIPanGestureRecognizer) {
        let queue = DispatchQueue(label: "first")
        if users.count <= shownUserIndex+1{
            secondUserShownImage.image = #imageLiteral(resourceName: "noMoreUsersToShow")
        }else{
            secondUserShownImage.image = users[shownUserIndex + 1][2] as! UIImage
            secondUserShownAge.text = String(users[shownUserIndex + 1][1] as! Int)
            secondUserShownName.text = users[shownUserIndex + 1][0] as! String
        }
        let card = sender.view!
        let point = sender.translation(in: view)
        card.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
        let xFromCenter = card.center.x - view.center.x
        
        thumbImageView.alpha = abs(xFromCenter) / view.center.x
        if sender.state == UIGestureRecognizer.State.ended{
            
            if card.center.x < 75 {
                myGroup.enter()
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3) {
                        card.center = CGPoint(x: card.center.x - 200, y: card.center.y + 60)
                        card.alpha = 0
                        self.myGroup.leave()
                    }
                    return
                }
            }else if card.center.x > (view.frame.width - 75){
                myGroup.enter()
                DispatchQueue.main.async {
                    self.likeThisUser(UID: self.users[self.shownUserIndex][3] as! String, Name: self.users[self.shownUserIndex][0] as! String)
                    UIView.animate(withDuration: 0.3) {
                        card.center = CGPoint(x: card.center.x + 200, y: card.center.y + 60)
                        card.alpha = 0
                        self.myGroup.leave()
                    }
                    return
                }
                
            }
            
            
            UIView.animate(withDuration: 0.2, animations: {
//                card.center = self.view.center
                self.thumbImageView.alpha = 0

            })
            myGroup.notify(queue: .main) {
                if self.users.count <= self.shownUserIndex+1{
                    self.secondUserShownImage.image = #imageLiteral(resourceName: "noMoreUsersToShow")
                }else{
                    self.imageShown.image = self.users[self.shownUserIndex + 1][2] as! UIImage
                    self.shownUserAge.text = String(self.users[self.shownUserIndex + 1][1] as! Int)
                    self.shownUserName.text = self.users[self.shownUserIndex + 1][0] as! String
                    self.shownUserIndex += 1
                    sleep(1)
                    
                    card.center = self.view.center
                    card.alpha = 1
                }
                
            }
            
        }
        
        
        if xFromCenter > 0{
            thumbImageView.image = #imageLiteral(resourceName: "thumb_up")
            thumbImageView.tintColor = UIColor.green
        }else{
            thumbImageView.image = #imageLiteral(resourceName: "thumb_down")
            thumbImageView.tintColor = UIColor.red
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
