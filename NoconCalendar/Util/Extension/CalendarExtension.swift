//
//  CalendarExtension.swift
//  NoconCalendar
//
//  Created by 金子広樹 on 2023/08/07.
//

import Foundation

extension Calendar {
    /// 今月の開始日を取得する
    /// - Parameters:
    ///   - date: 対象日
    /// - Returns: 開始日
    func startOfMonth(for date: Date) -> Date? {
        let comps = dateComponents([.month, .year], from: date)
        return self.date(from: comps)
    }
    
    /// 今月の日数を取得する
    /// - Parameters:
    ///   - date: 対象日
    /// - Returns: 日数
    func daysInMonth(for date: Date) -> Int? {
        return range(of: .day, in: .month, for: date)?.count
    }
    
    /// 今月の週数を取得する
    /// - Parameters:
    ///   - date: 対象日
    /// - Returns: 週数
    func weeksInMonth(for date: Date) -> Int? {
        return range(of: .weekOfMonth, in: .month, for: date)?.count
    }
    
    func year(for date: Date) -> Int? {
        let comps = dateComponents([.year], from: date)
        return comps.year
    }
    
    func month(for date: Date) -> Int? {
        let comps = dateComponents([.month], from: date)
        return comps.month
    }
    
    func day(for date: Date) -> Int? {
        let comps = dateComponents([.day], from: date)
        return comps.day
    }
    
    func weekday(for date: Date) -> Int? {
        let comps = dateComponents([.weekday], from: date)
        return comps.weekday
    }
}
