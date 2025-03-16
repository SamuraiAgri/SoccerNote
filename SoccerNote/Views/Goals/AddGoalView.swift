import SwiftUI
import CoreData

struct AddGoalView: View {
    @Environment(\.presentationMode) var presentationMode
    let goalViewModel: GoalViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var deadline = Date().addingTimeInterval(60*60*24*30) // 30日後
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("目標情報")) {
                    TextField("タイトル", text: $title)
                    
                    TextField("詳細", text: $description)
                        .frame(height: 100)
                    
                    DatePicker("期限", selection: $deadline, displayedComponents: .date)
                }
                
                Section {
                    Button(action: saveGoal) {
                        Text("目標を保存")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(AppDesign.primaryColor)
                            .cornerRadius(AppDesign.CornerRadius.medium)
                    }
                    .disabled(title.isEmpty)
                }
            }
            .navigationTitle("目標追加")
            .navigationBarItems(trailing: Button("キャンセル") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    // 目標保存
    private func saveGoal() {
        goalViewModel.saveGoal(
            title: title,
            description: description,
            deadline: deadline
        )
        
        presentationMode.wrappedValue.dismiss()
    }
}
