import Foundation
import SwiftData

@MainActor
class DataController {
    static let accountNameExamples = ["Banco do Brasil", "Maya Trust", "Feijão Bank"]
    static let transactionNameExamples = ["Almoço", "Jantar", "Mansão"]
    static let accountCurrencyExamples = ["R$", "元", "US$"]

    static func createRandomAccount() -> Account {
        Account(name: accountNameExamples.randomElement()!,
                color: NiceColor.allCases.randomElement()!.rawValue,
                currency: accountCurrencyExamples.randomElement()!)
    }

    static let previewContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Account.self, configurations: config)

            let accounts = accountNameExamples.map {
                Account(
                    name: $0,
                    color: NiceColor.allCases.randomElement()!.rawValue,
                    currency: accountCurrencyExamples.randomElement()!)
            }
            accounts.forEach { container.mainContext.insert($0) }
            try container.mainContext.save()
            transactionNameExamples.forEach {
                let transaction = Transaction(
                    id: .init(),
                    name: $0,
                    value: Double((0...99999).randomElement()!) / 100,
                    account: accounts.randomElement()!,
                    date: Date(),
                    type: .adjustment,
                    place: nil)
                container.mainContext.insert(transaction)
            }

            try container.mainContext.save()
            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()
}