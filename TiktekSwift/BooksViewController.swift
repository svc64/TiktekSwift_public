//
//  BooksViewController.swift
//  TiktekSwift
//
//  Created by svc64 on 31/03/2021.
//

import UIKit

class BooksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell") as! BookCell
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            sleep(5)
            DispatchQueue.main.async { [self] in
                loadingIndicator.stopAnimating()
                tableView.isHidden = false
                tableView.delegate = self
                tableView.dataSource = self
            }
        }
    }
}