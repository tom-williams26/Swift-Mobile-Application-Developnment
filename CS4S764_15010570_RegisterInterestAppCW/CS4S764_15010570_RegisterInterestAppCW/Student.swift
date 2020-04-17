//
//  Student.swift
//  CS4S764_15010570_RegisterInterestAppCW
//
//  Created by USWHomeUser on 16/04/2020.
//  Copyright © 2020 USWHomeUser. All rights reserved.
//

import Foundation

struct Student: Encodable {
       let firstName: String
       let lastName: String
       let emailAddress: String
       let birthDate: String
       let subject: String
       let marketUpdates: String
       let longitude: String
       let latitude: String
   }

struct Subject: Decodable {
    let name: String
}

