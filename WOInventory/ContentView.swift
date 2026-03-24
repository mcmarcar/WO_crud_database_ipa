import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: WorkOrderViewModel

    @State private var showAddForm        = false
    @State private var workOrderToEdit:   WorkOrder? = nil
    @State private var showDeleteAllAlert = false
    @State private var selectedSortIndex  = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                sortBar
                mainContent
            }
            .navigationTitle("WO Inventory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.appPrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .searchable(text: $viewModel.searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search all fields…")
            .toolbar { toolbarItems }
            .sheet(isPresented: $showAddForm) {
                WorkOrderFormView(mode: .add)
            }
            .sheet(item: $workOrderToEdit) { wo in
                WorkOrderFormView(mode: .edit(wo))
            }
            .alert("Delete All Records?", isPresented: $showDeleteAllAlert) {
                Button("Delete All", role: .destructive) { viewModel.deleteAll() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all \(viewModel.totalCount) work order records.")
            }
        }
    }

    // MARK: - Sort bar

    private var sortBar: some View {
        HStack(spacing: 8) {
            Text("Sort by")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))

            Picker("Sort", selection: $selectedSortIndex) {
                ForEach(WorkOrder.sortFields.indices, id: \.self) { i in
                    Text(WorkOrder.sortFields[i].label).tag(i)
                }
            }
            .pickerStyle(.menu)
            .tint(.white)
            .onChange(of: selectedSortIndex) { _, idx in
                viewModel.sortFieldKey = WorkOrder.sortFields[idx].key
            }

            Spacer()

            Text("\(viewModel.totalCount) records")
                .font(.caption.weight(.medium))
                .foregroundColor(.white.opacity(0.85))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.appPrimaryDark)
    }

    // MARK: - Main content

    @ViewBuilder
    private var mainContent: some View {
        if viewModel.isLoading {
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.4)
                Text("Loading inventory data…")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.workOrders.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.workOrders) { wo in
                        WorkOrderRowView(
                            workOrder: wo,
                            sortField: viewModel.sortFieldKey,
                            onEdit:   { workOrderToEdit = wo },
                            onDelete: { viewModel.delete(wo) }
                        )
                        .padding(.horizontal, 12)
                    }
                }
                .padding(.vertical, 10)
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: viewModel.searchText.isEmpty ? "tray" : "magnifyingglass")
                .font(.system(size: 52))
                .foregroundColor(.secondary)
            Text(viewModel.searchText.isEmpty ? "No Work Orders" : "No Results")
                .font(.title3.weight(.semibold))
            Text(viewModel.searchText.isEmpty
                 ? "Tap + to add a new work order."
                 : "No records match "\(viewModel.searchText)".")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button { showAddForm = true } label: {
                Image(systemName: "plus")
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button { showDeleteAllAlert = true } label: {
                Image(systemName: "trash")
            }
            .disabled(viewModel.totalCount == 0)
        }
    }
}
