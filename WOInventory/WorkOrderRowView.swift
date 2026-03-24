import SwiftUI

struct WorkOrderRowView: View {
    let workOrder: WorkOrder
    let sortField: String
    let onEdit:   () -> Void
    let onDelete: () -> Void

    @State private var showDeleteAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Two-column field grid
            let columns = [GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, alignment: .leading, spacing: 6) {
                ForEach(WorkOrder.sortFields, id: \.key) { field in
                    fieldCell(label: field.label,
                              value: workOrder.value(for: field.key),
                              highlighted: field.key == sortField)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
            .padding(.bottom, 8)

            Divider()

            // Action buttons
            HStack {
                Button {
                    onEdit()
                } label: {
                    Label("Edit", systemImage: "pencil")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.appPrimary)
                }
                .buttonStyle(.plain)

                Spacer()

                Button {
                    showDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        .alert("Delete Record?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) { onDelete() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Remove \"\(workOrder.firstDescription)\"?")
        }
    }

    @ViewBuilder
    private func fieldCell(label: String, value: String, highlighted: Bool) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(highlighted ? .sortHighlightText : .secondary)
                .textCase(.uppercase)
                .lineLimit(1)

            Text(value.isEmpty ? "—" : value)
                .font(.system(size: 13))
                .foregroundColor(highlighted ? .sortHighlightText : .primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(highlighted ? Color.sortHighlight : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
