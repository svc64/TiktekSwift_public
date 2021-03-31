//
//  SubjectsTable.swift
//  TiktekSwift
//
//  Created by svc64 on 31/03/2021.
//

import UIKit
struct Subject {
    var ID: String
    var name: String
}
class SubjectsTable: UITableViewController {
    private let subjects = [
        Subject(ID: "ST2016", name: "Maths")
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectCell") as! SubjectCell
        cell.subjectName.text = subjects[indexPath.row].name
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        subjects.count
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
        tableView.deselectRow(at: indexPath, animated: true)
        segue.destination.title = subjects[indexPath.row].name
    }
}
