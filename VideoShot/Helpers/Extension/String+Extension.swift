//
//  String+Extension.swift
//  FreezeFrame
//
//  Created by admin on 8/10/25.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
