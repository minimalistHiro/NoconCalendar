//
//  SheetView.swift
//  NoconCalendar
//
//  Created by 金子広樹 on 2023/08/08.
//

import SwiftUI
import CoreData

struct SheetView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Entity.startDate, ascending: true)])
    var data: FetchedResults<Entity>
    
    let setting = Setting()
    @ObservedObject var viewModel = ContentViewModel.shared
    @Binding var isShowSheet: Bool
    
    @State private var title: String = ""                   // 入力テキスト
    @State private var selectionStartDate = Date()          // 入力日付（開始日）
    @State private var selectionEndDate = Date()            // 入力日付（終了日）
    @State private var isAllDay: Bool = false               // 終日有無
    @State private var selectedColor: ColorPicker = .blue   // カラー選択
    @State private var isShowAlert: Bool = false            // アラート表示有無
    @State private var isSelectColor: Bool = false          // カラー選択画面表示有無
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("タイトル", text: $title)
                    .listRowSeparator(.hidden)
                    .onChange(of: title) { value in
                        // 最大文字数に達したら、それ以上書き込めないようにする。
                        if value.count > setting.maxTextCount {
                            title.removeLast(title.count - setting.maxTextCount)
                        }
                    }
                Toggle("終日", isOn: $isAllDay)
                    .listRowSeparator(.hidden)
                // "終日"をオンにした場合、"開始"、"終了"を日付のみの選択にする。
                if isAllDay {
                    DatePicker("開始", selection: $selectionStartDate, displayedComponents: .date)
                        .listRowSeparator(.hidden)
                    DatePicker("終了", selection: $selectionEndDate, displayedComponents: .date)
                        .listRowSeparator(.hidden)
                } else {
                    DatePicker("開始", selection: $selectionStartDate)
                        .listRowSeparator(.hidden)
                    DatePicker("終了", selection: $selectionEndDate)
                        .listRowSeparator(.hidden)
                }
                HStack {
                    Image(systemName: "paintpalette")
                    Spacer()
                    Button {
                        isSelectColor = true
                    } label: {
                        Circle()
                            .frame(width: 30)
                            .foregroundColor(selectedColor.color)
                    }
                }
                .listRowSeparator(.hidden)
            }
            .overlay {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            // 一日当たりに登録できる予定の数を超えて、新規予定を追加しようとするとアラートを表示する。
                            if checkOverMaxDayCount() >= setting.appointmentsAvailableForRegistrationPerDay {
                                // 正確にアラートが表示されないことがあるので、処理を遅らせる。
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isShowAlert = true
                                }
                            } else {
                                create()
                                isShowSheet = false
                            }
                        } label: {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50)
                                .foregroundColor(setting.black)
                                .overlay {
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20)
                                        .bold()
                                        .foregroundColor(setting.white)
                                }
                        }
                        .padding()
                    }
                }
            }
            if isSelectColor {
                HStack {
                    ForEach(colorPicker, id: \.self) { colorPicker in
                        Button {
                            selectedColor = colorPicker
                            isSelectColor = false
                        } label: {
                            Circle()
                                .frame(width: 30)
                                .foregroundColor(colorPicker.color)
                                .overlay {
                                    if selectedColor == colorPicker {
                                        Image(systemName: "checkmark")
                                            .resizable()
                                            .scaledToFit()
                                            .bold()
                                            .frame(width: 15)
                                            .foregroundColor(.white)
                                    }
                                }
                        }
                    }
                }
                .padding(.bottom)
            }
        }
        .onAppear {
            let calendar = Calendar(identifier: .gregorian)

            let setYear = Calendar.current.component(.year, from: selectionStartDate)
            let setMonth = Calendar.current.component(.month, from: selectionStartDate)
            let setDay = Calendar.current.component(.day, from: selectionStartDate)
            let setHour = Calendar.current.component(.hour, from: selectionStartDate)
            let setMinute = Calendar.current.component(.minute, from: selectionStartDate)
            selectionEndDate = calendar.date(from: DateComponents(year: setYear, month: setMonth, day: setDay, hour: setHour + 1, minute: setMinute)) ?? selectionStartDate
        }
        .onChange(of: selectionStartDate) { date in
            let calendar = Calendar(identifier: .gregorian)

            let setYear = Calendar.current.component(.year, from: date)
            let setMonth = Calendar.current.component(.month, from: date)
            let setDay = Calendar.current.component(.day, from: date)
            let setHour = Calendar.current.component(.hour, from: date)
            let setMinute = Calendar.current.component(.minute, from: date)
            selectionEndDate = calendar.date(from: DateComponents(year: setYear, month: setMonth, day: setDay, hour: setHour + 1, minute: setMinute)) ?? date
        }
        .alert("", isPresented: $isShowAlert) {
            Button("OK") {
                isShowAlert = false
            }
        } message: {
            Text("その日に登録できる最大予定数を超えています。")
        }
    }
    
    /// Modelに新規データを保存する。
    /// - Parameters: なし
    /// - Returns: なし
    private func create() {
        let newEntity = Entity(context: viewContext)
        
        if title.isEmpty {
            newEntity.title = "タイトル"
        } else {
            newEntity.title = title
        }
        
        newEntity.isAllDay = isAllDay
        
        // "終日"がオンになったら、"開始"と"終了"の時間を00:00にする。
        if isAllDay {
            let calendar = Calendar(identifier: .gregorian)
            
            // "開始"日付の設定
            let setStartYear = Calendar.current.component(.year, from: selectionStartDate)
            let setStartMonth = Calendar.current.component(.month, from: selectionStartDate)
            let setStartDay = Calendar.current.component(.day, from: selectionStartDate)
            let setStartDate = calendar.date(from: DateComponents(year: setStartYear, month: setStartMonth, day: setStartDay, hour: 0, minute: 0, second: 0)) ?? selectionStartDate
            selectionStartDate = setStartDate
            
            // "開始"日付の設定
            let setEndYear = Calendar.current.component(.year, from: selectionEndDate)
            let setEndMonth = Calendar.current.component(.month, from: selectionEndDate)
            let setEndDay = Calendar.current.component(.day, from: selectionEndDate)
            let setEndDate = calendar.date(from: DateComponents(year: setEndYear, month: setEndMonth, day: setEndDay + 1, hour: 0, minute: 0, second: 0)) ?? selectionEndDate
            selectionEndDate = setEndDate
        }
        
        newEntity.startDate = selectionStartDate
        // 終了日が開始日より過去であった場合、終了日に開始日を代入。
        if selectionStartDate > selectionEndDate {
            newEntity.endDate = selectionStartDate
        } else {
            newEntity.endDate = selectionEndDate
        }
        
        let stringColor = viewModel.convertColorPickerToString(selectedColor)
        newEntity.color = stringColor
        
        do {
            try viewContext.save()
        } catch {
            fatalError("セーブに失敗")
        }
    }
    
    /// その日に登録している予定数をカウント
    /// - Parameters: なし
    /// - Returns: その日に登録している予定数
    private func checkOverMaxDayCount() -> Int {
        var count: Int = 0
        
        for data in data {
            if let dataDate = data.startDate {
                if viewModel.checkSameDate(dataDate: dataDate, date: selectionStartDate) {
                    count += 1
                }
            }
        }
        return count
    }
}

struct SheetView_Previews: PreviewProvider {
    static var previews: some View {
        SheetView(isShowSheet: .constant(true))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
