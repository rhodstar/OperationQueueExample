import UIKit

struct ImageMetadata: Codable {
    let name: String
    let firstAppearance: String
    let year: Int
}

struct DetailedImage {
    let image: UIImage
    let metadata: ImageMetadata
}

enum ImageDownloadError: Error {
    case badImage
    case invalidMetadata
}

let BASEURL = "https://www.andyibanez.com/fairesepages.github.io/tutorials/async-await/part1"

//MARK:- Defining FETCH functions
func downloadImageAndMetadata(
    imageNumber: Int,
    completionHandler: @escaping (_ image: DetailedImage?, _ error: Error?) -> Void
) {
    let imageUrl = URL(string: BASEURL+"/\(imageNumber).png")!
    let imageTask = URLSession.shared.dataTask(with: imageUrl) { data, response, error in
        guard let data = data, let image = UIImage(data: data), (response as? HTTPURLResponse)?.statusCode == 200 else {
            completionHandler(nil, ImageDownloadError.badImage)
            return
        }
        let metadataUrl = URL(string: BASEURL+"/\(imageNumber).json")!
        let metadataTask = URLSession.shared.dataTask(with: metadataUrl) { data, response, error in
            guard let data = data, let metadata = try? JSONDecoder().decode(ImageMetadata.self, from: data),  (response as? HTTPURLResponse)?.statusCode == 200 else {
                completionHandler(nil, ImageDownloadError.invalidMetadata)
                return
            }
            let detailedImage = DetailedImage(image: image, metadata: metadata)
            completionHandler(detailedImage, nil)
        }
        metadataTask.resume()
    }
    imageTask.resume()
}

// MARK:- Fetching information with NSOperations|
let queue = OperationQueue()
// We will be using main operation Queue to update UI Components
let mainQueue = OperationQueue.main

let operation = BlockOperation(block: {
    print("Started download")
    downloadImageAndMetadata(imageNumber: 1) { imageDetail, error in
        print("Finished downloaed")
        mainQueue.addOperation {
            print("Updating UI components in main thread")
        }
    }
})

queue.addOperation(operation)
