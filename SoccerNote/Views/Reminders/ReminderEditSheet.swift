// SoccerNote/Views/Reminders/ReminderEditSheet.swift
import SwiftUI
import CoreData

struct ReminderEditSheet: View {
    @Binding var isPresented: Bool
    let activity: NSManagedObject
    @Binding var reminderTime: Date
    @Binding var hasReminder: Bool
    
    @State private var tempReminderTime: Date
    @State private var showError = false
    @State private var errorMessage = ""
    
    init(isPresented: Binding<Bool>, activity: NSManagedObject, reminderTime: Binding<Date>, hasReminder: Binding<Bool>) {
        self._isPresented = isPresented
        self.activity = activity
        self._reminderTime = reminderTime
        self._hasReminder = hasReminder
        self._tempReminderTime = State(initialValue: reminderTime.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("リマインダー時間")) {
                    DatePicker("", selection: $tempReminderTime)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                }
                
                Section {
                    Button(action: saveReminder) {
                        Text("リマインダーを設定")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                            .padding()
                            .background(AppDesign.primaryColor)
                            .cornerRadius(8)
                    }
                    
                    if hasReminder {
                        Button(action: cancelReminder) {
                            Text("リマインダーを削除")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .navigationTitle("リマインダー設定")
            .navigationBarItems(trailing: Button("キャンセル") {
                isPresented = false
            })
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("エラー"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    // リマインダーの設定
    private func saveReminder() {
        if tempReminderTime < Date() {
            showError = true
            errorMessage = "過去の時間を指定することはできません。"
            return
        }
        
        if let activityDate = activity.value(forKey: "date") as? Date, tempReminderTime > activityDate {
            showError = true
            errorMessage = "リマインダー時間は活動時間より前である必要があります。"
            return
        }
        
        // リマインダーを設定
        ReminderManager.shared.scheduleReminder(for: activity, at: tempReminderTime) { error in
            DispatchQueue.main.async {
                if let error = error {
                    showError = true
                    errorMessage = error.localizedDescription
                } else {
                    reminderTime = tempReminderTime
                    hasReminder = true
                    isPresented = false
                }
            }
        }
    }
    
    // リマインダーの削除
    private func cancelReminder() {
        guard let id = activity.value(forKey: "id") as? UUID else {
            return
        }
        
        ReminderManager.shared.cancelReminder(for: id)
        hasReminder = false
        isPresented = false
    }
}
