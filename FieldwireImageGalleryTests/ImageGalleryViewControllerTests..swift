//
//  FieldwireImageGalleryTests.swift
//  FieldwireImageGalleryTests
//
//  Created by Andrew Koprowski on 10/15/24.
//

import XCTest
@testable import FieldwireImageGallery

final class ImageGalleryViewControllerTests: XCTestCase {

    var sut: ImageGalleryViewController! // System Under Test

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = ImageGalleryViewController()
        sut.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testNumberOfItemsInSection() throws {
        // Given
        let indexPath = IndexPath(item: 0, section: 0)
        // When
        let observedNumberOfItems = sut.collectionView(sut.testHooks.collectionView, numberOfItemsInSection: indexPath.section)
        // Then
        XCTAssertGreaterThan(observedNumberOfItems, 0,
        """
        The numberOfItemsInSection should be implemented and return non-zero.
        """
        )
    }
}
