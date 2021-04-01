//
//  BooksViewController.swift
//  TiktekSwift
//
//  Created by svc64 on 31/03/2021.
//

import UIKit

class BooksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var subjectID: String?
    var books: [Book]?
    var shouldOpenAnswers = true
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        books!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell") as! BookCell
        cell.BookName.text = self.books![indexPath.row].name
        cell.BookInfo.text = self.books![indexPath.row].info
        cell.BookCover.image = self.books![indexPath.row].image
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        view.addSubview(loadingIndicator)
        DispatchQueue.global(qos: .userInitiated).async {
            if api == nil {
                api = TiktekAPI()
            }
            print("fetching shit for subject id \(String(describing: self.subjectID))")
            self.books = api?.getBooks(subjectID: self.subjectID!)
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
