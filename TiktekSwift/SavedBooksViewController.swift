//
//  SavedBooksViewController.swift
//  TiktekSwift
//
//  Created by svc64 on 14/04/2021.
//

import UIKit

class SavedBooksViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nopeLabel: UILabel!
    private let reuseIdentifier = "SavedBookCell"
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        bookshelf.savedBooks.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SavedBookCell", for: indexPath) as! SavedBookCell
        cell.imageView.image = UIImage(data: bookshelf.savedBooks[indexPath.item].image)
        cell.bookNameLabel.text = bookshelf.savedBooks[indexPath.item].name
        return cell
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if bookshelf.savedBooks.count == 0 {
            var frame = nopeLabel.frame
            frame.size.width = self.view.frame.width
            frame.size.height = self.view.frame.height
            nopeLabel.frame = frame
            nopeLabel.isHidden = false
            collectionView.isHidden = true
        }
        if bookshelf.corruptedBookList {
            // notify the user that the book list was (probably) corrupted
            let alert = UIAlertController(title: "Error", message: "The saved books list was corrupted and reset", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        var frame = nopeLabel.frame
        frame.size.width = size.width
        frame.size.height = size.height
        nopeLabel.frame = frame
    }
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
}
