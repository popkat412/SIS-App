//
//  String+Regex.swift
//  SIS App
//
//  Created by Wang Yunze on 10/12/20.
//

import Foundation

extension String {
    func matches(regex: String) -> Bool {
        let range = NSRange(location: 0, length: utf16.count)
        let pattern = try! NSRegularExpression(pattern: regex)
        return pattern.firstMatch(in: self, options: [], range: range) != nil
    }
}
