import SwiftUI

// MARK: - 리뷰 작성 화면
struct ReviewWriteView: View {
    let restaurant: Restaurant
    let onSubmit: (Double, String, [String]) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var rating: Double = 5.0
    @State private var content = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 맛집 정보
                HStack {
                    VStack(alignment: .leading) {
                        Text(restaurant.name)
                            .font(.headline)
                        Text(restaurant.category.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.3))
                .cornerRadius(12)
                
                // 별점 선택
                VStack(alignment: .leading, spacing: 12) {
                    Text("별점")
                        .font(.headline)
                    
                    HStack {
                        ForEach(1...5, id: \.self) { index in
                            Button {
                                rating = Double(index)
                            } label: {
                                Image(systemName: index <= Int(rating) ? "star.fill" : "star")
                                    .font(.title2)
                                    .foregroundColor(.yellow)
                            }
                        }
                        
                        Spacer()
                    }
                }
                
                // 리뷰 내용
                VStack(alignment: .leading, spacing: 12) {
                    Text("리뷰")
                        .font(.headline)
                    
                    TextEditor(text: $content)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(Color(.systemGray6).opacity(0.3))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("리뷰 작성")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        onSubmit(rating, content, [])
                        dismiss()
                    }
                    .disabled(content.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
