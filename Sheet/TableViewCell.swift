//
//  TableViewCell.swift
//  Sheet
//
//  Created by Li-Heng Hsu on 16/03/2018.
//  Copyright © 2018 Li-Heng Hsu. All rights reserved.
//

import UIKit

protocol TableViewCellDelegate: AnyObject {
    func tableViewCell(_ cell: TableViewCell, didEndEditing paragraph: Paragraph)
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
    }
    
    func setParagraph(_ paragraph: Paragraph) {
        textView.text = paragraph.text
    }
    
}

extension TableViewCell: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let paragraph = Paragraph(text: textView.text, date: Date())
        delegate?.tableViewCell(self, didEndEditing: paragraph)
    }
    
}
