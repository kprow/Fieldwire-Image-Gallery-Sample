//
//  ImageFetcher.swift
//  FieldwireImageGallery
//
//  Created by Andrew Koprowski on 10/16/24.
//

import UIKit
import Combine

protocol ImageFetcherService {
    func fetchImages() -> AnyPublisher<[ImgurResponse.ImageInfo], Error>
}

class ImageFetcher: ImageFetcherService {
    private let clientID = "b067d5cb828ec5a"
    private let apiURL = "https://api.imgur.com/3/gallery/search"

    private func getRequest(params: ImgurRequestParams) -> URLRequest? {
        guard var urlComponents = URLComponents(string: apiURL) else { return nil }
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: params.query),
            URLQueryItem(name: "q_type", value: "jpg|png")
        ]
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(clientID)", forHTTPHeaderField: "Authorization")
        return request
    }

    func fetchImages() -> AnyPublisher<[ImgurResponse.ImageInfo], Error> {
        let params = ImgurRequestParams(query: "starships")
        guard let request = getRequest(params: params) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: ImgurResponse.self, decoder: JSONDecoder())
            .map {
                $0.data
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
struct ImgurRequestParams {
    let query: String
    let sort: ImgurSort? = nil
    let window: ImgurWindow? = nil
    let page: Int? = nil
    enum ImgurSort: String {
        case time
        case viral
        case top
    }
    enum ImgurWindow: String {
        case day
        case week
        case month
        case year
        case all
    }
}

struct ImgurResponse: Codable {
    let data: [ImageInfo]
    struct ImageInfo: Codable {
        let id: String
        let title: String?
        let link: String
        let images: [SingleImage]
        struct SingleImage: Codable {
            let link: String
            let type: String
        }
    }
}
