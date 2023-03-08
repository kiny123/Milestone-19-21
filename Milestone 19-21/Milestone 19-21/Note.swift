//
//  Note.swift
//  Milestone 19-21
//
//  Created by nikita on 09.03.2023.
//

import UIKit

class Note: Codable {
    var text: String?
    
    init(text: String) {
        self.text = text
    }
}
