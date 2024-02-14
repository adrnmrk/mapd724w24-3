//
//  ImageBrowser.swift
//  Assignment3
//
//  Created by Cenk Bilgen on 2024-02-12.
//

import SwiftUI

struct ImageBrowser: View {
    @StateObject var state = PhotosState()
    @State var index = 0 // the current photo index in the array of photos
    
    @State var scale: CGFloat = 1
    @GestureState private var gestureRotation = Angle.zero
    @State private var rotationAngle: Angle = .zero
    
    let dialRadius: CGFloat = 50
    @State var dialAngle: Angle = .zero
    
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
                    .frame(width: 200, height: 200) // Adjust size as needed
                    .scaleEffect(scale)
                    .rotationEffect(rotationAngle + gestureRotation)
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
            } else {
                Text("No photo available")
            }
            Spacer()
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    let change = value.translation.width / 10 // Adjust the sensitivity
                    withAnimation {
                        // Handle swipe gesture here
                        // Calculate the new index
                                       var newIndex = index + Int(change)
                                       
                                       // Ensure the index stays within bounds
                                       if newIndex < 0 {
                                           newIndex = 0
                                       } else if newIndex >= state.photos.count {
                                           newIndex = state.photos.count - 1
                                       }
                                       
                                       // Update the index
                                       index = newIndex
                    }
                }
        )
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
                        .gesture(
                            RotationGesture()
                                .onChanged { value in
                                    // Update dialAngle directly
                                    dialAngle = value
                                    
                                    // Calculate the index based on the rotation angle
                                    let indexIncrement = Double(state.photos.count) * Double(value.radians) / (2 * .pi)
                                    index = max(0, min(state.photos.count - 1, Int(indexIncrement)))
                                }
                        )
                }
            }
        
    
    //    // you may ne
    
    
    
    // SwiftUI Image does not have an initializer from Data. UIImage does, so we created a SwiftUI Image by creating a UIImage first, which is probably fine for just a class assignment, but I still don't like it.
    // Use this instead.
    // NOTE: when making extensions to system-wide types like Image,
    // keep your modifications private to the file to avoid conflicts
    // especially if you are doing so in a shared library
    
    //fileprivate extension Image {
    //    init?(data: Data, scale: CGFloat) {
    //        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
    //              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
    //            return nil
    //        }
    //        self = Image(decorative: cgImage, scale: scale)
    //    }
    //}
}

