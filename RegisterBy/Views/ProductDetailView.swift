import SwiftUI
import SwiftData

struct ProductDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: ProductItem

    @State private var showMarkRegistered = false
    @State private var registeredDate = Date.now
    @State private var showDeleteConfirm = false
    @State private var brandRegion: BrandRegion = .current

    var body: some View {
        List {
            statusSection
            timelineSection
            photosSection
            claimSection
            actionsSection
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink("Edit") {
                    EditProductView(item: item)
                }
            }
        }
        .sheet(isPresented: $showMarkRegistered) {
            markRegisteredSheet
        }
        .confirmationDialog("Delete product?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { deleteItem() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes \(item.name) and saved photos.")
        }
    }

    @ViewBuilder
    private var statusSection: some View {
        Section {
            HStack {
                Image(systemName: item.category.iconName)
                    .font(.title)
                    .foregroundStyle(.tint)
                VStack(alignment: .leading, spacing: 4) {
                    Text(statusTitle)
                        .font(.headline)
                    Text(statusSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            if item.registrationRequired, item.registeredAt == nil {
                Button("Mark as registered") {
                    showMarkRegistered = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private var timelineSection: some View {
        Section("Timeline") {
            timelineRow(label: "Purchase", date: item.purchaseDate)
            if item.registrationRequired, let reg = item.registerByDate {
                timelineRow(label: item.registeredAt == nil ? "Register by" : "Registered", date: item.registeredAt ?? reg)
                if item.registeredAt == nil, !item.registrationURL.isEmpty, let url = URL(string: item.registrationURL) {
                    Link("Open registration page", destination: url)
                }
            }
            if item.trackReturn, let ret = item.returnByDate {
                timelineRow(label: "Return ends", date: ret)
            }
            timelineRow(label: "Warranty ends", date: item.warrantyEndDate)
        }
    }

    private var photosSection: some View {
        Section("Photos") {
            photoRow(title: "Receipt", filename: item.receiptImageFilename)
            photoRow(title: "Serial plate", filename: item.serialImageFilename)
        }
    }

    private var claimSection: some View {
        Section("Claim info") {
            if !item.modelNumber.isEmpty {
                LabeledContent("Model", value: item.modelNumber)
            }
            if !item.serialNumber.isEmpty {
                LabeledContent("Serial", value: item.serialNumber)
            }
            if !item.claimNotes.isEmpty {
                Text(item.claimNotes)
                    .font(.body)
            }
            if item.modelNumber.isEmpty, item.serialNumber.isEmpty, item.claimNotes.isEmpty {
                Text("Add details in Edit")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var actionsSection: some View {
        Section {
            if item.isArchived {
                Button("Restore to active") {
                    item.isArchived = false
                    item.updatedAt = .now
                    saveAndReschedule()
                }
            } else {
                Button("Archive") {
                    item.isArchived = true
                    item.updatedAt = .now
                    saveAndReschedule()
                    dismiss()
                }
            }
            Button("Delete", role: .destructive) {
                showDeleteConfirm = true
            }
        }
    }

    private var markRegisteredSheet: some View {
        NavigationStack {
            Form {
                DatePicker("Registered on", selection: $registeredDate, displayedComponents: .date)
            }
            .navigationTitle("Mark registered")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showMarkRegistered = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        item.registeredAt = registeredDate
                        item.updatedAt = .now
                        saveAndReschedule()
                        showMarkRegistered = false
                        AppReview.recordMarkRegisteredAndMaybeRequestReview()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func timelineRow(label: String, date: Date) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(date.formatted(date: .abbreviated, time: .omitted))
                .foregroundStyle(.secondary)
        }
    }

    private func photoRow(title: String, filename: String?) -> some View {
        HStack {
            Text(title)
            Spacer()
            if let filename, let image = ImageStore.load(filename: filename) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Text("None")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var statusTitle: String {
        switch item.status {
        case .registerOverdue: return "Registration overdue"
        case .registerSoon: return "Register soon"
        case .registered: return "Registered"
        case .returnEnding: return "Return window ending"
        case .expiringSoon: return "Warranty expiring soon"
        case .expired: return "Warranty expired"
        case .active: return "Active"
        }
    }

    private var statusSubtitle: String {
        if let reg = item.registerByDate, item.registeredAt == nil {
            return "Register by \(reg.formatted(date: .abbreviated, time: .omitted))"
        }
        if let reg = item.registeredAt {
            return "Registered \(reg.formatted(date: .abbreviated, time: .omitted))"
        }
        return item.brand.isEmpty ? item.category.rawValue : item.brand
    }

    private func saveAndReschedule() {
        try? modelContext.save()
        NotificationScheduler.schedule(for: item)
    }

    private func deleteItem() {
        ImageStore.delete(filename: item.receiptImageFilename)
        ImageStore.delete(filename: item.serialImageFilename)
        modelContext.delete(item)
        try? modelContext.save()
        dismiss()
    }
}
