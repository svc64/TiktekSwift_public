//
//  AnswerCell.swift
//  TiktekSwift
//
//  Created by svc64 on 02/04/2021.
//

import UIKit
class AnswerCell: UITableViewCell {
    @IBOutlet weak var correctnessLabel: UILabel!
    @IBOutlet weak var answerTitle: UILabel!
    @IBOutlet weak var answerImageView: UIImageView!
    @IBOutlet weak var imageLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var usernameLabel: UILabel!
}
