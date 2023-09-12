//
//  cacApp.swift
//  cac
//
//  Created by 安室和成 on 6/28/23.
//

import SwiftUI

@main
struct cacApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(ChatViewModel())
        }
    }
}
