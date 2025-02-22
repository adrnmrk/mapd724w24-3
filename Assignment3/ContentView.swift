//
//  ContentView.swift
//  Assignment3
//
//  Created by Cenk Bilgen on 2024-02-11.
//

import SwiftUI

struct ImageView: View {
    @State private var downloadedImage: UIImage? // Store the downloaded image
    
    let photo: FlickrService.Photo // Photo object containing URL
    
    var body: some View {
        if let image = downloadedImage {
            // If the image has been downloaded, display it
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            // If the image has not been downloaded yet, show a placeholder
            ProgressView() // You can use any placeholder view here
                .onAppear(perform: downloadImage) // Trigger image download when the view appears
        }
    }
    
    private func downloadImage() {
        // Use the URL property of the Photo object to download the image data asynchronously
        URLSession.shared.dataTask(with: photo.url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                // If image data is downloaded successfully, update the downloadedImage state
                DispatchQueue.main.async {
                    self.downloadedImage = image
                }
            } else {
                // Handle any errors that occur during image download
                print("Error downloading image:", error?.localizedDescription ?? "Unknown error")
            }
        }.resume() // Start the URLSession task
    }
}

// Example usage in ContentView
struct ContentView: View {
    let photo: FlickrService.Photo // Example Photo object
    let authorName: String // Author's name
    var body: some View {
        Text(authorName)
            .padding(5)
            .background(Color.black.opacity(0.5))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 5))
        ImageView(photo: photo).scaledToFit()

    }
}


