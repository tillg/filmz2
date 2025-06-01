import SwiftUI

/// A flexible layout that wraps content to multiple lines
/// Used by pill components and other UI elements that need flexible wrapping
struct FlexibleLayout: Layout {
    let spacing: CGFloat
    
    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return layout(sizes: sizes, in: proposal.width ?? 0).size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let positions = layout(sizes: sizes, in: bounds.width).positions
        
        for (index, subview) in subviews.enumerated() {
            if index < positions.count {
                let position = CGPoint(
                    x: bounds.minX + positions[index].x,
                    y: bounds.minY + positions[index].y
                )
                subview.place(at: position, anchor: .topLeading, proposal: .unspecified)
            }
        }
    }
    
    private func layout(sizes: [CGSize], in width: CGFloat) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var currentRowY: CGFloat = 0
        var currentRowX: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        
        for size in sizes {
            if currentRowX + size.width > width && currentRowX > 0 {
                // Move to next row
                currentRowY += currentRowHeight + spacing
                currentRowX = 0
                currentRowHeight = 0
            }
            
            positions.append(CGPoint(x: currentRowX, y: currentRowY))
            currentRowX += size.width + spacing
            currentRowHeight = max(currentRowHeight, size.height)
            totalHeight = currentRowY + currentRowHeight
        }
        
        return (
            size: CGSize(width: width, height: totalHeight),
            positions: positions
        )
    }
}

// MARK: - Preview

#Preview("Flexible Layout") {
    let items = ["Short", "Medium Length", "Very Long Text Item", "Another", "Item", "Last One"]
    
    VStack(spacing: 20) {
        Text("Flexible Layout Demo")
            .font(.headline)
        
        FlexibleLayout(spacing: 8) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    .padding()
}