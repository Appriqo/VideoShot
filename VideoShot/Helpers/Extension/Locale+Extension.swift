//
//  Locale+Extension.swift
//  FreezeFrame
//
//  Created by admin on 13/10/25.
//

import Foundation

extension Locale {
    static var currentLanguageCode: String {
        if #available(macOS 13, *) {
            return Locale.current.language.languageCode?.identifier ?? "en"
        } else {
            return Locale.current.languageCode ?? "en"
        }
    }

    static var isEn: Bool {
        print(currentLanguageCode)
        return currentLanguageCode == "en"
    }

    static var isAr: Bool {
        currentLanguageCode == "ar"
    }
    
    static var isJP: Bool {
        currentLanguageCode == "ja"
    }

    static var isKO: Bool {
        currentLanguageCode == "ko"
    }
    
    static var isRU: Bool {
        currentLanguageCode == "ru"
    }
    
    static var isFR: Bool {
        currentLanguageCode == "fr"
    }
}
