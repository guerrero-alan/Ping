//
//  LoginViewController.swift
//  Ping
//
//  Created by Alan Guerrero on 9/4/19.
//  Copyright © 2019 Alan Guerrero. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import ChameleonFramework

//MARK: LoginViewController

class LoginViewController: UIViewController {

    //MARK: IBOutlets

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: IBActions

    @IBAction func didPressLogin(_ sender: UIButton) {
        SVProgressHUD.show()
        
        Auth.auth().signIn(withEmail: usernameTextField.text!, password: passwordTextField.text!) { (result, error) in
            if error != nil {
                return
            } else {
                print("Successfully Logged In")
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }
    }

}
