//
//  RegisterViewController.swift
//  Ping
//
//  Created by Alan Guerrero on 9/4/19.
//  Copyright © 2019 Alan Guerrero. All rights reserved.
//

import UIKit
import Firebase

// MARK: RegisterViewController

class RegisterViewController: UIViewController {

    // MARK: IBOutlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: IBActions
    
    @IBAction func didPressRegister(_ sender: Any) {
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (result, error) in
            if let error = error {
                print(error)
               return
            } else {
                print("Successfully Registered")
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }
    }
    
}
