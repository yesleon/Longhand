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
        
        navigationBar.topItem?.title = title
        navigationBar.shadowImage = UIImage()
        tableView.register(TableViewCell.nib, forCellReuseIdentifier: "Cell")
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTableView)))
    }
    
    @objc func didTapTableView(with tapGesture: UITapGestureRecognizer) {
        let cell = tableView.cellForRow(at: [0, paragraphs.count - 1]) as! TableViewCell
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
    
    private func beginEditing(at indexPath: IndexPath) {
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        let cell = tableView.cellForRow(at: indexPath) as! TableViewCell
        cell.beginEditing()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        beginEditing(at: indexPath)
    }

    @IBAction func didPressAddButton(_ item: UIBarButtonItem) {
        delegate?.viewController(self, didRequest: .create)
    }
    
    @IBAction func didPressTrashButton(_ item: UIBarButtonItem) {
        delegate?.viewController(self, didRequest: .delete)
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
        delegate?.viewController(self, didUpdate: paragraphs)
    }
    
}

