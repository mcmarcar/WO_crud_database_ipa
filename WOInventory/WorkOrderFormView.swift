import SwiftUI

enum FormMode {
    case add
    case edit(WorkOrder)
}

struct WorkOrderFormView: View {
    @EnvironmentObject var viewModel: WorkOrderViewModel
    @Environment(\.dismiss)  var dismiss

    let mode: FormMode

    @State private var range             = ""
    @State private var num               = ""
    @State private var planStartDate     = ""
    @State private var locationDate      = ""
    @State private var location          = ""
    @State private var itemNumber        = ""
    @State private var firstDescription  = ""
    @State private var secondDescription = ""
    @State private var itemSize          = ""
    @State private var quantityOnHand    = ""
    @State private var notes             = ""
    @State private var onOrder           = ""
    @State private var price             = ""

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Work Order") {
                    field("Range",          text: $range)
                    field("Num",            text: $num)
                    field("Plan Start Date",text: $planStartDate, placeholder: "e.g. 5/13/2024")
                    field("Location Date",  text: $locationDate)
                    field("Location",       text: $location)
                }

                Section("Item") {
                    field("Item Number",     text: $itemNumber)
                    field("1st Description", text: $firstDescription)
                    field("2nd Description", text: $secondDescription)
                    field("Item Size",       text: $itemSize, placeholder: "e.g. #1 G")
                }

                Section("Inventory") {
                    field("Qty On Hand",text: $quantityOnHand, keyboardType: .numberPad)
                    field("On Order",   text: $onOrder,        keyboardType: .numberPad)
                    field("Price",      text: $price,          keyboardType: .decimalPad)
                }

                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isEditing ? "Edit Work Order" : "New Work Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(firstDescription.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { populateIfEditing() }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func field(_ label: String,
                       text: Binding<String>,
                       placeholder: String? = nil,
                       keyboardType: UIKeyboardType = .default) -> some View {
        LabeledContent(label) {
            TextField(placeholder ?? label, text: text)
                .multilineTextAlignment(.trailing)
                .keyboardType(keyboardType)
        }
    }

    private func populateIfEditing() {
        if case .edit(let wo) = mode {
            range             = wo.range
            num               = wo.num
            planStartDate     = wo.planStartDate
            locationDate      = wo.locationDate
            location          = wo.location
            itemNumber        = wo.itemNumber
            firstDescription  = wo.firstDescription
            secondDescription = wo.secondDescription
            itemSize          = wo.itemSize
            quantityOnHand    = wo.quantityOnHand
            notes             = wo.notes
            onOrder           = wo.onOrder
            price             = wo.price
        }
    }

    private func save() {
        let wo = WorkOrder(
            id:               isEditing ? editingID : 0,
            range:            range,
            num:              num,
            planStartDate:    planStartDate,
            locationDate:     locationDate,
            location:         location,
            itemNumber:       itemNumber,
            firstDescription: firstDescription,
            secondDescription:secondDescription,
            itemSize:         itemSize,
            quantityOnHand:   quantityOnHand,
            notes:            notes,
            onOrder:          onOrder,
            price:            price
        )
        if isEditing { viewModel.update(wo) } else { viewModel.add(wo) }
        dismiss()
    }

    private var editingID: Int64 {
        if case .edit(let wo) = mode { return wo.id }
        return 0
    }
}
