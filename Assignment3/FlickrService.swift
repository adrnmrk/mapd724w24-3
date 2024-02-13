//
//  FlickrService.swift
//  Assignment3
//
//  Created by Cenk Bilgen on 2024-02-11.
//

import Foundation
import Combine

struct FlickrService {
    static let apiKey = "a6d819499131071f158fd740860a5a88"
    static let baseURL = URL(string: "https://api.flickr.com/services/rest/")!
    // ^ rare case where force unwrapping is acceptable,
    // since we are providing the whole string literal, it must be a valid URL

    static func createRequest(apiKey: String, method: String) throws -> URLRequest {

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)

        components?.queryItems = [
            URLQueryItem(name: "method", value: method),
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "extras", value: "url_z,date_taken"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1")
        ]

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        return URLRequest(url: url)
    }

    // Note the publisher only published one value, the whole array of photos
    static func getList(maxCount: Int = 10) -> AnyPublisher<[Photo], Error> {
        do {
            let request = try createRequest(apiKey: apiKey, method: "flickr.interestingness.getList")
            print("Sending Request: \(request.debugDescription)")
            return URLSession.DataTaskPublisher(request: request, session: .shared)
                // Output type: (Data, URLResponse)
                // Failure: URLError
                .print()
                .tryMap { data, response in
                    if (response as? HTTPURLResponse)?.statusCode != 200 {
                        throw URLError(.badServerResponse)
                    } else {
                        return data
                    }
                }
                // Output type: (Data)
                // Failure: URLError
                .mapError { urlError in
                    urlError as Error
                }
                // Ouptut type: (Data)
                // Failure: Error
                .decode(type: GetListResponse.self, decoder: JSONDecoder())
                // Ouptut type: GetListResponse
                // Failure: Error
                .map { list in
                    list.photos.photo
                }
                // Output type: [Photo]
                // Failure: Error
                .eraseToAnyPublisher()

        } catch {
            return Fail<[Photo], Error>(error: error)
                .eraseToAnyPublisher()
        }
    }

    // MARK: JSON Model

    struct GetListResponse: Decodable {
        let photos: Photos
        // let extras: ... // ignore this key
        // let stat: ... // ignore this key

        struct Photos: Decodable { // NOTE: `photos` plural
            let photo: [Photo]
            // NOTE: key name is just photo, but it is actually an array of key/values which we describe in the Photo type
        }
    }

    struct Photo: Decodable, Identifiable, Equatable {
        // NOTE: Array items are unmamed (no key), so we could name this type anything
        let id: String // from server
        let title: String
        let url: URL
        let owner: String
        
        // what keys we are interested in a map variable name to json key name,
        // if we want them to be different
        enum CodingKeys: String, CodingKey {
            case id, title, owner
            case url = "url_z"
        }
    }
}

