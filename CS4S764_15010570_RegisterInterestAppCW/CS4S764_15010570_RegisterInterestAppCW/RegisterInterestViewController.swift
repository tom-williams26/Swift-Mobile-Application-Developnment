//
//  RegisterInterestViewController.swift
//  CS4S764_15010570_RegisterInterestAppCW
//
//  Created by USWHomeUser on 09/04/2020.
//  Copyright © 2020 USWHomeUser. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import Network

class RegisterInterestViewController: UIViewController ,UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate  {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
     // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return 1
    }

    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return subjects.count
    }

    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         return subjects[row].name
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = subjects[row].name
    }
    
    @IBOutlet weak var firstNameInputField: UITextField!
    @IBOutlet weak var lastNameInputField: UITextField!
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    
    @IBOutlet weak var birthDateTextField: UITextField!
    private var datePicker: UIDatePicker?
    
    @IBOutlet weak var subjectAreaPickerView: UIPickerView!
    
    // Stores all subjects.
    var subjects = [Subject]()
    
    // Required for storing in core data.
    var selectedRow: String?
    var marketingUpdates = "No"
    
    
    var longitude: String?
    var latitude: String?
    
    var locationManager: CLLocationManager!
    var location: CLLocation! {
        didSet{
            longitude = "\(location.coordinate.longitude)"
            latitude = "\(location.coordinate.latitude)"
        }
    }
    
    let monitor = NWPathMonitor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        // Do any additional setup after loading the view.
        configureTextFields()
        configureTapGesture()
        subjectAreaHttpGETRequest()
        birthDatePicker()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkLocationServices()
        
    }
    
    // Dismiss a keyboard or picker view by tapping outside of the keyboard
    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RegisterInterestViewController.viewTapped(gestureRecognizer:)))
               
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
        
    }
    
    // Configuration
    private func configureTextFields() {
        firstNameInputField.delegate = self
        lastNameInputField.delegate = self
        emailAddressTextField.delegate = self
        birthDateTextField.delegate = self
        subjectAreaPickerView.delegate = self
        subjectAreaPickerView.dataSource = self
    }
    
    // Name validation
    func inputFullName() {
        if firstNameInputField.text!.isEmpty || lastNameInputField.text!.isEmpty {
              presentAlert(withTitle: "Empty Text Field", message: "Please enter your name")
        }
        else if !firstNameInputField.text!.nameIsValid(testStr: firstNameInputField.text!) {
            presentAlert(withTitle: "Invalid First Name", message: "Please enter a valid first name")
        }
        else  if !lastNameInputField.text!.nameIsValid(testStr: lastNameInputField.text!){
            presentAlert(withTitle: "Invalid Last Name", message: "Please enter a valid last name")
        }
    }
    // Email validation
    func inputEmail() {
        
        if emailAddressTextField.text!.isEmpty {
            presentAlert(withTitle: "Empty Text Field", message: "Please enter an email")
        }
        else if !(emailAddressTextField.text?.isEmail(emailAddressTextField.text!))! {
            presentAlert(withTitle: "Invalid Email", message: "Please enter a valid email")
        }
        else {
            return
        }
    }
    

    func birthDatePicker() {
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(RegisterInterestViewController.dateChanged(datePicker:)), for: .valueChanged)
        
        datePicker?.maximumDate = Calendar.current.date(byAdding: .year, value: -16, to: Date())
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneBtn], animated: true)
        birthDateTextField.inputAccessoryView = toolbar
        birthDateTextField.inputView = datePicker
        
    }
    // Dismiss the date picker
    @objc func donePressed() {

        self.view.endEditing(true)
    }
    
    // Set region format to "United Kingdom" in Settings to view in british format.
    @objc func dateChanged(datePicker: UIDatePicker) {
        
        let dateFormatter = DateFormatter()

        dateFormatter.dateStyle = .short
        birthDateTextField.text = dateFormatter.string(from: datePicker.date)
    }
    // Makes a GET request and retrieves the subjects from the specified URL.
    func subjectAreaHttpGETRequest() {
        guard let url = URL(string: "https://prod-42.westeurope.logic.azure.com:443/workflows/bde222cb4461471d90691324f4b6861f/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=rPL5qFWfWLPKNk3KhRuP0fsw4ooSYczKXuNfCAtDjPA") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else { return }
            
            if error == nil {
                do {
                     self.subjects = try JSONDecoder().decode([Subject].self, from:data)
                }
                catch {
                    print("Parse Error")
                }
                DispatchQueue.main.async {
                    self.subjectAreaPickerView.reloadComponent(0)
                }
            }
        }.resume()
    }
    
    
    // Saves to Core Data
    func saveToDevice() {
        let context = appDelegate.persistentContainer.viewContext
        context.perform {
            let entity = NSEntityDescription.entity(forEntityName: "Student", in: context)
            let newStudent = NSManagedObject(entity: entity!, insertInto: context)
            
            newStudent.setValue(self.firstNameInputField.text, forKey: "firstName")
            newStudent.setValue(self.lastNameInputField.text, forKey: "lastName")
            newStudent.setValue(self.emailAddressTextField.text, forKey: "emailAddress")
            newStudent.setValue(self.birthDateTextField.text, forKey: "dateOfBirth")
            newStudent.setValue(self.selectedRow, forKey: "subject")
            newStudent.setValue(self.marketingUpdates, forKey: "marketingUpdates")
            newStudent.setValue(self.longitude, forKey: "longitude")
            newStudent.setValue(self.latitude, forKey: "latitude")

            do {
                try context.save()
            }
            catch {
                print("Failed to save")
            }
        }
       
    }
    
    // Posts the student's Interest
    func studentInterestPOSTRequest() {
         guard let postURL = URL(string: "https://prod-69.westeurope.logic.azure.com:443/workflows/d2ec580e6805459893e498d43f292462/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=zn8yq-Xe3cOCDoRWTiLwDsUDXAwdGSNzxKL5OUHJPxo") else { return }
        
        let postRequest = Student(firstName: firstNameInputField.text!, lastName: lastNameInputField.text!, emailAddress: emailAddressTextField.text!, birthDate: birthDateTextField.text!, subject: selectedRow!, marketUpdates: marketingUpdates, longitude: longitude!, latitude: latitude!)
        
        var request = URLRequest(url: postURL)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        
        // Encodes the student's details.
        do {
            request.httpBody = try JSONEncoder().encode(postRequest)

        }
        catch let jsonError {
            print("Error serializing json:", jsonError.localizedDescription)
                           
        }
        
        print(request)
       
            
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                let jsonData = data else {
                    return
                }
            
                do {
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
                    print(json)
                    
                }
                catch let jsonError {
                    print("Error serializing json:", jsonError)
                    
                }
          
        }
            .resume()
    }
    
    // Handler for the marketing updates.
    @IBAction func toggleMarketingUpdates(_ sender: UISwitch) {
        
        
        if sender.isOn == true {
           marketingUpdates = "Yes"
        }
        else {
            marketingUpdates = "No"
        }

    }
    
    // Submits students data.
    @IBAction func submitInterestBtn(_ sender: Any) {
        
        inputFullName()
        inputEmail()

        if birthDateTextField.text!.isEmpty {
            presentAlert(withTitle: "Empty Text Field", message: "Please enter your date of birth")
        }
    
        locationManager.startUpdatingLocation()
        self.saveToDevice()
        
        // Handler for checking if the devices as a internet connection
//        monitor.pathUpdateHandler = { path in
//            if path.status == .satisfied {
//
//                self.studentInterestPOSTRequest()
//            }
//            else {
//                self.presentAlert(withTitle: "Internet Access", message: "Not connected. Saving to device storage...")
//
//            }
//            print(path.isExpensive)
//
//
//        }
       // Returns the current view to the previous view / landing screen.
        _ = navigationController?.popToRootViewController(animated: true)
        
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            // Set up location Manager
            checkLocationAuthorization()
        }
        else {
            presentAlert(withTitle: "Location Services", message: "Your location services are turned off, please turn on to use this app.")
        }
    }
  
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse: // Authorized when this app is in the foreground.
            locationManager.startUpdatingLocation()
            break
        case .denied: // Authorization to use location services for this app have been denied.
            break
        case .notDetermined: // The user has not set the permission.
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted: // The user is not able to set e.g., a child using a parental controlled device.
            presentAlert(withTitle: "Unauthorized Access", message: "Unauthorized to use location service.")
            break
        case .authorizedAlways: // Enabled always, even if the app is in the background.
            break
        @unknown default:
            fatalError()
        }
    }
    // Stop updating location, once the location has been stored.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         location = locations.last
         locationManager.stopUpdatingLocation()
             
     }
}

extension RegisterInterestViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIViewController {
    
    func presentAlert(withTitle title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        
        self.present(alertController, animated: true, completion: nil)
    }
}

// Name and Email Validation.
extension String {
    
    // Valid Name
    func nameIsValid(testStr:String) -> Bool {
        guard testStr.count > 2, testStr.count < 15 else { return false }

        let predicateTest = NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z]{3,}(?: [a-zA-Z]+){0,2}$")
        return predicateTest.evaluate(with: testStr)
    }

    // Validate Email

    func isEmail(_ email: String) -> Bool {
        let emailRegex = "(?:[a-zA-Z0-9!#$%\\&‘*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-" +
            "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
            "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
    
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
}
