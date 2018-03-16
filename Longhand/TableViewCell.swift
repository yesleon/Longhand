//
//  TableViewCell.swift
//  Sheet
//
//  Created by Li-Heng Hsu on 16/03/2018.
//  Copyright © 2018 Li-Heng Hsu. All rights reserved.
//

import UIKit

protocol TableViewCellDelegate: AnyObject {
    func tableViewCell(_ cell: TableViewCell, didEndEditing paragraph: Paragraph, withReturnPressed: Bool)
}

class TableViewCell: UITableViewCell {

    static let nib = UINib(nibName: String(describing: TableViewCell.self), bundle: nil)
    
    @IBOutlet private weak var textView: UITextView!
    weak var delegate: TableViewCellDelegate?
    private var withReturnPressed = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.delegate = self
        textView.isSelectable = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textView.text = nil
    }
    
    func setParagraph(_ paragraph: Paragraph) {
        textView.text = paragraph.text
        textView.isEditable = textView.text.isEmpty
    }
    
    func beginEditing() {
        textView.becomeFirstResponder()
    }
    
}

extension TableViewCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            withReturnPressed = true
            textView.endEditing(false)
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.caretRect(for: textView.endOfDocument).origin.y < 0 {
            textView.removeConstraints(textView.constraints)
            textView.translatesAutoresizingMaskIntoConstraints = true
            textView.sizeToFit()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.isSelectable = false
        textView.isEditable = textView.text.isEmpty
        let paragraph = Paragraph(text: textView.text, date: Date())
        delegate?.tableViewCell(self, didEndEditing: paragraph, withReturnPressed: withReturnPressed)
        withReturnPressed = false
    }
    
}
