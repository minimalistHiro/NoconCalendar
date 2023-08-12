//
//  NoconCalendarApp.swift
//  NoconCalendar
//
//  Created by 金子広樹 on 2023/08/07.
//

import SwiftUI

@main
struct NoconCalendarApp: App {
    let persistenceController = PersistenceController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(\.locale, Locale(identifier: "ja_JP"))
        }
    }
}
