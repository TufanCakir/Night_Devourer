//
//  NightTheme.swift
//  Night Devourer
//
//  Created by Tufan Cakir on 07.06.26.
//

import SwiftUI

enum NightTheme {
    static let bone = Color(red: 0.91, green: 0.89, blue: 0.82)
    static let oldCloth = Color(red: 0.72, green: 0.70, blue: 0.63)
    static let ash = Color(red: 0.42, green: 0.43, blue: 0.42)
    static let deepBlack = Color.black
    static let driedBlood = Color(red: 0.62, green: 0.04, blue: 0.03)
    static let coldMist = Color(red: 0.44, green: 0.50, blue: 0.54)

    static var titleGradient: LinearGradient {
        LinearGradient(
            colors: [bone, ash],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var bandageGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.82, green: 0.80, blue: 0.72),
                Color(red: 0.50, green: 0.49, blue: 0.44),
                Color(red: 0.89, green: 0.87, blue: 0.78),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
