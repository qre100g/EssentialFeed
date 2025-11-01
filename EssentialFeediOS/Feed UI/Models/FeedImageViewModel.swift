//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 02/11/25.
//

import UIKit
import EssentialFeed

final class FeedImageViewModel {
    typealias Observer<T> = (T) -> Void
    
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    var hasLocation: Bool {
        model.location != nil
    }
    
    var location: String? {
        model.location
    }
    
    var description: String? {
        model.description
    }
    
    var onImageLoad: Observer<UIImage>?
    var onImageLoadStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    func loadImage() {
        onImageLoadStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        task = imageLoader.loadImageData(from: model.imageURL) { [weak self] result in
            if let image = (try? result.get()).flatMap(UIImage.init) {
                self?.onImageLoad?(image)
            } else {
                self?.onShouldRetryImageLoadStateChange?(true)
            }
            self?.onImageLoadStateChange?(false)
        }
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
    
}
