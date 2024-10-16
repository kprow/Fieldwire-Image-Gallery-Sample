//
//  ImageDetailViewController.swift
//  FieldwireImageGallery
//
//  Created by Andrew Koprowski on 10/16/24.
//
import UIKit

class ImageDetailViewController: UIViewController {
    private let viewModel: ViewModel
    struct ViewModel {
        let imageURL: URL?
        let title: String?
    }

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.spacing = UIView.spacing8
        return stackView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        label.backgroundColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViewHierarchy()
        load()
    }

    private func setupViewHierarchy() {
        view.addAutoLayoutSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIView.spacing8),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIView.spacing8),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(imageView)
    }

    private func load() {
        titleLabel.text = viewModel.title
        guard let url = viewModel.imageURL else { return }
        imageView.sd_setImage(with: url)
    }
}
