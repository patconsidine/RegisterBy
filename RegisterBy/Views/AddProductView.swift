import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct AddProductView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchases: PurchaseManager

    @Query(filter: #Predicate<ProductItem> { !$0.isArchived })
    private var existing: [ProductItem]

    @State private var name = ""
    @State private var brand = ""
    @State private var category: ProductCategory = .electronics
    @State private var purchaseDate = Date.now
    @State private var storeName = ""
    @State private var registrationRequired = true
    @State private var registerWithinDays = 30
    @State private var trackReturn = true
    @State private var returnWithinDays = 30
    @State private var warrantyYears = 2
    @State private var registrationURL = ""
    @State private var modelNumber = ""
    @State private var serialNumber = ""
    @State private var claimNotes = ""
    @State private var brandRegion: BrandRegion = .current

    @State private var receiptItem: PhotosPickerItem?
    @State private var serialItem: PhotosPickerItem?
    @State private var receiptImage: UIImage?
    @State private var serialImage: UIImage?
    @State private var cameraPhoto: ProductPhotoKind?

    var body: some View {
        NavigationStack {
            Form {
                Section("Product") {
                    TextField("Product name", text: $name)
                    TextField("Brand (optional)", text: $brand)
                    Picker("Category", selection: $category) {
                        ForEach(ProductCategory.allCases) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    .onChange(of: category) { _, new in
                        applyDefaults(for: new)
                    }
                }

                Section("Purchase") {
                    DatePicker("Purchase date", selection: $purchaseDate, displayedComponents: .date)
                    TextField("Store (optional)", text: $storeName)
                }

                Section("Register by") {
                    Toggle("Registration required", isOn: $registrationRequired)
                    if registrationRequired {
                        Picker("Register within", selection: $registerWithinDays) {
                            Text("14 days").tag(14)
                            Text("30 days").tag(30)
                            Text("60 days").tag(60)
                            Text("90 days").tag(90)
                        }
                        if let regBy = registerByPreview {
                            Text("Register by: \(regBy.formatted(date: .abbreviated, time: .omitted))")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        TextField("Registration URL", text: $registrationURL)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                        brandChips
                    }
                }

                Section("Return window") {
                    Toggle("Track store return", isOn: $trackReturn)
                    if trackReturn {
                        Picker("Return within", selection: $returnWithinDays) {
                            Text("14 days").tag(14)
                            Text("30 days").tag(30)
                            Text("60 days").tag(60)
                        }
                        if let retBy = returnByPreview {
                            Text("Return by: \(retBy.formatted(date: .abbreviated, time: .omitted))")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Warranty") {
                    Picker("Warranty length", selection: $warrantyYears) {
                        Text("1 year").tag(1)
                        Text("2 years").tag(2)
                        Text("3 years").tag(3)
                        Text("5 years").tag(5)
                        Text("10 years").tag(10)
                    }
                    Text("Warranty ends: \(warrantyEndPreview.formatted(date: .abbreviated, time: .omitted))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                photosSection

                Section("Claims (optional)") {
                    TextField("Model number", text: $modelNumber)
                    TextField("Serial number", text: $serialNumber)
                    TextField("Claim notes", text: $claimNotes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                applyDefaults(for: category)
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
    }

    @ViewBuilder
    private var photosSection: some View {
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
    }

    private enum ProductPhotoKind: String, Identifiable {
        case receipt
        case serial

        var id: String { rawValue }
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

    private var brandChips: some View {
        VStack(alignment: .leading, spacing: 8) {
            Picker("Region", selection: $brandRegion) {
                ForEach(BrandRegion.allCases) { r in
                    Text(r.rawValue).tag(r)
                }
            }
            .pickerStyle(.segmented)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(BrandLinks.all) { brand in
                        Button(brand.name) {
                            if let url = BrandLinks.url(for: brand, region: brandRegion) {
                                registrationURL = url.absoluteString
                            }
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }
        }
    }

    private var registerByPreview: Date? {
        guard registrationRequired else { return nil }
        return Calendar.current.date(byAdding: .day, value: registerWithinDays, to: purchaseDate)
    }

    private var returnByPreview: Date? {
        guard trackReturn else { return nil }
        return Calendar.current.date(byAdding: .day, value: returnWithinDays, to: purchaseDate)
    }

    private var warrantyEndPreview: Date {
        Calendar.current.date(byAdding: .year, value: warrantyYears, to: purchaseDate) ?? purchaseDate
    }

    private func applyDefaults(for cat: ProductCategory) {
        let d = ProductCategory.defaults(for: cat)
        registrationRequired = d.registrationRequired
        registerWithinDays = d.registerWithinDays
        trackReturn = d.trackReturn
        returnWithinDays = d.returnWithinDays
        warrantyYears = d.warrantyYears
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

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        var item = ProductItem(
            name: trimmed,
            brand: brand,
            category: category,
            purchaseDate: purchaseDate,
            storeName: storeName,
            registrationRequired: registrationRequired,
            registerWithinDays: registerWithinDays,
            trackReturn: trackReturn,
            returnWithinDays: returnWithinDays,
            warrantyYears: warrantyYears,
            registrationURL: registrationURL,
            modelNumber: modelNumber,
            serialNumber: serialNumber,
            claimNotes: claimNotes
        )

        if let receiptImage {
            item.receiptImageFilename = ImageStore.save(receiptImage, for: item.id, kind: "receipt")
        }
        if let serialImage {
            item.serialImageFilename = ImageStore.save(serialImage, for: item.id, kind: "serial")
        }

        modelContext.insert(item)
        try? modelContext.save()
        NotificationScheduler.schedule(for: item)
        dismiss()
    }
}
