//
//  Globals.swift
//  TiktekSwift
//
//  Created by svc64 on 01/04/2021.
//

import Foundation

var api = TiktekAPI()
let settings = UserDefaults.standard
let bookshelf = BookSaver()
enum Errors: Error {
    case bookSaveFailed
    case bookRemoveFailed
}
