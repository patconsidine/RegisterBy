import SwiftUI
import PhotosUI
import UIKit

enum ProductPhotoKind: String, Identifiable {
    case receipt
    case serial

    var id: String { rawValue }
}

struct ProductPhotosFormSection: View {
    @Binding var receiptImage: UIImage?
    @Binding var serialImage: UIImage?

    @State private var receiptItem: PhotosPickerItem?
    @State private var serialItem: PhotosPickerItem?
    @State private var cameraPhoto: ProductPhotoKind?

    var body: some View {
        Section {
            photoAttachmentGroup(
                title: "Receipt",
                icon: "doc.viewfinder",
                image: receiptImage,
                pickerSelection: $receiptItem,
                cameraKind: .receipt
            ) {
                receiptImage = nil
                receiptItem = nil
            }
            Divider()
            photoAttachmentGroup(
                title: "Serial / model plate",
                icon: "barcode.viewfinder",
                image: serialImage,
                pickerSelection: $serialItem,
                cameraKind: .serial
            ) {
                serialImage = nil
                serialItem = nil
            }
        } header: {
            Text("Photos")
        } footer: {
            Text("Optional. Photos stay on this iPhone only.")
        }
        .onChange(of: receiptItem) { _, item in
            Task { await loadImage(from: item, isReceipt: true) }
        }
        .onChange(of: serialItem) { _, item in
            Task { await loadImage(from: item, isReceipt: false) }
        }
        .sheet(item: $cameraPhoto) { kind in
            CameraImagePicker(image: imageBinding(for: kind))
                .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private func photoAttachmentGroup(
        title: String,
        icon: String,
        image: UIImage?,
        pickerSelection: Binding<PhotosPickerItem?>,
        cameraKind: ProductPhotoKind,
        onRemove: @escaping () -> Void
    ) -> some View {
        Group {
            if let image {
                HStack(spacing: 12) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Text(title)
                        .font(.subheadline.weight(.medium))
                    Spacer()
                }
            } else {
                Label(title, systemImage: icon)
                    .font(.subheadline.weight(.medium))
            }

            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button {
                    cameraPhoto = cameraKind
                } label: {
                    Label(image == nil ? "Take photo" : "Retake photo", systemImage: "camera")
                }
            }

            PhotosPicker(selection: pickerSelection, matching: .images) {
                Label(image == nil ? "Choose from library" : "Replace from library", systemImage: "photo.on.rectangle")
            }

            if image != nil {
                Button("Remove photo", role: .destructive, action: onRemove)
            }
        }
    }

    private func imageBinding(for kind: ProductPhotoKind) -> Binding<UIImage?> {
        switch kind {
        case .receipt:
            Binding(get: { receiptImage }, set: { receiptImage = $0 })
        case .serial:
            Binding(get: { serialImage }, set: { serialImage = $0 })
        }
    }

    private func loadImage(from item: PhotosPickerItem?, isReceipt: Bool) async {
        guard let item else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            await MainActor.run {
                if isReceipt { receiptImage = image }
                else { serialImage = image }
            }
        }
    }
}

enum ProductPhotoPersistence {
    static func saveReceipt(_ image: UIImage?, for item: ProductItem) {
        if let image {
            ImageStore.delete(filename: item.receiptImageFilename)
            item.receiptImageFilename = ImageStore.save(image, for: item.id, kind: "receipt")
        } else {
            ImageStore.delete(filename: item.receiptImageFilename)
            item.receiptImageFilename = nil
        }
    }

    static func saveSerial(_ image: UIImage?, for item: ProductItem) {
        if let image {
            ImageStore.delete(filename: item.serialImageFilename)
            item.serialImageFilename = ImageStore.save(image, for: item.id, kind: "serial")
        } else {
            ImageStore.delete(filename: item.serialImageFilename)
            item.serialImageFilename = nil
        }
    }
}
