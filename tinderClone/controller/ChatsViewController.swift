//
//  ChatsViewController.swift
//  tinderClone
//
//  Created by Nishant Thakur on 05/06/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import UIKit
import Firebase

class ChatsViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    let db = Firestore.firestore()
    var chatUsers = [[String(), String(), UIImage()]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "ChatsTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        loadChatUsers()
        // Do any additional setup after loading the view.
    }
    func loadChatUsers(){
        db.collection("likes").document("\((Auth.auth().currentUser?.uid)!)").getDocument { (document, error) in
            if error != nil{
                print(error!)
            }else{
                let data = document?.data()
                if data != nil{
                    for user in data!{
                        if user.value as? Int == 2{
                        //    self.chatUsers.append((user.key as? String)!)
                            print(user.key)
                            self.db.collection("users").document("\((user.key as? String)!)").getDocument { (document, error) in
                                if error != nil{
                                    print(error!)
                                }else{
                                    let likedUserData = document?.data()
                                    if let imageURL = likedUserData!["imageURL"] as? String{
                                        if let url = URL(string: imageURL){
                                            
                                            //MARK:- 2>CREATE A URLSession
                                            let session = URLSession(configuration: .default)
                                            
                                            //MARK:- 3>GIVE the session a task
                                            let task = session.dataTask(with: url) { (imageData, response, error) in
                                                if error != nil{
                                                    print(error)
                                                }else{
                                                    self.chatUsers.append([likedUserData!["uid"] as? String, likedUserData!["name"] as? String, UIImage(data: imageData!)!])
                                                   // print(self.chatUsers)
                                                    DispatchQueue.main.async {
                                                        
                                                        self.tableView.reloadData()
                                                       // cell.profilePicture.image = UIImage(data: data!)
                                                    }
                                                }
                                            }
                                            //MARK:- 4>Start the Task
                                            task.resume()
                                        }
                                    }
                                    
                                    
                                }
                            }
                            
                            
                            
                        }
                    }
                }
                
            }
        }
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func logOut(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            print("Logged Out")
            navigationController?.popToRootViewController(animated: true)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
}
extension ChatsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(chatUsers.count - 1)
        return chatUsers.count - 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ChatsTableViewCell
        cell?.userImage.image = chatUsers[indexPath.row + 1][2] as? UIImage
        cell?.userName.text = chatUsers[indexPath.row + 1][1] as? String
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
        print(chatUsers)
//        chatVC?.name.text = chatUsers[indexPath.row + 1][1] as? String
        chatVC?.recieverUID = chatUsers[indexPath.row + 1][0] as! String
//        chatVC?.image.image = chatUsers[indexPath.row + 1][2] as? UIImage
        chatVC?.profileImage = (chatUsers[indexPath.row + 1][2] as? UIImage)!
        chatVC?.otherUserName = (chatUsers[indexPath.row + 1][1] as? String)!
        navigationController?.pushViewController(chatVC!, animated: true)
    }
    
    
}
