//
//  BooksViewController.swift
//  TiktekSwift
//
//  Created by svc64 on 31/03/2021.
//

import UIKit

class BooksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var subjectID: String?
    var books: [Book]?
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
}
