import Photos
import SDWebImage

final class PhotosLoader: NSObject, SDImageLoader {
  // MARK: - SDImageLoader

  func canRequestImage(for url: URL?) -> Bool {
    return url?.scheme == "ph"
  }

  func requestImage(with url: URL?, options: SDWebImageOptions = [], context: [SDWebImageContextOption : Any]?, progress progressBlock: SDImageLoaderProgressBlock?, completed completedBlock: SDImageLoaderCompletedBlock? = nil) -> SDWebImageOperation? {
    guard isPhotosStatusAuthorized() else {
      let error = makeNSError(description: "Unauthorized access to the Photos library")
      completedBlock?(nil, nil, error, false)
      return nil
    }
    guard let assetLocalIdentifier = assetLocalIdentifier(fromUrl: url) else {
      let error = makeNSError(description: "Unable to obtain the asset identifier from the url: '\(url?.absoluteString)'")
      completedBlock?(nil, nil, error, false)
      return nil
    }
    guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetLocalIdentifier], options: .none).firstObject else {
      let error = makeNSError(description: "Asset with identifier '\(assetLocalIdentifier)' not found")
      completedBlock?(nil, nil, error, false)
      return nil
    }
    request(asset: asset, completion: completedBlock)
    return nil
  }

  func shouldBlockFailedURL(with url: URL, error: Error) -> Bool {
    return false
  }
}

/**
 Checks whether the app is authorized to read the Photos library.
 */
private func isPhotosStatusAuthorized() -> Bool {
  if #available(iOS 14, *) {
    return PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized
  } else {
    return PHPhotoLibrary.authorizationStatus() == .authorized
  }
}

/**
 Returns the local identifier of the asset from the given `ph://` url.
 These urls have the form of "ph://26687849-33F9-4402-8EC0-A622CD011D70",
 where the asset local identifier is used as the host part.
 */
private func assetLocalIdentifier(fromUrl url: URL?) -> String? {
  return url?.host
}

private func request(asset: PHAsset, completion: SDImageLoaderCompletedBlock?) {
  PHImageManager.default().requestImage(
    for: asset,
    targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
    contentMode: .aspectFit,
    options: .none,
    resultHandler: { image, info in
      let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool ?? false

      completion?(image, nil, nil, !isDegraded)
    }
  )
}
