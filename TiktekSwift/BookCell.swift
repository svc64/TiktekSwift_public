//
//  BookCell.swift
//  TiktekSwift
//
//  Created by svc64 on 31/03/2021.
//

import UIKit

class BookCell: UITableViewCell {
    @IBOutlet weak var BookCover: UIImageView!
    @IBOutlet weak var BookName: UILabel!
    @IBOutlet weak var BookInfo: UILabel!
    var bookID: String?
}
