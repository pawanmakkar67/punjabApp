//
//  CustomDatePicker.swift
//  PunjabAppNew
//
//  Created by pc on 03/11/25.
//


import SwiftUI
struct CustomDatePicker: View {
    var placeholder: String
    @Binding var selectedDateString: String

    @State private var selectedDate = Date()
    @State private var showPicker = false

    // ❗ Set max date = today - 18 years
    private var maxDate: Date {
        Calendar.current.date(byAdding: .year, value: -14, to: Date())!
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation {
                    showPicker.toggle()
                }
            } label: {
                HStack {
                    Text(selectedDateString.isEmpty ? placeholder : convertDateString(selectedDateString))
                        .foregroundColor(selectedDateString.isEmpty ? .gray : .primary)
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }

            if showPicker {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    in: ...maxDate,   // 👈 LIMIT DATE HERE
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding(.horizontal)
                .onChange(of: selectedDate) { newValue in
                    selectedDateString = formatDate(newValue)
                }
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    func convertDateString(_ input: String,
                           fromFormat: String = "yyyy-MM-dd",
                           toFormat: String = "MMM dd, yyyy") -> String {

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        formatter.dateFormat = fromFormat
        guard let date = formatter.date(from: input) else { return input }

        formatter.dateFormat = toFormat
        return formatter.string(from: date)
    }
}
