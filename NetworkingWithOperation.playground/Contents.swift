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

let BASEURL = "https://www.andyibanez.com/fairesepages.github.io/tutorials/async-await/part1"

//MARK:- Defining FETCH functions
func downloadImage( imageNumber: Int) -> UIImage? {
    let imageUrl = URL(string: BASEURL+"/\(imageNumber).png")!
    if let data = try? Data(contentsOf: imageUrl) {
        return UIImage(data: data)!
    }
    return nil
}

func downloadMetadata(imageNumber: Int) -> ImageMetadata! {
    let metaDataUrl = URL(string: BASEURL+"/\(imageNumber).json")!
    if let data = try? Data(contentsOf: metaDataUrl) {
        let metadata = try? JSONDecoder().decode(ImageMetadata.self, from: data)
        return metadata
    }
    return nil
}

// MARK:- Fetching information with NSOperations|
let queue = OperationQueue()
// We will be using main operation Queue to update UI Components
let mainQueue = OperationQueue.main

var myImage: UIImage?
var metadata: ImageMetadata?

let operationForImage = BlockOperation(block: {
    print("Started image download")
    myImage = downloadImage(imageNumber: 1)
    print("Finished image download")
})

let operationForMetadata = BlockOperation(block: {
    print("Started download metadata")
    metadata = downloadMetadata(imageNumber: 1)
    print("Finished download metadata")
})

queue.addOperation(operationForImage)
queue.addOperation(operationForMetadata)
