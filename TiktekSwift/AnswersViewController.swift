//
//  AnswersViewController.swift
//  TiktekSwift
//
//  Created by svc64 on 01/04/2021.
//

import UIKit
import QuickLook
class AnswersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    struct CellData {
        var imageName: String
        var answerTitle: String
        var correctnessLabel: String
        var usernameLabel: String
        var image: UIImage?
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
        cell.index = indexPath.row
        if cells![indexPath.row].image == nil {
            cell.answerImageView?.image = UIImage(systemName: "xmark.octagon.fill")
            cell.answerImageView.contentMode = .center
            cell.answerImageView?.isHidden = false
        } else {
            cell.answerImageView?.image = cells![indexPath.row].image
            cell.answerImageView?.isHidden = false
        }
        // set up QuickLook
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        cell.addGestureRecognizer(tapGesture)
        return cell
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        print("quicklooking...")
        let quickLookViewController = QLPreviewController()
        quickLookViewController.dataSource = self
        quickLookViewController.currentPreviewItemIndex = (sender!.view as! AnswerCell).index!
        present(quickLookViewController, animated: true)

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
                usernameLabel: answer.creator,
                image: nil))
            }
            
            // load images
            for i in 0...self.cells!.count-1 {
                self.cells![i].image = api.downloadImage(imageName: self.cells![i].imageName, bookDir: self.book!.imagesDirectory, bookID: self.book!.ID)
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
extension AnswersViewController: QLPreviewControllerDataSource {
  func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
    self.cells!.count
  }

  func previewController(
    _ controller: QLPreviewController,
    previewItemAt index: Int
  ) -> QLPreviewItem {
    let tempImage = NSURL(fileURLWithPath: "\(NSTemporaryDirectory())/\(self.cells![index].imageName)")
    do {
        try self.cells![index].image?.pngData()?.write(to: tempImage as URL)
    } catch {
        print("quicklook failed!")
        abort()
    }
    return tempImage as QLPreviewItem
  }
}
