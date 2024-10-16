//
//  ViewController.swift
//  FieldwireImageGallery
//
//  Created by Andrew Koprowski on 10/15/24.
//

import Combine
import SDWebImage
import UIKit

class ImageGalleryViewController: UIViewController {

    let reuseId = "ImageCell"
    private let imageService: ImageFetcherService = ImageFetcher()
    private var images: [ImgurResponse.ImageInfo] = []
    private var cancellables = Set<AnyCancellable>()

    private lazy var collectionView: UICollectionView = {
        let verticalFlowLayout = UICollectionViewFlowLayout()
        verticalFlowLayout.scrollDirection = .vertical
        verticalFlowLayout.minimumInteritemSpacing = UIView.spacing8
        verticalFlowLayout.minimumLineSpacing = UIView.spacing8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: verticalFlowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImageGalleryImageCell.self, forCellWithReuseIdentifier: reuseId)
        collectionView.backgroundColor = .gray
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchy()
        fetchImages()
        view.backgroundColor = .red
    }

    private func setupViewHierarchy() {
        view.addAutoLayoutSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: UIView.spacing8),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -UIView.spacing8)
        ])
    }

    func fetchImages() {
        imageService.fetchImages()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching images: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] images in
                self?.images = images
                self?.collectionView.reloadData()
            })
            .store(in: &cancellables)
    }

}
extension ImageGalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as? ImageGalleryImageCell
        let colors: [UIColor] = [.cyan, .blue, .green]
        cell?.backgroundColor = colors.randomElement()
        let image = images[indexPath.row]
        cell?.configure(with: image.images.first(where: { $0.type.contains("image") }))
        return cell ?? UICollectionViewCell()
    }
}
extension ImageGalleryViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 2 - 4, height: 200)
        }
}

#if DEBUG
extension ImageGalleryViewController {
    struct TestHooks {
        let target: ImageGalleryViewController

        var collectionView: UICollectionView {
            target.collectionView
        }
    }

    var testHooks: TestHooks {
        TestHooks(target: self)
    }
}
#endif
