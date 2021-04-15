//
//  SavedBooksViewController.swift
//  TiktekSwift
//
//  Created by svc64 on 14/04/2021.
//

import UIKit

class SavedBooksViewController: UICollectionViewController {
    private let reuseIdentifier = "SavedBookCell"
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        40
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        return cell
    }
}
