//
//  BooksViewController.swift
//  TiktekSwift
//
//  Created by svc64 on 31/03/2021.
//

import UIKit

class BooksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if books == nil {
            return
        }
        guard let text = searchController.searchBar.text else { return }
        if text == "" {
            displayedBooks = books
            tableView.reloadData()
        } else {
            var newBookList: [Book] = []
            for book in books! {
                if book.name.contains(text) {
                    newBookList.append(book)
                }
            }
            displayedBooks = newBookList
            tableView.reloadData()
        }
    }
    
    var subjectID: String?
    var books: [Book]?
    var displayedBooks: [Book]?
    var shouldOpenAnswers = true
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedBooks!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell") as! BookCell
        cell.BookName.text = self.displayedBooks![indexPath.row].name
        cell.BookInfo.text = self.displayedBooks![indexPath.row].info
        cell.BookCover.image = self.displayedBooks![indexPath.row].image
        cell.bookID = self.displayedBooks![indexPath.row].ID
        cell.bookStruct = self.displayedBooks![indexPath.row]
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        view.addSubview(loadingIndicator)
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search for books"
        navigationItem.searchController = search
        DispatchQueue.global(qos: .userInitiated).async {
            print("fetching shit for subject id \(self.subjectID!)")
            self.books = api.getBooks(subjectID: self.subjectID!)
            self.displayedBooks = self.books
            DispatchQueue.main.async { [self] in
                loadingIndicator.stopAnimating()
                tableView.isHidden = false
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! AnswersViewController
        let clickedCell = sender as! BookCell
        dest.book = clickedCell.bookStruct
    }
}
