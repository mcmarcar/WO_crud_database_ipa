import Foundation
import SQLite3

final class DatabaseManager {
    private var db: OpaquePointer?

    init() {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = dir.appendingPathComponent("wo_database.sqlite").path
        if sqlite3_open(path, &db) != SQLITE_OK {
            print("DB open error: \(dbError)")
        }
    }

    deinit { sqlite3_close(db) }

    // MARK: - Schema

    func createTable() {
        let sql = """
            CREATE TABLE IF NOT EXISTS work_orders (
                id                INTEGER PRIMARY KEY AUTOINCREMENT,
                range             TEXT NOT NULL DEFAULT '',
                num               TEXT NOT NULL DEFAULT '',
                plan_start_date   TEXT NOT NULL DEFAULT '',
                location_date     TEXT NOT NULL DEFAULT '',
                location          TEXT NOT NULL DEFAULT '',
                item_number       TEXT NOT NULL DEFAULT '',
                first_description TEXT NOT NULL DEFAULT '',
                second_description TEXT NOT NULL DEFAULT '',
                item_size         TEXT NOT NULL DEFAULT '',
                quantity_on_hand  TEXT NOT NULL DEFAULT '',
                notes             TEXT NOT NULL DEFAULT '',
                on_order          TEXT NOT NULL DEFAULT '',
                price             TEXT NOT NULL DEFAULT ''
            );
        """
        exec(sql)
    }

    // MARK: - Queries

    func count() -> Int {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        guard sqlite3_prepare_v2(db, "SELECT COUNT(*) FROM work_orders;", -1, &stmt, nil) == SQLITE_OK,
              sqlite3_step(stmt) == SQLITE_ROW
        else { return 0 }
        return Int(sqlite3_column_int(stmt, 0))
    }

    func fetchAll(sortBy column: String = "range", search: String = "") -> [WorkOrder] {
        let col = sanitize(column)
        var results: [WorkOrder] = []
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }

        if search.isEmpty {
            let sql = "SELECT * FROM work_orders ORDER BY \(col) ASC;"
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
        } else {
            let sql = """
                SELECT * FROM work_orders WHERE
                    range LIKE ? OR num LIKE ? OR plan_start_date LIKE ? OR
                    location_date LIKE ? OR location LIKE ? OR item_number LIKE ? OR
                    first_description LIKE ? OR second_description LIKE ? OR
                    item_size LIKE ? OR quantity_on_hand LIKE ? OR notes LIKE ? OR
                    on_order LIKE ? OR price LIKE ?
                ORDER BY \(col) ASC;
            """
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
            let pattern = "%\(search)%"
            for i in 1...13 {
                bind(stmt, Int32(i), text: pattern)
            }
        }

        while sqlite3_step(stmt) == SQLITE_ROW {
            results.append(row(stmt))
        }
        return results
    }

    // MARK: - Mutations

    func insert(_ wo: WorkOrder) {
        let sql = """
            INSERT INTO work_orders
                (range, num, plan_start_date, location_date, location,
                 item_number, first_description, second_description, item_size,
                 quantity_on_hand, notes, on_order, price)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?);
        """
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return }
        bindFields(stmt, wo)
        sqlite3_step(stmt)
    }

    func insertBatch(_ records: [WorkOrder]) {
        exec("BEGIN TRANSACTION;")
        records.forEach { insert($0) }
        exec("COMMIT;")
    }

    func update(_ wo: WorkOrder) {
        let sql = """
            UPDATE work_orders SET
                range=?, num=?, plan_start_date=?, location_date=?, location=?,
                item_number=?, first_description=?, second_description=?, item_size=?,
                quantity_on_hand=?, notes=?, on_order=?, price=?
            WHERE id=?;
        """
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return }
        bindFields(stmt, wo)
        sqlite3_bind_int64(stmt, 14, wo.id)
        sqlite3_step(stmt)
    }

    func delete(id: Int64) {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        guard sqlite3_prepare_v2(db, "DELETE FROM work_orders WHERE id=?;", -1, &stmt, nil) == SQLITE_OK else { return }
        sqlite3_bind_int64(stmt, 1, id)
        sqlite3_step(stmt)
    }

    func deleteAll() { exec("DELETE FROM work_orders;") }

    // MARK: - Helpers

    private func exec(_ sql: String) {
        var err: UnsafeMutablePointer<CChar>?
        if sqlite3_exec(db, sql, nil, nil, &err) != SQLITE_OK, let e = err {
            print("SQL error: \(String(cString: e))")
            sqlite3_free(err)
        }
    }

    private func bind(_ stmt: OpaquePointer?, _ idx: Int32, text: String) {
        sqlite3_bind_text(stmt, idx, (text as NSString).utf8String, -1, nil)
    }

    private func bindFields(_ stmt: OpaquePointer?, _ wo: WorkOrder) {
        let fields = [wo.range, wo.num, wo.planStartDate, wo.locationDate, wo.location,
                      wo.itemNumber, wo.firstDescription, wo.secondDescription, wo.itemSize,
                      wo.quantityOnHand, wo.notes, wo.onOrder, wo.price]
        for (i, f) in fields.enumerated() { bind(stmt, Int32(i + 1), text: f) }
    }

    private func row(_ stmt: OpaquePointer?) -> WorkOrder {
        func s(_ col: Int32) -> String {
            guard let p = sqlite3_column_text(stmt, col) else { return "" }
            return String(cString: p)
        }
        return WorkOrder(id: sqlite3_column_int64(stmt, 0),
                         range: s(1), num: s(2), planStartDate: s(3),
                         locationDate: s(4), location: s(5), itemNumber: s(6),
                         firstDescription: s(7), secondDescription: s(8),
                         itemSize: s(9), quantityOnHand: s(10),
                         notes: s(11), onOrder: s(12), price: s(13))
    }

    private func sanitize(_ name: String) -> String {
        let allowed: Set<String> = ["range","num","plan_start_date","location_date","location",
                                    "item_number","first_description","second_description",
                                    "item_size","quantity_on_hand","notes","on_order","price"]
        return allowed.contains(name) ? name : "range"
    }

    private var dbError: String {
        guard let msg = sqlite3_errmsg(db) else { return "unknown" }
        return String(cString: msg)
    }
}
