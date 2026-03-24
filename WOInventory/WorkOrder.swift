import Foundation

struct WorkOrder: Identifiable, Equatable, Hashable {
    var id: Int64
    var range: String
    var num: String
    var planStartDate: String
    var locationDate: String
    var location: String
    var itemNumber: String
    var firstDescription: String
    var secondDescription: String
    var itemSize: String
    var quantityOnHand: String
    var notes: String
    var onOrder: String
    var price: String

    static let empty = WorkOrder(
        id: 0, range: "", num: "", planStartDate: "", locationDate: "",
        location: "", itemNumber: "", firstDescription: "", secondDescription: "",
        itemSize: "", quantityOnHand: "", notes: "", onOrder: "", price: ""
    )

    // Column key matches the SQLite column name
    static let sortFields: [(key: String, label: String)] = [
        ("range",              "Range"),
        ("num",                "Num"),
        ("plan_start_date",    "Plan Start Date"),
        ("location_date",      "Location Date"),
        ("location",           "Location"),
        ("item_number",        "Item Number"),
        ("first_description",  "1st Description"),
        ("second_description", "2nd Description"),
        ("item_size",          "Item Size"),
        ("quantity_on_hand",   "Qty On Hand"),
        ("notes",              "Notes"),
        ("on_order",           "On Order"),
        ("price",              "Price")
    ]

    func value(for key: String) -> String {
        switch key {
        case "range":              return range
        case "num":                return num
        case "plan_start_date":    return planStartDate
        case "location_date":      return locationDate
        case "location":           return location
        case "item_number":        return itemNumber
        case "first_description":  return firstDescription
        case "second_description": return secondDescription
        case "item_size":          return itemSize
        case "quantity_on_hand":   return quantityOnHand
        case "notes":              return notes
        case "on_order":           return onOrder
        case "price":              return price
        default:                   return ""
        }
    }
}
