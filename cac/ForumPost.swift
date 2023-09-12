//
//  ForumPost.swift
//  cac
//
//  Created by 安室和成 on 7/26/23.
//

import SwiftUI

struct ForumPost: View {
    @State var isLiked: Bool = false
    let image: Image
    let comment: String

    var body: some View {
        VStack {
            image
                .resizable()
                .scaledToFit()
                .frame(height: 200)
            Text(comment)
            Button(action: {
                isLiked.toggle()
            }) {
                HStack {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                    Text(isLiked ? "Liked" : "Like")
                }
            }
            .padding()
            .foregroundColor(isLiked ? .red : .gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 5)
    }
}

