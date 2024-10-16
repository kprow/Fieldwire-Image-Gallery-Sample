//
//  ImageGalleryImageCell.swift
//  FieldwireImageGallery
//
//  Created by Andrew Koprowski on 10/16/24.
//

import UIKit

class ImageGalleryImageCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViewHierarchy() {
        contentView.addAutoLayoutSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    func configure(with imgurImage: ImgurResponse.ImageInfo.SingleImage?) {
        guard let link = imgurImage?.link else { return }
        if let url = URL(string: link) {
            imageView.sd_setImage(with: url)
        }
    }
}
