//
//  TableViewCell.swift
//  Sheet
//
//  Created by Li-Heng Hsu on 16/03/2018.
//  Copyright © 2018 Li-Heng Hsu. All rights reserved.
//

import UIKit

protocol TableViewCellDelegate: AnyObject {
    func tableViewCellDidReturn(_ cell: TableViewCell)
    func tableViewCell(_ cell: TableViewCell, didUpdate paragraph: Paragraph)
}

class TableViewCell: UITableViewCell {

    static let nib = UINib(nibName: String(describing: TableViewCell.self), bundle: nil)
    
    @IBOutlet private weak var textView: UITextView!
    weak var delegate: TableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.delegate = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textView.text = nil
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
    }
    
    func setParagraph(_ paragraph: Paragraph) {
        textView.text = paragraph.text
        if paragraph.text.isEmpty {
            textView.isEditable = true
        }
    }
    
    func beginEditing() {
        textView.becomeFirstResponder()
    }
    
}

extension TableViewCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            delegate?.tableViewCellDidReturn(self)
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.caretRect(for: textView.endOfDocument).origin.y < 0 {
            textView.translatesAutoresizingMaskIntoConstraints = true
            let width = textView.frame.width
            textView.sizeToFit()
            textView.frame.size.width = width
        }
        delegate?.tableViewCell(self, didUpdate: Paragraph(text: textView.text, date: Date()))
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.isEditable = textView.text.isEmpty
        textView.isSelectable = textView.isEditable
    }
    
}
