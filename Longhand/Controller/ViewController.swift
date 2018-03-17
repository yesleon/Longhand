//
//  ViewController.swift
//  Sheet
//
//  Created by Li-Heng Hsu on 16/03/2018.
//  Copyright © 2018 Li-Heng Hsu. All rights reserved.
//

import UIKit

enum ViewControllerOperation {
    case create, delete
}

protocol ViewControllerDelegate: AnyObject {
    func viewController(_ viewController: ViewController, didUpdate paragraphs: [Paragraph])
    func viewController(_ viewController: ViewController, didRequest operation: ViewControllerOperation)
}

class ViewController: UITableViewController {
    
    var paragraphs: [Paragraph] = []
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    weak var delegate: ViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.shadowImage = UIImage()
        tableView.register(TableViewCell.nib, forCellReuseIdentifier: "Cell")
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTableView)))
    }
    
    @objc func didTapTableView(with tapGesture: UITapGestureRecognizer) {
        let lastIndexPath: IndexPath = [0, paragraphs.count - 1]
        tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
        let cell = tableView.cellForRow(at: lastIndexPath) as! TableViewCell
        cell.beginEditing()
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TableViewCell
        cell.beginEditing()
    }

    @IBAction func didPressMoreButtonItem(_ item: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "New Sheet", style: .default, handler: { _ in
            self.delegate?.viewController(self, didRequest: .create)
        }))
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.delegate?.viewController(self, didRequest: .delete)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
}

extension ViewController: TableViewCellDelegate {
    
    func tableViewCell(_ cell: TableViewCell, didEndEditing paragraph: Paragraph, withReturnPressed: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        paragraphs[indexPath.row] = paragraph
        tableView.reloadRows(at: [indexPath], with: .none)
        
        if !paragraph.text.isEmpty {
            paragraphs.append(Paragraph(text: "", date: Date()))
            
            var newIndexPath = indexPath
            newIndexPath.row += 1
            tableView.insertRows(at: [newIndexPath], with: .top)
            if withReturnPressed {
                tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: false)
                let cell = tableView.cellForRow(at: newIndexPath) as! TableViewCell
                cell.beginEditing()
            }
            
        }
        delegate?.viewController(self, didUpdate: paragraphs)
    }
    
}

