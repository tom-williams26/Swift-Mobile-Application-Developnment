//
//  Student.swift
//  UnitTest
//
//  Created by Williams T (FCES) on 14/02/2020.
//  Copyright © 2020 Williams T (FCES). All rights reserved.
//

import Foundation

class Student {
    private let firstName: String
    private let surname: String
    
    var friends:[Student] = []
    
    init(firstName:String, lastName:String){
        self.firstName=firstName
        self.surname=lastName
    }
    
    func addFriend(friend:Student){
        friends.append(friend)
    }
    
    func validFirstName() -> Bool {
        return firstName.count > 3
    }
    
    func validLastName() -> Bool {
        return surname.count > 3
    }
}
