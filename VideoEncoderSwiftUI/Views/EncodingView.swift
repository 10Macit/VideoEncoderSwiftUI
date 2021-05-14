//
//  EncodingView.swift
//  VideoEncoderSwiftUI
//
//  Created by Samet Macit on 14.05.2021.
//

import SwiftUI
import Photos

struct EncodingView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var isShowingAlert = false
    @State private var percent = 0.0
    
    var url: URL?
    
    var body: some View {
        ProgressView("Please wait…", value: percent, total: 1)
            .accentColor(.green)
            .padding()
            .onAppear(perform: {
                if let url = url {
                    encode(with: url)
                }
            })
            .alert(isPresented: $isShowingAlert) {
                Alert(title: Text("Saved succesfully"),
                      message: nil,
                      dismissButton: .default(Text("Ok")) {
                        self.presentationMode.wrappedValue.dismiss()
                      })
            }
    }
    
}

extension EncodingView {
    func encode(with url: URL) {
        // Declare destination path and remove anything exists in it
        let destinationPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("compressed.mp4")
        try? FileManager.default.removeItem(at: destinationPath)
        
        // Compress
        compressh264VideoInBackground(
            videoToCompress: url,
            destinationPath: destinationPath,
            size: CompressionSize(width: 540 , height: 960),
            compressionTransform: .keepSame,
            compressionConfig: .defaultConfig,
            completionHandler: { path in
                self.saveVideoToAlbum(path.absoluteURL) { error in
                    if let error = error {
                        print("Saving Error", error)
                    }
                }
            }, progressHandler: { percentage in
                DispatchQueue.main.async {
                    self.percent = Double(percentage)
                }
            },
            errorHandler: { e in
                print("Error: ", e)
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
                DispatchQueue.main.async {
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        self.isShowingAlert.toggle()
                    }
                    completion?(error)
                }
            }
        }
    }
}

struct EncodingView_Previews: PreviewProvider {
    static var previews: some View {
        EncodingView()
    }
}
