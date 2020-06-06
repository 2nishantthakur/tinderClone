//
//  ChatViewController.swift
//  tinderClone
//
//  Created by Nishant Thakur on 06/06/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    @IBOutlet var image: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var messageTF: UITextField!
    @IBOutlet var tableView: UITableView!
    
    var profileImage = UIImage()
    var otherUserName = String()
    var recieverUID = String()
    var messages = [Message]()
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image.layer.cornerRadius = image.frame.width/2
        image.image = profileImage
        name.text = otherUserName
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "cell")
        loadMessages()
        tableView.delegate = self
        tableView.dataSource = self
        

        // Do any additional setup after loading the view.
    }
    func loadMessages() {
        messages = []
        db.collection("messages").order(by: "date").addSnapshotListener{ (querySnapshot, error) in
            self.messages = []
            if let e = error{
                print("There was isssue retrieving data from firestore")
            }else{
                if let snapshotDocuments = querySnapshot?.documents{
                    for doc in snapshotDocuments{
                        let data = doc.data()
                        if let messageSender = data["sender"] as? String,let messageBody = data["messageBody"] as? String,let messageReciever = data["reciever"] as? String{
                            var newMessage = Message()
                            newMessage.sender = messageSender
                            newMessage.reciever = messageReciever
                            newMessage.messageBody = messageBody
                            
                            if (newMessage.sender == Auth.auth().currentUser?.uid && newMessage.reciever == self.recieverUID) || (newMessage.reciever == Auth.auth().currentUser?.uid && newMessage.sender == self.recieverUID){
                                self.messages.append(newMessage)

                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func send(_ sender: Any) {
        if messageTF.text != ""{
            if let messageBody =  messageTF.text, let messageSender = Auth.auth().currentUser?.uid{
                db.collection("messages").addDocument(data: ["sender": messageSender, "messageBody": messageBody, "date": Date().timeIntervalSince1970, "reciever": recieverUID]) { (error) in
                    if let e = error{
                        print("There was an issue saving data on firestore!")
                    }else{
                        print("Successfully Saved Data")
                        DispatchQueue.main.async {
                            self.messageTF.text = ""
                        }
                    }
                }
            }
        }
    }
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
extension ChatViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MessageCell
        cell.label.text = message.messageBody
        print(message.reciever)
        if message.sender == Auth.auth().currentUser?.uid && message.reciever == recieverUID{
            cell.otherUserImage.isHidden = true
            cell.label.textAlignment = .right
            cell.messageBubble.backgroundColor = UIColor(named: "skyBlue")
            cell.label.textColor = UIColor.white
        }else if message.reciever == Auth.auth().currentUser?.uid && message.sender == recieverUID{
            cell.otherUserImage.isHidden = false
            cell.otherUserImage.image = image.image
            cell.messageBubble.backgroundColor = UIColor.lightGray
            cell.label.textColor = UIColor.black
        }
        cell.backgroundColor = .clear
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
}
