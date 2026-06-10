import UIKit

/// Slices a UIImage into an NxN grid of equal-sized tiles.
/// Tiles are returned in row-major order: index 0 is top-left,
/// index (N*N - 1) is bottom-right.
enum ImageSlicer {

    struct SliceError: Error, LocalizedError {
        let message: String
        var errorDescription: String? { message }
    }

    /// Slice `image` into `gridSize × gridSize` tiles.
    /// - Parameters:
    ///   - image: The source image to slice.
    ///   - gridSize: Number of rows (and columns). Must be ≥ 2.
    /// - Returns: An array of `gridSize * gridSize` `UIImage` tiles in row-major order.
    static func slice(_ image: UIImage, gridSize: Int) throws -> [UIImage] {
        guard gridSize >= 2 else {
            throw SliceError(message: "gridSize must be at least 2, got \(gridSize)")
        }

        guard let cgImage = image.cgImage else {
            throw SliceError(message: "Could not obtain CGImage from source UIImage")
        }

        let totalWidth  = CGFloat(cgImage.width)
        let totalHeight = CGFloat(cgImage.height)
        let tileWidth   = totalWidth  / CGFloat(gridSize)
        let tileHeight  = totalHeight / CGFloat(gridSize)
        let scale       = image.scale

        var tiles: [UIImage] = []
        tiles.reserveCapacity(gridSize * gridSize)

        for row in 0 ..< gridSize {
            for col in 0 ..< gridSize {
                // Crop rect in the CGImage's pixel coordinate space
                let cropRect = CGRect(
                    x: CGFloat(col) * tileWidth,
                    y: CGFloat(row) * tileHeight,
                    width: tileWidth,
                    height: tileHeight
                )

                guard let croppedCG = cgImage.cropping(to: cropRect) else {
                    throw SliceError(message: "Failed to crop tile at row \(row), col \(col)")
                }

                let tile = UIImage(cgImage: croppedCG, scale: scale, orientation: image.imageOrientation)
                tiles.append(tile)
            }
        }

        return tiles
    }

    /// Convenience: slice a named asset image.
    static func slice(named name: String, gridSize: Int) throws -> [UIImage] {
        guard let image = UIImage(named: name) else {
            throw SliceError(message: "Image named '\(name)' not found in asset catalogue")
        }
        return try slice(image, gridSize: gridSize)
    }
}
