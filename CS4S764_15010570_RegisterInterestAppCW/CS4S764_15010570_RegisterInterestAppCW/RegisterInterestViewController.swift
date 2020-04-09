//
//  RegisterInterestViewController.swift
//  CS4S764_15010570_RegisterInterestAppCW
//
//  Created by USWHomeUser on 09/04/2020.
//  Copyright © 2020 USWHomeUser. All rights reserved.
//

import UIKit
import CoreData

class RegisterInterestViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstNameInputField: UITextField!
    @IBOutlet weak var lastNameInputField: UITextField!
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    
    @IBOutlet weak var birthDateTextField: UITextField!
    private var datePicker: UIDatePicker?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        birthDatePicker()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RegisterInterestViewController.viewTapped(gestureRecognizer:)))
        
        view.addGestureRecognizer(tapGesture)
    }
    
    func inputFullName() {
        if firstNameInputField.text?.isBlank 
    }
    
    func inputEmail() {
        let inputEmailAddress = UIAlertController(title: "Invalid input", message: "Please enter a valid email address", preferredStyle: .alert)
        inputEmailAddress.addAction(UIAlertAction(title: "Dismiss", style: .default))
        
        if emailAddressTextField.text!.isBlank {
            self.present(inputEmailAddress, animated: true, completion: nil)
        }
        else if emailAddressTextField.text!.isEmail {
            self.present(inputEmailAddress, animated: true, completion: nil)
        }
    }  
    
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
        
    }
    func birthDatePicker() {
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(RegisterInterestViewController.dateChanged(datePicker:)), for: .valueChanged)
        
        datePicker?.maximumDate = Calendar.current.date(byAdding: .year, value: -16, to: Date())
        
        birthDateTextField.inputView = datePicker
        
    }
    
    // Set region format to "United Kingdom" in Settings to view in british format.
    @objc func dateChanged(datePicker: UIDatePicker) {
        
        let dateFormatter = DateFormatter()

        dateFormatter.dateStyle = .short
        birthDateTextField.text = dateFormatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    

    
    @IBAction func submitInterestBtn(_ sender: Any) {
        
        inputEmail()
    }
    
}


extension String {

// To check text field or String is blank or not
var isBlank: Bool {
    get {
        let trimmed = trimmingCharacters(in: CharacterSet.whitespaces)
        return trimmed.isEmpty
    }
}
    
// Valid Name
    func nameIsValid(testStr:String) -> Bool {
        guard testStr.count > 7, testStr.count < 18 else { return false }

        let predicateTest = NSPredicate(format: "SELF MATCHES %@", "^(([^ ]?)(^[a-zA-Z].*[a-zA-Z]$)([^ ]?))$")
        return predicateTest.evaluate(with: testStr)
    }

// Validate Email

var isEmail: Bool {
    do {
        let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        
    } catch {
        return false
        
    }
    
    }
    
}
