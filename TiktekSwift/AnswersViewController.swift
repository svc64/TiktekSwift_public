//
//  AnswersViewController.swift
//  TiktekSwift
//
//  Created by svc64 on 01/04/2021.
//

import UIKit
class AnswersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    struct CellData {
        var imageName: String
        var answerTitle: String
        var correctnessLabel: String
        var usernameLabel: String
        var image: UIImage?
        var isWorking: Bool = false // is more data being currently fed into here? should we change anything in this struct right now?
    }
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    var book: Book?
    var page: String?
    var question: String?
    var answers: [Answer]?
    var cells: [CellData]? = []
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        answers!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell") as! AnswerCell
        cell.answerTitle.text = cells![indexPath.row].answerTitle
        cell.correctnessLabel.text = cells![indexPath.row].correctnessLabel
        cell.usernameLabel.text = cells![indexPath.row].usernameLabel
        // Fetch the image in background
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            if cells![indexPath.row].image == nil && !cells![indexPath.row].isWorking {
                cells![indexPath.row].isWorking = true
                var attempts = 0
                while attempts < 5 {
                    cells![indexPath.row].image = api.downloadImage(imageName: cells![indexPath.row].imageName, bookDir: book!.imagesDirectory, bookID: book!.ID)
                    if cells![indexPath.row].image != nil {
                        DispatchQueue.main.async {
                            cell.imageLoadingIndicator.stopAnimating()
                            cell.answerImageView?.image = cells![indexPath.row].image
                            cell.answerImageView?.isHidden = false
                        }
                        return
                    }
                    attempts += 1
                }
                // image download failed, display a failure icon
                DispatchQueue.main.async {
                    cell.imageLoadingIndicator.stopAnimating()
                    cell.answerImageView?.image = UIImage(systemName: "xmark.octagon.fill")
                    cell.answerImageView?.isHidden = false
                }
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
            
            // load the data we already have into the cell struct
            for answer in self.answers! {
                self.cells!.append(CellData(
                imageName: answer.imageName,
                answerTitle: "Page \(answer.page) question \(answer.question)",
                correctnessLabel: "\(answer.correctness)%",
                usernameLabel: answer.creator, image: nil))
            }
            
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
