//
//  FieldwireImageGalleryTests.swift
//  FieldwireImageGalleryTests
//
//  Created by Andrew Koprowski on 10/15/24.
//

import Combine
import XCTest
@testable import FieldwireImageGallery

final class ImageGalleryViewControllerTests: XCTestCase {
    
    /// Subject under test
    var sut: ImageGalleryViewController!
    var mockService: MockImageService!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockService = MockImageService()
        cancellables = []
        sut = ImageGalleryViewController(service: mockService)
        sut.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        sut = nil
        mockService = nil
        cancellables = nil
    }

    let indexPath = IndexPath(item: 0, section: 0)

    let mockImages = [
        ImgurResponse.ImageInfo(id: "1",
                                title: "Title 1",
                                link: "https://link1.com",
                                images: [ImgurResponse.ImageInfo.SingleImage(
                                    link: "https://link1.com/img.jpg",
                                    type: "image/jpg")]),
        ImgurResponse.ImageInfo(id: "2",
                                title: "Title 2",
                                link: "https://link2.com",
                                images: [ImgurResponse.ImageInfo.SingleImage(
                                    link: "https://link2.com/img.jpg",
                                    type: "image/jpg")]),
    ]
    let searchTerm = "Test Search"
    
    func testNumberOfItemsInSection() throws {
        // Given
        mockService.mockImages = mockImages

        // When
        sut.viewDidLoad()

        // Then
        XCTAssertEqual(sut.testHooks.images.count, 0,
        """
        Before a search is performed,
        the number of images should be 0.
        """)

        // When
        sut.testHooks.searchBar.text = searchTerm
        sut.searchBarSearchButtonClicked(sut.testHooks.searchBar)
        XCTAssertEqual(sut.testHooks.images.count, mockImages.count,
        """
        The number of images
        should be the number of images returned from the api.
        """
        )
        let observedNumberOfItems = sut.collectionView(sut.testHooks.collectionView, numberOfItemsInSection: indexPath.section)
        XCTAssertEqual(observedNumberOfItems, mockImages.count,
        """
        The numberOfItemsInSection should be implemented 
        and return the number of images.
        """
        )
    }

    func testCellForItemAt() throws {
        // Given
        mockService.mockImages = mockImages

        // When
        sut.testHooks.searchBar.text = searchTerm
        sut.searchBarSearchButtonClicked(sut.testHooks.searchBar)
        let observedCell = sut.collectionView(sut.testHooks.collectionView, cellForItemAt: indexPath) as? ImageGalleryImageCell
        
        // Then
        XCTAssertEqual(observedCell?.testHooks.titleLabel.text, "Title 1",
        """
        The cellForItemAt should be implemented
        and return the first image.
        It's tilte should be from the title of the first image in the response.
        """
        )
    }

    func testDidSelectItemAt() throws {
        // Given
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        window.rootViewController = sut
        _ = sut.view
        mockService.mockImages = mockImages
        sut.testHooks.searchBar.text = searchTerm
        sut.searchBarSearchButtonClicked(sut.testHooks.searchBar)

        // When
        sut.collectionView(sut.testHooks.collectionView, didSelectItemAt: indexPath)

        // Then
        XCTAssert(sut.presentedViewController is ImageDetailViewController,
        """
        The didSelectItemAt should be implemented
        and when an image is selected
        It should present the ImageDetailViewController.
        """
        )
    }

}

class MockImageService: ImageFetcherService {
    var mockImages: [ImgurResponse.ImageInfo] = []
    var mockError: Error? = nil
    
    func fetchImages(query: String) -> AnyPublisher<[ImgurResponse.ImageInfo], Error> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        } else {
            return Just(mockImages)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}
