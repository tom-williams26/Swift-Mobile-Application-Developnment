//
//  ViewController.swift
//  Networking
//
//  Created by Williams T (FCES) on 06/03/2020.
//  Copyright © 2020 Thomas Williams. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    

    struct Todo: Decodable {
        let completed: Bool
        let id: Int
        let title: String
        let userId: Int
        
    }
    var todos: [Todo] = []
    @IBOutlet weak var todoTable: UITableView!
    @IBAction func retrieveData(_ sender: UIButton) {
        getData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        todoTable.delegate = self
        todoTable.dataSource = self
    }
    func getData() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos") else { return }
        var request = URLRequest( url: url)
        // Other HTTP methods are available e.g "POST", "PUT", "DELETE"
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) {(data, response, error ) in
            guard let data = data else { return }
            do {
                print("in this block")
                self.todos = try JSONDecoder().decode([Todo].self, from: data)
                DispatchQueue.main.async {
                    self.todoTable.reloadData()
                }
            }catch let jsonErr {
                print(jsonErr)
            }
        }.resume()
        // End URL Session
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        
        cell.textLabel?.text = todos[indexPath.row].title
        return cell
    }

}

