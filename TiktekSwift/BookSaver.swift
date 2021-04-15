//
//  BookSaver.swift
//  TiktekSwift
//
//  Created by svc64 on 15/04/2021.
//

import UIKit
let savedBooksKey = "SavedBooks"
struct SavedBook {
    let image: UIImage
    let name: String
    let ID: String
    let imagesDirectory: String // the directory in tiktek's servers where the solution images are saved for this book
}
class BookSaver {
    public var savedBooks: [SavedBook] = []
    init() {
        let savedBooksValue = settings.array(forKey: savedBooksKey)
        if savedBooksValue != nil {
            savedBooks = savedBooksValue! as! [SavedBook]
        }
    }
    func saveBook(book: Book) {
        let savedBook = SavedBook(image: book.image, name: book.name, ID: book.ID, imagesDirectory: book.imagesDirectory)
        savedBooks.append(savedBook)
        settings.setValue(savedBooks, forKey: savedBooksKey)
    }
}
