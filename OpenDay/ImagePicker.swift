import SwiftUI
import Photos
import CoreLocation

struct ImagePickerViewController: UIViewControllerRepresentable {
    @Binding var presentationMode: PresentationMode

    var imagePicked: ((ImageAsset) -> Void)?

    //swiftlint:disable line_length
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerViewController>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.delegate = context.coordinator

        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { _ in

            }
        }

        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePickerViewController>) {
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        var parent: ImagePickerViewController

        init(_ parent: ImagePickerViewController) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            guard let asset = info[.phAsset] as? PHAsset else {
                return
            }

            let image = asset.image

            parent.imagePicked?(ImageAsset(image: image,
                                           location: asset.location,
                                           creationDate: asset.creationDate))
            parent.presentationMode.dismiss()
            picker.dismiss(animated: true, completion: nil)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.dismiss()
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

struct ImagePicker: View {
    var imagePicked: ((ImageAsset) -> Void)?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ImagePickerViewController(presentationMode: presentationMode,
                                  imagePicked: imagePicked)
    }
}

extension PHAsset {
    var image: UIImage {
        var readImage = UIImage()
        let imageManager = PHCachingImageManager()
        let requestOptions = PHImageRequestOptions()

        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.fast
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.isSynchronous = true

        imageManager.requestImage(for: self,
                                  targetSize: PHImageManagerMaximumSize,
                                  contentMode: PHImageContentMode.default,
                                  options: requestOptions,
                                  resultHandler: { image, _ in
                                    guard let image = image else {
                                        return
                                    }
            readImage = image
        })

        return readImage
    }
}
