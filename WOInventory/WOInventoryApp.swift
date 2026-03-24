import SwiftUI

@main
struct WOInventoryApp: App {
    @StateObject private var viewModel = WorkOrderViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
