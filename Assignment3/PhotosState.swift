//
//  NetworkModel.swift
//  Assignment3
//
//  Created by Cenk Bilgen on 2024-02-11.
//

import Foundation
import Combine

class PhotosState: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []

    @Published var photos: [FlickrService.Photo] = []

    @Published var photoData: [FlickrService.Photo.ID: Data] = [:]
//changed to 6
    init(maxPhotos: Int = 6) {
        FlickrService
            .getList()
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                    case .failure(let error):
                        print("Network Error. \(error.localizedDescription)")
                    case .finished:
                        print("Network Request Finished.")
                        for photo in self.photos {
                            self.downloadPhotoData(photo: photo)
                            print("Downloading Photo Data: \(photo)")
                        }
                }
            } receiveValue: { photos in
                print("Got \(photos.map { $0.title }.formatted(.list(type: .and)))")
                if !photos.isEmpty {
                    // randomly shuffle photos array and pick first maxCount (or up to count)
                    self.photos = Array(photos.shuffled()[0..<min(maxPhotos, photos.count)])
                }
            }
            .store(in: &cancellables) // this completes the publisher-subscriber connection and starts the network request
    }

    func downloadPhotoData(photo: FlickrService.Photo) {
        // really try to download the data and throw any error
        let data = Data()
        photoData[photo.id] = data  // move this to when the download is done, in the sink
    }
}
