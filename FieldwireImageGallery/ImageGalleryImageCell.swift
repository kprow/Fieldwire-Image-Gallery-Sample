//
//  ImageGalleryImageCell.swift
//  FieldwireImageGallery
//
//  Created by Andrew Koprowski on 10/16/24.
//

import UIKit
import SDWebImage

class ImageGalleryImageCell: UICollectionViewCell {
    static let reuseId = "ImageGalleryImageCell"
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
        label.textColor = .white
        label.backgroundColor = .black
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViewHierarchy() {
        contentView.addAutoLayoutSubview(titleLabel)
        contentView.addAutoLayoutSubview(imageView)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func configure(with imgurImage: ImgurResponse.ImageInfo?) {
        titleLabel.text = imgurImage?.title
        guard let link = imgurImage?.images.first(where: { $0.type.contains("image") })?.link else { return }
        if let url = URL(string: link) {
            imageView.sd_setImage(with: url)
        }
    }
}

#if DEBUG
extension ImageGalleryImageCell {
    struct TestHooks {
        let target: ImageGalleryImageCell

        var titleLabel: UILabel {
            target.titleLabel
        }

        var imageView: UIImageView {
            target.imageView
        }
    }

    var testHooks: TestHooks {
        TestHooks(target: self)
    }
}
#endif
