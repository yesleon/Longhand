//
//  ViewController.swift
//  Sheet
//
//  Created by Li-Heng Hsu on 16/03/2018.
//  Copyright © 2018 Li-Heng Hsu. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var paragraphs: [Paragraph] = [Paragraph(text: "", date: Date())]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(TableViewCell.nib, forCellReuseIdentifier: "Cell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paragraphs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        cell.delegate = self
        cell.setParagraph(paragraphs[indexPath.row])
        return cell
    }
    
    private func beginEditing(at indexPath: IndexPath) {
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        let cell = tableView.cellForRow(at: indexPath) as! TableViewCell
        cell.beginEditing()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        beginEditing(at: indexPath)
    }

}

extension ViewController: TableViewCellDelegate {
    
    func tableViewCell(_ cell: TableViewCell, didEndEditing paragraph: Paragraph) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        paragraphs[indexPath.row] = paragraph
        
        if !paragraph.text.isEmpty {
            paragraphs.append(Paragraph(text: "", date: Date()))
            var newIndexPath = indexPath
            newIndexPath.row += 1
            tableView.insertRows(at: [newIndexPath], with: .none)
            beginEditing(at: newIndexPath)
        }
    }
    
}

