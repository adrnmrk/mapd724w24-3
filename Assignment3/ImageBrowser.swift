//
//  ImageBrowser.swift
//  Assignment3
//
//  Created by Cenk Bilgen on 2024-02-12.
//

import SwiftUI

struct ImageBrowser: View {
    @StateObject var state = PhotosState()
    @State private var index = 0 // the current photo index in the array of photos
    
    @State private var scale: CGFloat = 1
    @GestureState private var gestureRotation = Angle.zero
    @State private var rotationAngle: Angle = .zero
    
    let dialRadius: CGFloat = 50
    @State private var dialAngle: Angle = .zero
    
    var photo: (FlickrService.Photo, data: Data)? {
        guard index < state.photos.count else {
            return nil
        }
        let photo = state.photos[index]
        if let data = state.photoData[photo.id] {
            return (photo, data)
        } else {
            return nil
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            if let photo = photo {
                ContentView(photo: photo.0) // Pass the photo object to ContentView
                    .scaleEffect(scale)
                    .rotationEffect(rotationAngle + gestureRotation)
                    .id(photo.0.id) // Ensure ContentView updates when photo changes
                    .gesture(
                        TapGesture(count: 1)
                            .onEnded { _ in
                                scale = scale == 1 ? 1.5 : 1
                            }
                            .simultaneously(with:
                                TapGesture(count: 2)
                                    .onEnded { _ in
                                        scale = 1
                                    }
                            )
                    )
                    .gesture(
                        DragGesture()
                            .onEnded { gesture in
                                let swipeThreshold: CGFloat = 100
                                if gesture.translation.width > swipeThreshold {
                                    // Swiped right, show the next image
                                    index = (index + 1) % state.photos.count
                                } else if gesture.translation.width < -swipeThreshold {
                                    // Swiped left, show the previous image
                                    index = index == 0 ? state.photos.count - 1 : index - 1
                                }
                            }
                    )
            } else {
                Text("No photo available")
            }
            Spacer()
        }
        .overlay(alignment: .bottomLeading) {
            Circle()
                .foregroundStyle(.pink)
                .frame(width: dialRadius*2, height: dialRadius*2)
                .overlay(alignment: .top) {
                    Capsule()
                        .frame(width: dialRadius/6, height: dialRadius/2)
                        .padding(dialRadius/10)
                }
                .rotationEffect(dialAngle)
                .opacity(state.photos.count > 1 ? 1 : 0) // hide if <1 photo
                .padding()
        }
    }
}
