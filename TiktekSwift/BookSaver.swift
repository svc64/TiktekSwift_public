//
//  BookSaver.swift
//  TiktekSwift
//
//  Created by svc64 on 15/04/2021.
//

import UIKit
let savedBooksKey = "SavedBooks"
struct SavedBook: Codable {
    let image: Data // CONVERT TO UIIMAGE PLZ
    let name: String
    let ID: String
    let imagesDirectory: String // the directory in tiktek's servers where the solution images are saved for this book
}
class BookSaver {
    public var savedBooks: [SavedBook] = []
    public var corruptedBookList = false // was the book list corrupted?
    init() {
        let savedBooksValue = settings.data(forKey: savedBooksKey)
        if savedBooksValue != nil {
            do {
                savedBooks = try PropertyListDecoder().decode(Array<SavedBook>.self, from: savedBooksValue!)
            } catch {
                corruptedBookList = true
                // wipe it
                settings.set([], forKey: savedBooksKey)
            }
        }
    }
    func saveBook(book: Book) throws {
        let savedBook = SavedBook(image: book.image.pngData()!, name: book.name, ID: book.ID, imagesDirectory: book.imagesDirectory)
        // check for dupes
        for book in savedBooks {
            // TODO: update books when they change on the server!
            if book.ID == savedBook.ID {
                return
            }
        }
        savedBooks.append(savedBook)
        do {
            try self.sync()
        } catch Errors.bookSaveFailed {
            throw Errors.bookSaveFailed
        }
    }
    private func sync() throws {
        do {
            let encodedData = try PropertyListEncoder().encode(savedBooks)
            settings.set(encodedData, forKey: savedBooksKey)
        } catch {
            throw Errors.bookSaveFailed
        }
    }
    func removeBook(book: SavedBook) throws {
        var newBookArray: [SavedBook] = []
        for savedBook in savedBooks {
            if savedBook.ID != book.ID {
                newBookArray.append(savedBook)
            }
        }
        savedBooks = newBookArray
        do {
            try self.sync()
        } catch Errors.bookSaveFailed {
            throw Errors.bookRemoveFailed
        }
    }
}
