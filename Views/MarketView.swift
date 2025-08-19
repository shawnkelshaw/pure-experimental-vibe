import SwiftUI

struct MarketView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 64, weight: .light))
                    .foregroundColor(.secondary)
                
                VStack(spacing: 8) {
                    Text("Market Data")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Coming Soon")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Market")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct MarketView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MarketView()
        }
    }
}