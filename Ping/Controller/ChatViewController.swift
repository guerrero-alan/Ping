//
//  ChatViewController.swift
//  Ping
//
//  Created by Alan Guerrero on 9/5/19.
//  Copyright © 2019 Alan Guerrero. All rights reserved.
//

import UIKit
import Firebase

// MARK: ChatViewController

class ChatViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messageHeightConstraint: NSLayoutConstraint!
    
    // MARK: Properties
    
    let messageDatabase: [Message] = [Message(messageBody: "Message1", sender: "A"), Message(messageBody: "Message2", sender: "B"), Message(messageBody: "Message3", sender: "C")]
    
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
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        messageTableView.reloadData()
    }
    
    // MARK: IBActions
    
    @IBAction func didPressSend(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.messageHeightConstraint.constant = 50
            self.view.layoutIfNeeded()
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
        
        let cell = messageTableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        cell.textLabel?.text = messageDatabase[indexPath.row].messageBody
        cell.detailTextLabel?.text = messageDatabase[indexPath.row].sender
        return cell
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
