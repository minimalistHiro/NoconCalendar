//
//  ScheduleRectangleView.swift
//  NoconCalendar
//
//  Created by 金子広樹 on 2023/08/08.
//

import SwiftUI

struct ScheduleRectangleView: View {
    let setting = Setting()
    
    let title: String
    let frameHeight: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .overlay(alignment: .leading) {
                Text(prefixText(title))
                    .foregroundColor(.white)
                    .font(.system(size: frameHeight / 52))
                    .bold()
            }
    }
    
    /// テキストを、カレンダーに表示する用に簡略化したテキストに変換する。
    /// - Parameters:
    ///   - text: メモテキスト
    /// - Returns: カレンダーに表示する用に簡略化したテキスト
    private func prefixText(_ text: String) -> String {
        let charCount = text.count
        let halfSizeCharCount = text.halfSizeCharsCount()
        let count = charCount - halfSizeCharCount / 2
        
        if count > setting.maxCalendarTextCount {
            let prefixText = text.prefix(setting.maxCalendarTextCount)
            return String(prefixText)
        }
        return text
    }
}

struct ScheduleRectangleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleRectangleView(title: "タイトル", frameHeight: 52)
    }
}
