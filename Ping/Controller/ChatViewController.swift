//
//  ChatViewController.swift
//  Ping
//
//  Created by Alan Guerrero on 9/5/19.
//  Copyright © 2019 Alan Guerrero. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

// MARK: ChatViewController

class ChatViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sendMessageButton: UIButton!
    // MARK: Properties
    
    var messageDatabase:[Message] = []
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTextField.delegate = self
        
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "messageCell")
        
        configureTableView()
        retreivemessages()
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        messageTableView.reloadData()
    }
    
    // MARK: IBActions
    
    @IBAction func didPressSend(_ sender: UIButton) {
        messageTextField.endEditing(true)
        messageTextField.isEnabled = false
        sendMessageButton.isEnabled = false
        
        let messagesDB = Database.database().reference().child("Messages")
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email,
                                 "MessageBody": messageTextField.text!]
        messagesDB.childByAutoId().setValue(messageDictionary) { (error, reference) in
            if error != nil {
                print(error!)
            } else {
                print("Message Saved")
                self.sendMessageButton.isEnabled = true
                self.messageTextField.isEnabled = true
                self.messageTextField.text = ""
            }
        }
    }
    
    @IBAction func didPressLogout(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            dismiss(animated: true)
        } catch {
            print(error)
        }
    }
    
    // MARK: Functions
    
    func retreivemessages() {
        let messagesDB = Database.database().reference().child("Messages")
        messagesDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! [String: String]
            let messageBody = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            let message = Message(messageBody: messageBody, sender: sender)
            self.messageDatabase.append(message)
            DispatchQueue.main.async {
                self.messageTableView.reloadData()
            }
        }
    }
    
    @objc func tableViewTapped() {
        messageTextField.endEditing(true)
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageDatabase.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = messageTableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageTableViewCell
        cell.messageBodyLabel.text = messageDatabase[indexPath.row].messageBody
        cell.senderLabel.text = messageDatabase[indexPath.row].sender
        
        if cell.senderLabel.text == Auth.auth().currentUser?.email {
            cell.messageBackground.backgroundColor = UIColor.flatMint()
            cell.senderLabel.textColor = UIColor.flatSkyBlue()
        } else {
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
             cell.senderLabel.textColor = UIColor.flatMint()
        }
        return cell
    }
    
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 10.0
    }
}

// MARK: UITextFieldDelegate

extension ChatViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        UIView.animate(withDuration: 0.5) {
            self.messageHeightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            var keyboardHeight = keyboardRectangle.height
            
            if #available(iOS 11.0, *) {
                let bottomInset = view.safeAreaInsets.bottom
                keyboardHeight -= bottomInset
            }
            
            UIView.animate(withDuration: 0.5) {
                self.messageHeightConstraint.constant = CGFloat(50 + keyboardHeight)
                self.view.layoutIfNeeded()
            }
        }
    }
    
}
