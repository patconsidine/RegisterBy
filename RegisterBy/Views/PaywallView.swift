import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchases: PurchaseManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                Image(systemName: "infinity.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.tint)
                Text("Track every warranty.\nPay once.")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                VStack(alignment: .leading, spacing: 12) {
                    labelRow("Unlimited products")
                    labelRow("All reminder types")
                    labelRow("No subscription — ever")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 32)

                if let product = purchases.product {
                    Text(product.displayPrice)
                        .font(.title.bold())
                } else {
                    Text("$6.99")
                        .font(.title.bold())
                }

                Button {
                    Task {
                        if await purchases.purchase() {
                            dismiss()
                        }
                    }
                } label: {
                    if purchases.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Unlock RegisterBy Pro")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal)

                Button("Restore purchases") {
                    Task { await purchases.restore() }
                }
                .font(.footnote)

                Button("Not now") { dismiss() }
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                if let error = purchases.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                Spacer()
            }
            .navigationTitle("RegisterBy Pro")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await purchases.loadProduct()
            }
        }
    }

    private func labelRow(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(text)
        }
    }
}
