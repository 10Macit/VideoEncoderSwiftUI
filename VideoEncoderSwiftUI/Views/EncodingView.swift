//
//  EncodingView.swift
//  VideoEncoderSwiftUI
//
//  Created by Samet Macit on 14.05.2021.
//

import SwiftUI

struct EncodingView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject private var model = EncodingViewModel()
    
    var url: URL?
    
    var body: some View {
        ProgressView("Please wait…", value: model.percentage, total: 1)
            .accentColor(.green)
            .padding()
            .onAppear(perform: {
                if let url = url {
                    model.encode(with: url)
                }
            })
            .alert(isPresented: $model.isShowAlert) {
                Alert(title: Text(model.alertMessage),
                      message: nil,
                      dismissButton: .default(Text("Ok")) {
                        self.presentationMode.wrappedValue.dismiss()
                      })
            }
    }
    
}

struct EncodingView_Previews: PreviewProvider {
    static var previews: some View {
        EncodingView()
    }
}
