//
//  LoginViewController.swift
//  CS4S764_15010570_RegisterInterestAppCW
//
//  Created by USWHomeUser on 06/04/2020.
//  Copyright © 2020 USWHomeUser. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var usernameInputField: UITextField!
    @IBOutlet weak var passwordInputField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
  
    }
    
    
   
    // To login to view student records - username: "admin", password: "Password".
    
    @IBAction func loginAdmin(_ sender: Any) {
        
        if ((usernameInputField.text?.contains("admin"))! && (passwordInputField.text?.contains("Password"))!) {
            
           
            
            guard let tableViewController = storyboard?.instantiateViewController(identifier: "table_vc") as? TableViewController else {
                print("Could not find TableViewController")
                return
            }
            
            navigationController?.pushViewController(tableViewController, animated: true)
            usernameInputField.text = ""
            passwordInputField.text = ""
        }
        else {
            presentAlert(withTitle: "Login", message: "Login Unsuccessful!")
        }
    }
    
 
}





