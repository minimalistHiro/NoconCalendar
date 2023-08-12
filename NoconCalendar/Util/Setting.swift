//
//  Setting.swift
//  NoconCalendar
//
//  Created by 金子広樹 on 2023/08/07.
//

import SwiftUI

final class Setting {
    // 各種設定
    let appointmentsAvailableForRegistrationPerDay: Int = 4 // 一日当たりに登録できる予定の数
    let maxCalendarTextCount: Int = 4                       // カレンダーに表示する最大テキスト数
    let maxTextCount: Int = 30                              // 最大テキスト文字数
    // 固定色
    let black: Color = Color("Black")                       // 文字・ボタン色
    let white: Color = Color("White")                       // 背景色
    let highlight: Color = Color("Highlight")               // 強調色
}

