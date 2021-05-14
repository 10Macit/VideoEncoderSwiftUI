//
//  SelectVideoView.swift
//  VideoEncoderSwiftUI
//
//  Created by Samet Macit on 14.05.2021.
//

import SwiftUI

struct SelectVideoView: View {
    @State private var isShowingEncoding = false
    @State private var isShowingMediaPicker = false
    @State private var url: URL?
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination:  EncodingView(url: self.url),
                               isActive: $isShowingEncoding) {
                    
                }
                Button(action: {
                    openVideoPicker()
                }, label: {
                    Text("Select Video")
                }).padding()
            }
        }
        .sheet(isPresented: $isShowingMediaPicker) {
            MediaPickerView(sourceType: .savedPhotosAlbum,
                            mediaTypes: ["public.movie"]) { url in
                self.url = url
                self.isShowingEncoding.toggle()
            }
        }
    }
    
    func openVideoPicker() {
        isShowingMediaPicker.toggle()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SelectVideoView()
    }
}
