import Foundation

enum FilterType: String, CaseIterable, Identifiable {
    case nose, glasses, beard
    
    var id: String { rawValue }
}

struct Filter: Identifiable {
    let id = UUID()
    let imageName: String
    let type: FilterType
}
