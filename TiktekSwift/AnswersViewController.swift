//
//  AnswersViewController.swift
//  TiktekSwift
//
//  Created by svc64 on 01/04/2021.
//

import UIKit
class AnswersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    var bookID: String?
    var bookName: String?
    var page: String?
    var question: String?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell")!
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        let alert = UIAlertController(title: bookName, message: "", preferredStyle: .alert)
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
                self.dismiss(animated: true, completion: nil)
                return
            }
            print("Page number: \(pageNumberField!.text!)")
            print("Question number: \(questionNumberField!.text!)")
            self.page = pageNumberField!.text!
            self.question = questionNumberField!.text!
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
        
        // data magic here
        DispatchQueue.global(qos: .userInitiated).async {
            
            DispatchQueue.main.async { [self] in
                
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) {
            return true
        }
        return false
    }
}
