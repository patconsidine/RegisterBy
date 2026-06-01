import SwiftUI
import SwiftData

struct EditProductView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: ProductItem

    @State private var receiptImage: UIImage?
    @State private var serialImage: UIImage?

    var body: some View {
        Form {
            Section("Product") {
                TextField("Name", text: $item.name)
                TextField("Brand", text: $item.brand)
                Picker("Category", selection: Binding(
                    get: { item.category },
                    set: { item.category = $0 }
                )) {
                    ForEach(ProductCategory.allCases) { cat in
                        Text(cat.rawValue).tag(cat)
                    }
                }
            }
            Section("Dates") {
                DatePicker("Purchase", selection: $item.purchaseDate, displayedComponents: .date)
                TextField("Store (optional)", text: $item.storeName)
                Toggle("Registration required", isOn: $item.registrationRequired)
                if item.registrationRequired {
                    Stepper("Register within: \(item.registerWithinDays) days", value: $item.registerWithinDays, in: 1...365)
                }
                Toggle("Track return", isOn: $item.trackReturn)
                if item.trackReturn {
                    Stepper("Return within: \(item.returnWithinDays) days", value: $item.returnWithinDays, in: 1...365)
                }
                Stepper("Warranty: \(item.warrantyYears) years", value: $item.warrantyYears, in: 1...20)
                    .onChange(of: item.warrantyYears) { _, _ in item.recomputeWarrantyEnd() }
                    .onChange(of: item.purchaseDate) { _, _ in item.recomputeWarrantyEnd() }
            }
            Section("Links & notes") {
                TextField("Registration URL", text: $item.registrationURL)
                    .textInputAutocapitalization(.never)
                TextField("Model", text: $item.modelNumber)
                TextField("Serial", text: $item.serialNumber)
                TextField("Claim notes", text: $item.claimNotes, axis: .vertical)
            }
            ProductPhotosFormSection(receiptImage: $receiptImage, serialImage: $serialImage)
        }
        .navigationTitle("Edit")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            receiptImage = ImageStore.load(filename: item.receiptImageFilename)
            serialImage = ImageStore.load(filename: item.serialImageFilename)
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    item.updatedAt = .now
                    item.recomputeWarrantyEnd()
                    ProductPhotoPersistence.saveReceipt(receiptImage, for: item)
                    ProductPhotoPersistence.saveSerial(serialImage, for: item)
                    try? modelContext.save()
                    NotificationScheduler.schedule(for: item)
                    dismiss()
                }
            }
        }
    }
}
