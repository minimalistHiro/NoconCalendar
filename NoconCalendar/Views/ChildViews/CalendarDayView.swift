//
//  CalendarDayView.swift
//  NoconCalendar
//
//  Created by 金子広樹 on 2023/08/11.
//

import SwiftUI

struct CalendarDayView: View {
    let date: Date
    let day: Int
    let color: Color
    
    var body: some View {
        // 今日の日付の場合のみ強調する
        if checkToday(date: date) {
            Text("\(day)")
                .foregroundColor(color)
                .overlay {
                    Circle()
                        .scaledToFill()
                        .foregroundColor(.blue)
                        .opacity(0.4)
                }
        } else {
            Text("\(day)")
                .foregroundColor(color)
        }
    }
    
    /// 示すカレンダーの日付が今日か否かを判定する。
    /// - Parameters:
    ///   - date: カレンダー表示の対象日
    /// - Returns: 今日の場合True、それ以外の日の場合False。
    private func checkToday(date: Date) -> Bool {
        if Calendar.current.component(.year, from: Date()) == Calendar.current.year(for: date) ?? 0 && Calendar.current.component(.month, from: Date()) == Calendar.current.month(for: date) ?? 0 && Calendar.current.component(.day, from: Date()) == Calendar.current.day(for: date) {
            return true
        } else {
            return false
        }
    }
}

struct CalendarDayView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDayView(date: Date(), day: 1, color: .blue)
    }
}
