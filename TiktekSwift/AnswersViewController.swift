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
    var book: Book?
    var page: String?
    var question: String?
    var answers: [Answer]?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        answers!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell") as! AnswerCell
        cell.answerTitle.text = "Page \(answers![indexPath.row].page) question \(answers![indexPath.row].question)"
        cell.correctnessLabel.text = "\(answers![indexPath.row].correctness)%"
        cell.usernameLabel.text = answers![indexPath.row].creator
        // Fetch the image in background
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            let image = api.downloadImage(imageName: answers![indexPath.row].imageName, bookDir: book!.imagesDirectory, bookID: book!.ID)
            DispatchQueue.main.async {
                cell.imageLoadingIndicator.stopAnimating()
                cell.answerImageView?.image = image
                cell.answerImageView?.isHidden = false
            }
        }
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let inputSemaphore = DispatchSemaphore(value: 0) // we need to wait for the user to enter a page number and question number

        tableView.isHidden = true
        let alert = UIAlertController(title: book!.name, message: "", preferredStyle: .alert)
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
                self.navigationController?.popViewController(animated: true)
                return
            }
            print("Page number: \(pageNumberField!.text!)")
            print("Question number: \(questionNumberField!.text!)")
            self.page = pageNumberField!.text!
            self.question = questionNumberField!.text!
            inputSemaphore.signal()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
        // data magic here
        DispatchQueue.global(qos: .userInitiated).async {
            inputSemaphore.wait()
            self.answers = api.getAnswers(bookID: self.book!.ID, page: self.page!, question: self.question!)
            DispatchQueue.main.async { [self] in
                loadingIndicator.stopAnimating()
                tableView.isHidden = false
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
            }
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) {
            return true
        }
        return false
    }
}
