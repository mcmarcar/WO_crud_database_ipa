import Foundation

enum CSVParser {
    // Parses pipe-delimited CSV with header row.
    // Column order: RANGE|NUM|PLAN_START_DATE|LOCATION_DATE|LOCATION|ITEM_NUMBER|
    //               1ST_DESCRIPTION|2ND_DESCRIPTION|ITEM_SIZE|QUANTITY_ON_HAND|
    //               ON_ORDER|NOTES|PRICE
    static func parse(_ content: String) -> [WorkOrder] {
        var results: [WorkOrder] = []
        let lines = content.components(separatedBy: .newlines)

        for line in lines.dropFirst() {       // skip header
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            let f = trimmed.components(separatedBy: "|")
            guard f.count >= 11 else { continue }

            results.append(WorkOrder(
                id:               0,
                range:            f[0],
                num:              f[1],
                planStartDate:    f[2],
                locationDate:     f[3],
                location:         f[4],
                itemNumber:       f[5],
                firstDescription: f[6],
                secondDescription:f[7],
                itemSize:         f[8],
                quantityOnHand:   f[9],
                notes:            f.count > 11 ? f[11] : "",   // col 11 = NOTES
                onOrder:          f[10],                        // col 10 = ON_ORDER
                price:            f.count > 12 ? f[12] : ""
            ))
        }
        return results
    }
}
