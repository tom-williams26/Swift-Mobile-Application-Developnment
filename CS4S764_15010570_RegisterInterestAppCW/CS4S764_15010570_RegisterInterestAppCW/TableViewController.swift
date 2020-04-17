//
//  TableViewController.swift
//  CS4S764_15010570_RegisterInterestAppCW
//
//  Created by USWHomeUser on 09/04/2020.
//  Copyright © 2020 USWHomeUser. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TableViewController: UITableViewController {

    var details: [NSManagedObject] = []
    let cellIdentifier = "StudentCell"
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Student")
        do {
            details = try managedContext.fetch(fetchRequest)
        }
        catch let error as NSError {
            print("Failed to fetch student records", error)
        }
    }
    
    @IBAction func syncStudentRecords(_ sender: UIBarButtonItem) {
        
        studentInterestPOSTRequest()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! StudentCell
        let item = details[indexPath.row]
        
        cell.firstNameLabel?.text = item.value(forKeyPath: "firstName") as? String
        cell.lastNameLabel?.text = item.value(forKeyPath: "lastName") as? String
        cell.emailAddressLabel?.text = item.value(forKeyPath: "emailAddress") as? String
        cell.birthDateLabel?.text = item.value(forKeyPath: "dateOfBirth") as? String
        cell.subjectLabel?.text = item.value(forKeyPath: "subject") as? String
        cell.marketingUpdatesLabel?.text = item.value(forKeyPath: "marketingUpdates") as? String
        cell.longitudeLabel?.text = item.value(forKeyPath: "longitude") as? String
        cell.latitudeLabel?.text = item.value(forKeyPath: "latitude") as? String

        
        return cell
    }
    
    func studentInterestPOSTRequest() {
         guard let postURL = URL(string: "https://prod-69.westeurope.logic.azure.com:443/workflows/d2ec580e6805459893e498d43f292462/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=zn8yq-Xe3cOCDoRWTiLwDsUDXAwdGSNzxKL5OUHJPxo") else { return }
        
        let postRequest = details.count
        
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
    

}
