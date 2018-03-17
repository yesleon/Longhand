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
    
    fileprivate func beginEditing() {
        var lastIndexPath: IndexPath = [0, paragraphs.count - 1]
        if !paragraphs[lastIndexPath.row].text.isEmpty {
            paragraphs.append(Paragraph(text: "", date: Date()))
            delegate?.viewController(self, didUpdate: paragraphs)
            lastIndexPath.row += 1
            tableView.insertRows(at: [lastIndexPath], with: .none)
        }
        tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
        let cell = tableView.cellForRow(at: lastIndexPath) as! TableViewCell
        cell.beginEditing()
    }
    
    @objc func didTapTableView(with tapGesture: UITapGestureRecognizer) {
        beginEditing()
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
        beginEditing()
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
    
    func tableViewCellDidReturn(_ cell: TableViewCell) {
        let tableView: UITableView = self.tableView
        guard let indexPath = tableView.indexPath(for: cell) else { fatalError() }
        guard !paragraphs.last!.text.isEmpty else { return }
        paragraphs.append(Paragraph(text: "", date: Date()))
        delegate?.viewController(self, didUpdate: paragraphs)
        
        var newIndexPath = indexPath
        newIndexPath.row += 1
        UIView.animate(withDuration: 0, animations: {
            tableView.insertRows(at: [newIndexPath], with: .none)
        }, completion: { _ in
            tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: false)
            let cell = tableView.cellForRow(at: newIndexPath) as! TableViewCell
            cell.beginEditing()
        })
    }
    
    func tableViewCell(_ cell: TableViewCell, didUpdate paragraph: Paragraph) {
        guard let indexPath = tableView.indexPath(for: cell) else { fatalError() }
        paragraphs[indexPath.row] = paragraph
        delegate?.viewController(self, didUpdate: paragraphs)
    }
    
}

