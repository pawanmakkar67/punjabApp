import SwiftUI

struct ReactionView: View {
    let onReactionSelected: (PostReaction) -> Void
    @State private var selectedReaction: PostReaction?
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(PostReaction.allCases) { reaction in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        selectedReaction = reaction
                    }
                    onReactionSelected(reaction)
                }) {
                    VStack(spacing: 2) {
                        Text(reaction.emoji)
                            .font(.system(size: selectedReaction == reaction ? 40 : 32))
                            .scaleEffect(selectedReaction == reaction ? 1.2 : 1.0)
                        
                        if selectedReaction == reaction {
                            Text(reaction.title)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(reaction.color)
                        }
                    }
                    .frame(width: 50, height: 60)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                scale = 1.0
            }
        }
    }
}

struct ReactionView_Previews: PreviewProvider {
    static var previews: some View {
        ReactionView { reaction in
            print("Selected: \(reaction.title)")
        }
        .padding()
        .background(Color.gray.opacity(0.2))
    }
}
