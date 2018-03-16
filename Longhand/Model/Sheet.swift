//
//  Sheet.swift
//  Sheet
//
//  Created by Li-Heng Hsu on 16/03/2018.
//  Copyright © 2018 Li-Heng Hsu. All rights reserved.
//

import Foundation

struct Sheet: Codable {
    var title: String
    var paragraphs: [Paragraph]
}
