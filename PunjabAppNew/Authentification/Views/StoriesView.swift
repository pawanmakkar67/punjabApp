//
//  StoryCard.swift
//  FacebookClone
//
//  Created by omar thamri on 2/1/2024.
//

import SwiftUI
import Kingfisher

//import SwiftUI
//import StoryUI

struct StoriesView: View {
    @State var isPresented: Bool = false
    @State var stories: [StoryUIModel] = [
        .init(
            user: .init(
                name: "Tolga İskender",
                image: "https://image.tmdb.org/t/p/original/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg"
            ),
            stories: [
                .init(
                    mediaURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
                    date: "30 min ago",
                    config: .init(
                        storyType: .message(
                            config: .init(showLikeButton: true),
                            emojis: [
                                ["😂","😮","😍"],
                                ["😢","👏","🔥"]
                            ],
                            placeholder: "Send Message"
                        ),
                        mediaType: .video
                    )
                ),
                .init(
                    mediaURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
                    date: "30 min ago",
                    config: .init(mediaType: .video)
                ),
                    .init(
                    mediaURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
                    date: "30 min ago",
                    config: .init(
                        storyType: .message(
                            config: .init(showLikeButton: true),
                            emojis: [
                                ["😂","😮","😍"],
                                ["😢","👏","🔥"]
                            ],
                            placeholder: "Send Message"
                        ),
                        mediaType: .video
                    )
                ),
                .init(
                    mediaURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
                    date: "30 min ago",
                    config: .init(mediaType: .video)
                )

            ]
        ),
        .init(
            user: .init(
                name: "ABC",
                image: "https://image.tmdb.org/t/p/original/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg"
            ),
            stories: [
                .init(
                    mediaURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
                    date: "30 min ago",
                    config: .init(
                        storyType: .message(
                            config: .init(showLikeButton: true),
                            emojis: [
                                ["😂","😮","😍"],
                                ["😢","👏","🔥"]
                            ],
                            placeholder: "Send Message"
                        ),
                        mediaType: .video
                    )
                ),
                .init(
                    mediaURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
                    date: "30 min ago",
                    config: .init(mediaType: .video)
                ),
                    .init(
                    mediaURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
                    date: "30 min ago",
                    config: .init(
                        storyType: .message(
                            config: .init(showLikeButton: true),
                            emojis: [
                                ["😂","😮","😍"],
                                ["😢","👏","🔥"]
                            ],
                            placeholder: "Send Message"
                        ),
                        mediaType: .video
                    )
                ),
                .init(
                    mediaURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
                    date: "30 min ago",
                    config: .init(mediaType: .video)
                )

            ]
        )

    ]
    var body: some View {
        NavigationView {
            Button {
                isPresented = true
            } label: {
                Text("Show")
            }
            .fullScreenCover(isPresented: $isPresented) {
                StoryView(
                    stories: stories,
                    isPresented: $isPresented
                )
            }
        }

    }
}
#Preview {
    StoriesView()
}
