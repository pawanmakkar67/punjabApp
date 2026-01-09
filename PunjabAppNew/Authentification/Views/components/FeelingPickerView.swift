//
//  FeelingPickerView.swift
//  PunjabAppNew
//
//  Created by AutoAgent on 3/1/2026.
//

import SwiftUI

struct FeelingOption: Identifiable {
    let id = UUID()
    let emoji: String
    let name: String
}

struct FeelingPickerView: View {
    @Binding var selectedFeeling: String
    @Environment(\.dismiss) var dismiss
    
    let feelings: [FeelingOption] = [
        FeelingOption(emoji: "🙂", name: "Happy"),
        FeelingOption(emoji: "😍", name: "Loved"),
        FeelingOption(emoji: "😌", name: "Satisfied"),
        FeelingOption(emoji: "💪", name: "Strong"),
        FeelingOption(emoji: "😔", name: "Sad"),
        FeelingOption(emoji: "😜", name: "Crazy"),
        FeelingOption(emoji: "😫", name: "Tired"),
        FeelingOption(emoji: "😴", name: "Sleepy"),
        FeelingOption(emoji: "😕", name: "Confused"),
        FeelingOption(emoji: "😟", name: "Worried"),
        FeelingOption(emoji: "😠", name: "Angry"),
        FeelingOption(emoji: "😞", name: "Down"),
        FeelingOption(emoji: "😒", name: "Annoyed"),
        FeelingOption(emoji: "😲", name: "Shocked")
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(feelings) { feeling in
                        Button(action: {
                            selectedFeeling = "\(feeling.emoji) \(feeling.name)"
                            dismiss()
                        }) {
                            HStack {
                                Text(feeling.emoji)
                                    .font(.largeTitle)
                                Text(feeling.name)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.black)
                                Spacer()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    .background(Color.blue.opacity(0.05))
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("How are you feeling?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.black)
                    }
                }
            }
        }
    }
}

#Preview {
    FeelingPickerView(selectedFeeling: .constant(""))
}
