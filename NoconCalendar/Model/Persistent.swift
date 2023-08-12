//
//  Persistent.swift
//  NoconCalendar
//
//  Created by 金子広樹 on 2023/08/09.
//

import SwiftUI
import CoreData

enum ColorPicker {
    case red
    case orange
    case yellow
    case green
    case blue
    
    var color: Color {
        switch self {
        case .red:
            return .red
        case .orange:
            return .orange
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .blue:
            return .blue
        }
    }
}

let colorPicker: [ColorPicker] = [.red, .orange, .yellow, .green, .blue]

struct PersistenceController {
    let container: NSPersistentContainer
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for num in 0..<4 {
            let newItem = Entity(context: viewContext)
            newItem.title = "title\(num + 1)"
            newItem.startDate = Date().addingTimeInterval(Double(num))
            newItem.endDate = Date().addingTimeInterval(Double(num))
            newItem.isAllDay = false
            newItem.color = "black"
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}

