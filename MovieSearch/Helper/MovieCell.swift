//
//  MovieCell.swift
//  MovieSearch
//
//  Created by JooYoung Kim on 1/16/26.
//

import UIKit
import Kingfisher

final class MovieCell: UICollectionViewCell {
    static let identifier: String = "MovieCell"
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private var subtitleLabel = UILabel()
    private var favoriteBadge = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .secondarySystemBackground
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .tertiarySystemFill
        
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.numberOfLines = 3
        
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 1
        
        favoriteBadge.font = .systemFont(ofSize: 11, weight: .bold)
        favoriteBadge.text = "★"
        favoriteBadge.textAlignment = .center
        favoriteBadge.backgroundColor = .systemYellow
        favoriteBadge.textColor = .black
        favoriteBadge.layer.cornerRadius = 10
        favoriteBadge.layer.masksToBounds = true
        favoriteBadge.isHidden = true
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        
        [imageView, textStack, favoriteBadge].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.414),

            textStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            textStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),

            favoriteBadge.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            favoriteBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            favoriteBadge.widthAnchor.constraint(equalToConstant: 20),
            favoriteBadge.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func setupData(item: MovieItem, isFavorite: Bool) {
        titleLabel.text = item.title
        subtitleLabel.text = "\(item.year) • \(item.type)"
        favoriteBadge.isHidden = !isFavorite
        
        let placeholder = UIImage(systemName: "photo.badge.exclamationmark")

        guard
            let poster = item.poster,
            poster != "N/A",
            let url = URL(string: poster)
        else {
            imageView.image = placeholder
            imageView.tintColor = .tertiaryLabel
            return
        }
        
        imageView.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ]
        ) { [weak self] result in
            guard let self else { return }
            if case .failure = result {
                self.imageView.contentMode = .scaleAspectFit
                self.imageView.image = placeholder
                self.imageView.tintColor = .tertiaryLabel
            } else {
                self.imageView.contentMode = .scaleAspectFill
                self.imageView.tintColor = nil
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        imageView.tintColor = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        favoriteBadge.isHidden = true
    }
}

