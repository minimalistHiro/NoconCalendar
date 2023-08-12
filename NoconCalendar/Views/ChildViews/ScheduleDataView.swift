//
//  ScheduleDataView.swift
//  NoconCalendar
//
//  Created by 金子広樹 on 2023/08/09.
//

import SwiftUI

struct ScheduleDataView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Entity.startDate, ascending: true)])
    var data: FetchedResults<Entity>
    
    @ObservedObject var viewModel = ContentViewModel.shared
    let date: Date
    let frameHeight: CGFloat
    
    var body: some View {
        ForEach(data) { data in
            if let dataDate = data.startDate {
                // 同年、同月、同日の場合、予定を表示。
                if checkSameDate(dataDate: dataDate, date: date) {
                    ScheduleRectangleView(title: data.title ?? "タイトル", frameHeight: frameHeight)
                        .frame(height: createCalendarDates(date).count > 35 ? (((frameHeight / 6) - 20) / 4) - 4 : (((frameHeight / 5) - 20) / 4) - 4)
                        .foregroundColor(viewModel.convertStringToColorPicker(data.color ?? "blue"))
                }
            }
        }
    }
    
    /// 同一年月日か否かを判定
    /// - Parameters:
    ///   - dataDate: 調べる日付
    ///   - date: 対象の日付
    /// - Returns: 同一年月日の場合True、それ以外false。
    private func checkSameDate(dataDate: Date, date: Date) -> Bool {
        if Calendar.current.component(.year, from: dataDate) == Calendar.current.component(.year, from: date) && Calendar.current.component(.month, from: dataDate) == Calendar.current.component(.month, from: date) && Calendar.current.component(.day, from: dataDate) == Calendar.current.component(.day, from: date) {
            return true
        }
        return false
    }
}

struct ScheduleDataView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleDataView(date: Date(), frameHeight: 17)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
