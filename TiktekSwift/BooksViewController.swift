//
//  BooksViewController.swift
//  TiktekSwift
//
//  Created by svc64 on 31/03/2021.
//

import UIKit

class BooksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
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
            print("fetching shit for subject id \(String(describing: self.subjectID))")
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
        /*
         let alert = UIAlertController(title: (sender as! BookCell).BookName.text, message: "", preferredStyle: .alert)
         alert.addTextField() { (pageNumberField) in
             pageNumberField.placeholder = "Page number"
             pageNumberField.keyboardType = .numberPad
             pageNumberField.delegate = self
         }
         alert.addTextField { (questionNumberField) in
             questionNumberField.placeholder = "Question number"
             questionNumberField.keyboardType = .numberPad
             questionNumberField.delegate = self
         }
         alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
             let pageNumberField = alert?.textFields![0]
             let questionNumberField = alert?.textFields![1]
             if pageNumberField?.text == nil {
                 self.shouldOpenAnswers = false
                 return
             }
             print("Page number: \(pageNumberField!.text!)")
             print("Question number: \(questionNumberField!.text!)")
             self.shouldOpenAnswers = true
         }))
         alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
             self.shouldOpenAnswers = false
         }))
         self.present(alert, animated: true, completion: nil)
         */
    }
    /*
     override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
         //self.shouldOpenAnswers
     }
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) {
            return true
        }
        return false
    }
}
