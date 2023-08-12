//
//  StringExtension.swift
//  NoconCalendar
//
//  Created by 金子広樹 on 2023/08/10.
//

import Foundation

extension String {
    // 半角文字が存在する場合、その文字数を返す
    func halfSizeCharsCount() -> Int {
        let pattern = "[ -~]"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let results = regex.matches(in: self, options: [], range: NSRange(0..<self.count))
        return results.count
    }
}

