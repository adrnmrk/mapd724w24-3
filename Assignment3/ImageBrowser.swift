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
        ZStack {
            VStack {
                Spacer()
                if let photo = photo {
                    let authorName = photo.0.owner
                    ContentView(photo: photo.0, authorName: authorName) // Pass the photo object and owner to ContentView
                        .id(photo.0.id) // Ensure ContentView updates when photo changes
                        .scaleEffect(scale)
                        .rotationEffect(rotationAngle + gestureRotation)
                        .gesture(
                            TapGesture(count: 2)
                                .onEnded { _ in
                                    // Double tap recognized, reset scale to 1
                                    scale = 1
                                }
                                .exclusively(before:
                                                TapGesture(count: 1)
                                    .onEnded { _ in
                                        // Single tap recognized, zoom in
                                        scale *= 1.5
                                    }
                                            )
                        )
                    //swipe
                        .gesture(
                            DragGesture()
                                .onEnded { gesture in
                                    let swipeThreshold: CGFloat = 100
                                    if gesture.translation.width > swipeThreshold {
                                        // Swiped right, show the next image
                                        index = (index + 1) % state.photos.count
                                        
                                        // Rotate the dial by a certain angle (e.g., 45 degrees)
                                        dialAngle -= Angle(degrees: 60)
                                    } else if gesture.translation.width < -swipeThreshold {
                                        // Swiped left, show the previous image
                                        index = index == 0 ? state.photos.count - 1 : index - 1
                                        
                                        // Rotate the dial by a certain angle (e.g., -45 degrees)
                                        dialAngle += Angle(degrees: 60)
                                    }
                                }
                        )
                    
                        .gesture(
                            RotationGesture()
                                .onChanged { angle in
                                    rotationAngle = angle
                                })
                } else {
                    Text("No photo available")
                }
                Spacer()
            }
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
                .position(x: dialRadius + 20, y: UIScreen.main.bounds.height - dialRadius - 100)
                .gesture(
                    DragGesture()
                        .onEnded{ value in
                            let startAngle = atan2(value.startLocation.x - dialRadius, value.startLocation.y - dialRadius)
                            let endAngle = atan2(value.location.x - dialRadius, value.location.y - dialRadius)
                            let diffAngle = endAngle - startAngle
                            
                            if diffAngle > 0 {
                                // Dragged clockwise, show the next image
                                index = (index + 1) % state.photos.count
                                
                                // Rotate the dial by a certain angle (e.g., 60 degrees)
                                dialAngle += Angle(degrees: 60)
                            } else if diffAngle < 0 {
                                // Dragged counterclockwise, show the previous image
                                index = index == 0 ? state.photos.count - 1 : index - 1
                                
                                // Rotate the dial by a certain angle (e.g., -60 degrees)
                                dialAngle -= Angle(degrees: 60)
                            }
                        }
                )
            
            
        }
    }
}
