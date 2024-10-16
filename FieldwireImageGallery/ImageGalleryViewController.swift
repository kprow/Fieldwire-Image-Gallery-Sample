//
//  ViewController.swift
//  FieldwireImageGallery
//
//  Created by Andrew Koprowski on 10/15/24.
//

import Combine
import UIKit

class ImageGalleryViewController: UIViewController {
    struct ViewModel {
        enum State: String {
            case noSearch = "Please perform a search."
            case success = "Success"
            case error = "Oops ... something went wrong."
        }
        var state: State
        var images: [ImgurResponse.ImageInfo]
    }

    private let imageService: ImageFetcherService
    private var viewModel: ViewModel
    private var cancellables = Set<AnyCancellable>()

    init(service: ImageFetcherService = ImageFetcher()) {
        self.imageService = service
        viewModel = ViewModel(state: .noSearch, images: [])
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search images"
        searchBar.delegate = self
        return searchBar
    }()

    private lazy var collectionView: UICollectionView = {
        let verticalFlowLayout = UICollectionViewFlowLayout()
        verticalFlowLayout.scrollDirection = .vertical
        verticalFlowLayout.minimumInteritemSpacing = UIView.spacing8
        verticalFlowLayout.minimumLineSpacing = UIView.spacing8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: verticalFlowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            ImageGalleryImageCell.self,
            forCellWithReuseIdentifier: ImageGalleryImageCell.reuseId
        )
        return collectionView
    }()

    private lazy var stateLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.state.rawValue
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchy()
        view.backgroundColor = .white
    }

    private func setupViewHierarchy() {
        view.addAutoLayoutSubview(searchBar)
        let containerView = UIView()
        view.addAutoLayoutSubview(containerView)
        containerView.addAutoLayoutSubview(stateLabel)
        containerView.addAutoLayoutSubview(collectionView)
        NSLayoutConstraint.activate([
            // Search Bar Constraints
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: UIView.spacing8),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -UIView.spacing8),

            // Container View Constraints
            containerView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: UIView.spacing8),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -UIView.spacing8),
            
            
            // Collection View Constraints
            collectionView.topAnchor.constraint(equalTo: containerView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),

            // State Label Constraints
            stateLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stateLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            stateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
        collectionView.isHidden = true
    }

    private func fetchImages(searchQuery: String? = nil) {
        guard let query = searchQuery else { return }
        imageService.fetchImages(query: query)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching images: \(error)")
                    self?.viewModel.state = .error
                    self?.stateLabel.text = self?.viewModel.state.rawValue
                    self?.stateLabel.isHidden = false
                    self?.collectionView.isHidden = true
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] images in
                self?.viewModel.images = images
                self?.stateLabel.isHidden = true
                self?.collectionView.isHidden = false
                self?.collectionView.reloadData()
            })
            .store(in: &cancellables)
    }

}

// MARK: - UICollectionViewDataSource

extension ImageGalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageGalleryImageCell.reuseId,
            for: indexPath
        ) as? ImageGalleryImageCell
        cell?.backgroundColor = .lightGray
        let image = viewModel.images[indexPath.row]
        cell?.configure(with: image)
        return cell ?? UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegate

extension ImageGalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedImage = viewModel.images[indexPath.item]
        let viewModel = ImageDetailViewController.ViewModel(
            imageURL: selectedImage.singleImageUrl,
            title: selectedImage.title
        )
        let imageDetailVC = ImageDetailViewController(viewModel: viewModel)
        present(imageDetailVC, animated: false)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ImageGalleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 2 - 4, height: 200)
    }
}

// MARK: - UISearchBarDelegate
extension ImageGalleryViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else {
            return
        }
        fetchImages(searchQuery: query)
        searchBar.resignFirstResponder()
    }
}

#if DEBUG
extension ImageGalleryViewController {
    struct TestHooks {
        let target: ImageGalleryViewController

        var collectionView: UICollectionView {
            target.collectionView
        }

        var searchBar: UISearchBar {
            target.searchBar
        }

        var images: [ImgurResponse.ImageInfo] {
            target.viewModel.images
        }
    }

    var testHooks: TestHooks {
        TestHooks(target: self)
    }
}
#endif
