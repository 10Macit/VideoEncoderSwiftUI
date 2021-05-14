//
//  MediaPickerView.swift
//  VideoEncoderSwiftUI
//
//  Created by Samet Macit on 14.05.2021.
//

import SwiftUI

public struct MediaPickerView: UIViewControllerRepresentable {

    private let sourceType: UIImagePickerController.SourceType
    private let mediaTypes: [String]
    private let onMediaPicked: (URL) -> Void
    @Environment(\.presentationMode) private var presentationMode

    public init(sourceType: UIImagePickerController.SourceType, mediaTypes: [String], onMediaPicked: @escaping (URL) -> Void) {
        self.sourceType = sourceType
        self.mediaTypes = mediaTypes
        self.onMediaPicked = onMediaPicked
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = self.sourceType
        picker.delegate = context.coordinator
        picker.mediaTypes = mediaTypes
        picker.allowsEditing = false
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(
            onDismiss: { self.presentationMode.wrappedValue.dismiss() },
            onMediaPicked: self.onMediaPicked
        )
    }

    final public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

        private let onDismiss: () -> Void
        private let onMediaPicked: (URL) -> Void

        init(onDismiss: @escaping () -> Void, onMediaPicked: @escaping (URL) -> Void) {
            self.onDismiss = onDismiss
            self.onMediaPicked = onMediaPicked
        }

        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let url = info[.mediaURL] as? URL {
                self.onMediaPicked(url)
            }
            self.onDismiss()
        }

        public func imagePickerControllerDidCancel(_: UIImagePickerController) {
            self.onDismiss()
        }

    }

}
