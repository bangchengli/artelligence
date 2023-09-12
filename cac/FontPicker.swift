//
//  FontPicker.swift
//  cac
//
//  Created by 安室和成 on 7/12/23.
//

import SwiftUI

struct FontPicker: View {
    @Binding var selectedFontName: String
    @Environment(\.presentationMode) private var presentationMode
    
    private var availableFonts: [String] {
        UIFont.familyNames.sorted().flatMap { UIFont.fontNames(forFamilyName: $0) }
    }
    
    var body: some View {
        NavigationView {
            List(availableFonts, id: \.self) { font in
                Button(action: {
                    selectedFontName = font
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(font)
                }
            }
            .navigationTitle("Select Font")
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done")
            })
        }
    }
}
