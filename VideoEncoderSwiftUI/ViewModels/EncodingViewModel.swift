//
//  EncodingViewModel.swift
//  VideoEncoderSwiftUI
//
//  Created by Samet Macit on 15.05.2021.
//

import Foundation
import Photos


protocol EncodingViewModelProtocol {
    func encode(with url: URL)
}

class EncodingViewModel: EncodingViewModelProtocol, ObservableObject {
    
    @Published var percentage: CGFloat = 0.0
    @Published var isShowAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private var successMessage: String  = "It's completed"
    // 960 height, 540 width pixels, portrait mode as frame size
    private var defaultSize = CompressionSize(width: 540 , height: 960)
    private var tempFilePath: String = "compressed.mp4"
    
    private let defaultCompressionConfig = CompressionConfig(
        videoBitrate: 1024 * 122,
        videomaxKeyFrameInterval: 1,
        avVideoProfileLevel: AVVideoProfileLevelH264High41,
        audioSampleRate: 44100,
        audioBitrate: 64000,
        videoExpectedSourceFrameRateKey: 24
    )
    
    func encode(with url: URL) {
        // Declare destination path and remove anything exists in it
        let destinationPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tempFilePath)
        try? FileManager.default.removeItem(at: destinationPath)
        
        // Compress
        compressh264VideoInBackground(
            videoToCompress: url,
            destinationPath: destinationPath,
            size: defaultSize,
            compressionTransform: .keepSame,
            compressionConfig: defaultCompressionConfig,
            completionHandler: { path in
                self.saveVideoToAlbum(path.absoluteURL) { error in
                    if let error = error {
                        self.alertMessage = error.localizedDescription
                        print("Saving Error", error)
                    }
                    self.isShowAlert = true
                }
            }, progressHandler: { percentage in
                DispatchQueue.main.async {
                    self.percentage = percentage
                }
            },
            errorHandler: { error in
                self.alertMessage = error.localizedDescription
                self.isShowAlert = true
                print("Error: ", error)
            }
        )
    }
    
    
    func requestAuthorization(completion: @escaping ()->Void) {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    completion()
                }
            }
        } else if PHPhotoLibrary.authorizationStatus() == .authorized{
            completion()
        }
    }
    
    func saveVideoToAlbum(_ outputURL: URL, _ completion: ((Error?) -> Void)?) {
        requestAuthorization {
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .video, fileURL: outputURL, options: nil)
            }) { (result, error) in
                DispatchQueue.main.async { [self] in
                    if let error = error {
                        //show error
                        print(error.localizedDescription)
                    } else {
                        self.alertMessage = self.successMessage
                    }
                    completion?(error)
                }
            }
        }
    }
    
}
