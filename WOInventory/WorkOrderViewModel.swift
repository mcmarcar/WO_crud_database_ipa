import Foundation
import Combine

@MainActor
final class WorkOrderViewModel: ObservableObject {
    @Published var workOrders: [WorkOrder] = []
    @Published var searchText:  String = ""
    @Published var sortFieldKey: String = WorkOrder.sortFields[0].key
    @Published var totalCount:  Int = 0
    @Published var isLoading:   Bool = false

    private let db = DatabaseManager()
    private var cancellables = Set<AnyCancellable>()

    init() {
        db.createTable()

        // React to search / sort changes
        Publishers.CombineLatest($searchText, $sortFieldKey)
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .sink { [weak self] search, sort in
                self?.load(search: search, sort: sort)
            }
            .store(in: &cancellables)

        seedIfNeeded()
    }

    // MARK: - Public interface

    func add(_ wo: WorkOrder)    { db.insert(wo);      reload() }
    func update(_ wo: WorkOrder) { db.update(wo);      reload() }
    func delete(_ wo: WorkOrder) { db.delete(id: wo.id); reload() }
    func deleteAll()             { db.deleteAll();     reload() }

    // MARK: - Private

    private func reload() { load(search: searchText, sort: sortFieldKey) }

    private func load(search: String, sort: String) {
        workOrders = db.fetchAll(sortBy: sort, search: search)
        totalCount = db.count()
    }

    private func seedIfNeeded() {
        guard db.count() == 0 else { load(search: "", sort: sortFieldKey); return }

        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            var records: [WorkOrder] = []
            if let url     = Bundle.main.url(forResource: "data", withExtension: "csv"),
               let content = try? String(contentsOf: url, encoding: .utf8) {
                records = CSVParser.parse(content)
            }
            self.db.insertBatch(records)
            DispatchQueue.main.async {
                self.load(search: "", sort: self.sortFieldKey)
                self.isLoading = false
            }
        }
    }
}
