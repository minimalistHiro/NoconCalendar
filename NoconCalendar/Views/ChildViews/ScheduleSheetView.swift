//
//  ScheduleSheetView.swift
//  NoconCalendar
//
//  Created by 金子広樹 on 2023/08/09.
//

import SwiftUI

struct ScheduleSheetView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Entity.startDate, ascending: true)])
    var data: FetchedResults<Entity>
    
    @ObservedObject var viewModel = ContentViewModel.shared
    @Binding var date: Date
    
    @State private var dateText = ""
    private let dateFormatter = DateFormatter()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(data) { data in
                    if let dataStartDate = data.startDate,
                       let dataEndDate = data.endDate,
                        let dataTitle = data.title {
                        if viewModel.checkSameDate(dataDate: dataStartDate, date: date) {
                            HStack {
                                Circle()
                                    .frame(width: 20)
                                    .foregroundColor(viewModel.convertStringToColorPicker(data.color ?? "blue"))
                                if data.isAllDay {
                                    Text("終日")
                                        .padding(.trailing)
                                        .font(.callout)
                                } else {
                                    VStack(alignment: .center) {
                                        Text("\(makeHour(dataStartDate)):\(String(format: "%02d", makeMinute(dataStartDate)))")
                                        Text("|")
                                        Text("\(makeHour(dataEndDate)):\(String(format: "%02d", makeMinute(dataEndDate)))")
                                    }
                                    .padding(.trailing)
                                    .font(.caption2)
                                }
                                
                                Text(dataTitle)
                                    .font(.headline)
                                    .bold()
                            }
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    rowRemove(data: data)
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .tint(.red)
                            }
                        }
                    }
                }
            }
            .listStyle(.inset)
            .padding()
            .navigationTitle(dateText)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            dateFormatter.dateFormat = "yyyy/MM/dd"
            dateFormatter.locale = Locale(identifier: "ja_jp")
            dateText = "\(dateFormatter.string(from: date))"
        }
    }
    
    /// Dateから"時"を抽出する
    /// - Parameters:
    ///   - date: 対象の日付
    /// - Returns: 時
    private func makeHour(_ date: Date) -> Int {
        let hour = Calendar.current.component(.hour, from: date)
        return hour
    }
    
    /// Dateから"分"を抽出する
    /// - Parameters:
    ///   - date: 対象の日付
    /// - Returns: 分
    private func makeMinute(_ date: Date) -> Int {
        let minute = Calendar.current.component(.minute, from: date)
        return minute
    }
    
    /// 行を削除する。
    /// - Parameters:
    ///   - data: 削除するデータ
    /// - Returns: なし
    private func rowRemove(data: FetchedResults<Entity>.Element) {
        viewContext.delete(data)
        do {
            try viewContext.save()
        } catch {
            fatalError("セーブに失敗")
        }
    }
}

struct ScheduleSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleSheetView(date: .constant(Date()))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
