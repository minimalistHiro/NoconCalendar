//
//  ContentView.swift
//  NoconCalendar
//
//  Created by 金子広樹 on 2023/08/07.
//

import SwiftUI

struct CalendarDates: Identifiable {
    var id = UUID()
    var date: Date?
}

struct ContentView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Entity.startDate, ascending: true)])
    var data: FetchedResults<Entity>
    
    let setting = Setting()
    @ObservedObject var viewModel = ContentViewModel.shared
    @State private var indicateDate = Date()
    
    var year: Int {
        Calendar.current.year(for: indicateDate) ?? 0
    }           // 年
    var month: Int {
        Calendar.current.month(for: indicateDate) ?? 0
    }           // 月
    var calendarDates: [CalendarDates] {
        createCalendarDates(indicateDate)
    }           // 日付配列
    let weekdays = Calendar.current.shortWeekdaySymbols         // 曜日
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 5), count: 7) // グリッドアイテム
    
    @GestureState private var dragOffset: CGFloat = 0           // ドラッグの度量
    @State private var calendarCenter: CGPoint = CGPoint.zero   // カレンダーの中心座標
    @State private var isShowSheet: Bool = false                // シートの表示有無
    @State private var isShowScheduleSheet: Bool = false        // スケジュールシートの表示有無
    @State private var correctedDate: Date = Date()             // タップ時にスケジュールシートを表示するためのDate
    
    var body: some View {
        VStack {
            Text(String(format: "%04d / %2d", year, month))
                .font(.system(size: 24))
            
            // 曜日
            HStack(spacing: 5) {
                ForEach(weekdays, id: \.self) { weekday in
                    if weekday == "日" {
                        Text(weekday)
                            .frame(height: 40, alignment: .center)
                            .frame(maxWidth: UIScreen.main.bounds.width)
                            .foregroundColor(.red)
                    } else if weekday == "土" {
                        Text(weekday)
                            .frame(height: 40, alignment: .center)
                            .frame(maxWidth: UIScreen.main.bounds.width)
                            .foregroundColor(.blue)
                    } else {
                        Text(weekday)
                            .frame(height: 40, alignment: .center)
                            .frame(maxWidth: UIScreen.main.bounds.width)
                    }
                }
            }
            .padding()
            
            // カレンダー
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ForEach(createThreeMonthDate(month), id: \.self) { date in
                        LazyVGrid(columns: columns, spacing: 0) {
                            ForEach(createCalendarDates(date)) { calendarDates in
                                VStack(spacing: 7) {
                                    if let date = calendarDates.date,
                                       let day = Calendar.current.day(for: date) {
                                        // 日曜日は赤、土曜日は青、それ以外は黒に分ける。
                                        if checkHoliday(date) {
                                            CalendarDayView(date: date, day: day, color: .red)
                                        } else if checkSunday(calendars: createCalendarDates(date), day: day) {
                                            CalendarDayView(date: date, day: day, color: .red)
                                        } else if checkSaturday(calendars: createCalendarDates(date), day: day) {
                                            CalendarDayView(date: date, day: day, color: .blue)
                                        } else {
                                            CalendarDayView(date: date, day: day, color: setting.black)
                                        }
                                    } else {
                                        Text("")
                                    }
                                    ZStack {
                                        Spacer()
                                            .frame(height: createCalendarDates(date).count > 35 ? (geometry.size.height / 6) - 20 : (geometry.size.height / 5) - 20)
                                        if let date = calendarDates.date {
                                            VStack(spacing: 2) {
                                                ScheduleDataView(date: date, frameHeight: geometry.size.height)
                                                Spacer()
                                            }
                                        }
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if let date = calendarDates.date {
                                        correctedDate = date
                                        isShowScheduleSheet = true
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .offset(x: self.dragOffset)
                .offset(x: -1 * geometry.size.width)
                .gesture(
                    DragGesture()
                        .updating(self.$dragOffset, body: { (value, state, _) in
                            // 移動幅（width）のみ更新する
                            state = value.translation.width
                        })
                        .onEnded({ value in
                            let calendar = Calendar(identifier: .gregorian)
                            
                            var newDate = self.indicateDate
                            
                            // ドラッグ幅からページングを判定
                            if abs(value.translation.width) > geometry.size.width * 0.4 {
                                newDate = (value.translation.width > 0 ? calendar.date(from: DateComponents(year: year, month: month - 1)) : calendar.date(from: DateComponents(year: year, month: month + 1))) ?? Date()
                            }
                            
                            // 最小ページ、最大ページを超えないようチェック
                            //                        if newDate < 0 {
                            //                            newDate = 0
                            //                        } else if newDate > (self.examples.count - 1) {
                            //                            newDate = self.examples.count - 1
                            //                        }
                            
                            self.indicateDate = newDate
                        })
                )
            }
        }
        .overlay {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        isShowSheet = true
                    } label: {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60)
                            .foregroundColor(setting.black)
                            .overlay {
                                Image(systemName: "plus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25)
                                    .bold()
                                    .foregroundColor(setting.white)
                            }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $isShowSheet) {
            SheetView(isShowSheet: $isShowSheet)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $isShowScheduleSheet) {
            ScheduleSheetView(date: $correctedDate)
                .presentationDetents([.fraction(0.35), .large])
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
    
    /// 示すカレンダーの日付が祝日か否かを判定する。
    /// - Parameters:
    ///   - date: 対象日
    /// - Returns: 祝日の場合True、それ以外の場合False。
    private func checkHoliday(_ date: Date) -> Bool {
        let horiday = viewModel.convertHolidayToDate(viewModel.horiday)
        if horiday.contains(date) {
            return true
        }
        return false
    }
    
    
    /// 示すカレンダーの日付が日曜日か否かを判定する。
    /// - Parameters:
    ///   - calendars: その月のカレンダー
    ///   - day: カレンダー表示の対象日
    /// - Returns: 日曜日の場合True、それ以外の場合False。
    private func checkSunday(calendars: [CalendarDates], day: Int) -> Bool {
        var count: Int = 0
        for calendar in calendars {
            count += 1
            if let date = calendar.date {
                if count % 7 == 1 && Calendar.current.component(.day, from: date) == day {
                    return true
                }
            }
        }
        return false
    }
    
    /// 示すカレンダーの日付が土曜日か否かを判定する。
    /// - Parameters:
    ///   - calendars: その月のカレンダー
    ///   - day: カレンダー表示の対象日
    /// - Returns: 土曜日の場合True、それ以外の場合False。
    private func checkSaturday(calendars: [CalendarDates], day: Int) -> Bool {
        var count: Int = 0
        for calendar in calendars {
            count += 1
            if let date = calendar.date {
                if count % 7 == 0 && Calendar.current.component(.day, from: date) == day {
                    return true
                }
            }
        }
        return false
    }
    
    /// 先月、今月（表示月）、来月の3ヶ月分のDateを取得。
    /// - Parameters: なし
    /// - Returns: 3ヶ月分の日付配列
    private func createThreeMonthDate(_ month: Int) -> [Date] {
        let calendar = Calendar(identifier: .gregorian)
        
        let oneMonthAgo = calendar.date(from: DateComponents(year: year, month: month - 1))
        let thisMonth = calendar.date(from: DateComponents(year: year, month: month))
        let oneMonthLater = calendar.date(from: DateComponents(year: year, month: month + 1))
        
        guard let oneMonthAgoDate = oneMonthAgo,
              let thisMonthDate = thisMonth,
              let oneMonthLaterDate = oneMonthLater else { return [] }
        
        return [oneMonthAgoDate, thisMonthDate, oneMonthLaterDate]
    }
}

/// カレンダー表示用の日付配列を取得
/// - Parameters:
///   - date: カレンダー表示の対象日
/// - Returns: 日付配列
func createCalendarDates(_ date: Date) -> [CalendarDates] {
    var days = [CalendarDates]()
    
    // 今月の開始日
    let startOfMonth = Calendar.current.startOfMonth(for: date)
    // 今月の日数
    let daysInMonth = Calendar.current.daysInMonth(for: date)
    
    guard let daysInMonth = daysInMonth, let startOfMonth = startOfMonth else { return [] }
    
    // 今月の全ての日付
    for day in 0..<daysInMonth {
        // 今月の開始日から1日ずつ加算
        days.append(CalendarDates(date: Calendar.current.date(byAdding: .day, value: day, to: startOfMonth)))
    }
    
    guard let firstDay = days.first, let lastDay = days.last,
          let firstDate = firstDay.date, let lastDate = lastDay.date,
          let firstDateWeekday = Calendar.current.weekday(for: firstDate),
          let lastDateWeekday = Calendar.current.weekday(for: lastDate) else { return [] }
    
    // 初週のオフセット日数
    let firstWeekEmptyDays = firstDateWeekday - 1
    // 最終週のオフセット日数
    let lastWeekEmptyDays = 7 - lastDateWeekday
    
    // 初週のオフセットを追加
    for _ in 0..<firstWeekEmptyDays {
        days.insert(CalendarDates(date: nil), at: 0)
    }
    
    // 最終週のオフセットを追加
    for _ in 0..<lastWeekEmptyDays {
        days.append(CalendarDates(date: nil))
    }
    
    return days
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
