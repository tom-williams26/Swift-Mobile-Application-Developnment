//
//  ViewController.swift
//  CS4S763_15010570
//
//  Created by Williams T (FCES) on 13/03/2020.
//  Copyright © 2020 Williams T (FCES). All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var inputName: UITextField!
    @IBOutlet weak var inputEmail: UITextField!
    
    @IBOutlet weak var selectBirthDate: UIDatePicker!
    @IBOutlet weak var selectSubjectArea: UIPickerView!
    
    @IBOutlet weak var optMarketingUpdates: UISwitch!
    
    @IBOutlet weak var btnSubmitInterest: UIButton!
    @IBOutlet weak var btnClearFields: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

