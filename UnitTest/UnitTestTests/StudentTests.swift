//
//  StudentTests.swift
//  UnitTest
//
//  Created by Williams T (FCES) on 14/02/2020.
//  Copyright © 2020 Williams T (FCES). All rights reserved.
//
import Foundation
import XCTest
@testable import UnitTest

class StudentTests : XCTestCase {
    func testInvalidFirstName(){
        let student = Student.init(firstName: "Si", lastName: "Payne")
        XCTAssertFalse(student.validFirstName())
    }
    
    func testValidSurname(){
        let student = Student.init(firstName: "Si", lastName: "Payne")
        XCTAssertTrue(student.validLastName())
    }
    
    func testAddFriend(){
        let student = Student.init(firstName: "Si", lastName: "Payne")
        let friend = Student.init(firstName: "Tom", lastName: "Test2")
        XCTAssertTrue(student.friends.count==0)
        student.addFriend(friend: friend)
        
        XCTAssertTrue(student.friends.count==1)
    }
}
