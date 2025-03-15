// SoccerNote/Views/Records/ActivityDetailView.swift
import SwiftUI
import CoreData

struct ActivityDetailView: View {
    let activity: NSManagedObject
    
    @State private var showingEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.medium) {
                // ヘッダー
                HStack {
                    VStack(alignment: .leading) {
                        Text(activityTypeText)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(formattedDate)
                            .font(.subheadline)
                            .foregroundColor(AppDesign.secondaryText)
                    }
                    Spacer()
                                        
                                        // 評価スター
                                        HStack {
                                            ForEach(1...5, id: \.self) { index in
                                                Image(systemName: index <= (activity.value(forKey: "rating") as? Int ?? 0) ? AppIcons.Rating.starFill : AppIcons.Rating.star)
                                                    .foregroundColor(.yellow)
                                            }
                                        }
                                    }
                                    
                                    Divider()
                                    
                                    // 基本情報
                                    Group {
                                        DetailRow(title: "場所", value: activity.value(forKey: "location") as? String ?? "")
                                        
                                        DetailRow(title: "メモ", value: activity.value(forKey: "notes") as? String ?? "")
                                    }
                                    
                                    Divider()
                                    
                                    // 詳細情報（試合または練習）
                                    if let type = activity.value(forKey: "type") as? String, type == "match" {
                                        // 試合詳細を表示
                                        if let matchDetails = fetchMatchDetails() {
                                            Group {
                                                DetailRow(title: "対戦相手", value: matchDetails.value(forKey: "opponent") as? String ?? "")
                                                
                                                DetailRow(title: "スコア", value: matchDetails.value(forKey: "score") as? String ?? "")
                                                
                                                HStack {
                                                    VStack(alignment: .leading) {
                                                        Text("ゴール")
                                                            .font(.headline)
                                                        
                                                        Text("\(matchDetails.value(forKey: "goalsScored") as? Int ?? 0)")
                                                    }
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    
                                                    VStack(alignment: .leading) {
                                                        Text("アシスト")
                                                            .font(.headline)
                                                        
                                                        Text("\(matchDetails.value(forKey: "assists") as? Int ?? 0)")
                                                    }
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                }
                                                
                                                DetailRow(title: "出場時間", value: "\(matchDetails.value(forKey: "playingTime") as? Int ?? 0)分")
                                                
                                                DetailRow(title: "パフォーマンス評価", value: "\(matchDetails.value(forKey: "performance") as? Int ?? 0)/10")
                                            }
                                        }
                                    } else {
                                        // 練習詳細を表示
                                        if let practiceDetails = fetchPracticeDetails() {
                                            Group {
                                                DetailRow(title: "フォーカスエリア", value: practiceDetails.value(forKey: "focus") as? String ?? "")
                                                
                                                DetailRow(title: "練習時間", value: "\(practiceDetails.value(forKey: "duration") as? Int ?? 0)分")
                                                
                                                Text("練習強度")
                                                    .font(.headline)
                                                
                                                HStack {
                                                    ForEach(1...5, id: \.self) { index in
                                                        Image(systemName: index <= (practiceDetails.value(forKey: "intensity") as? Int ?? 0) ? AppIcons.Rating.circleFill : AppIcons.Rating.circle)
                                                            .foregroundColor(AppDesign.primaryColor)
                                                    }
                                                }
                                                
                                                DetailRow(title: "学んだこと", value: practiceDetails.value(forKey: "learnings") as? String ?? "")
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                            }
                            .navigationBarTitle("詳細", displayMode: .inline)
                            .navigationBarItems(trailing: Button("編集") {
                                showingEditSheet = true
                            })
                            .sheet(isPresented: $showingEditSheet) {
                                // 編集画面を表示
                                if let type = activity.value(forKey: "type") as? String, type == "match" {
                                    EditMatchView(activity: activity)
                                } else {
                                    EditPracticeView(activity: activity)
                                }
                            }
                        }
                        
                        // 試合詳細の取得
                        private func fetchMatchDetails() -> NSManagedObject? {
                            guard let id = activity.value(forKey: "id") as? UUID else { return nil }
                            
                            let request = NSFetchRequest<NSManagedObject>(entityName: "Match")
                            request.predicate = NSPredicate(format: "activity.id == %@", id as CVarArg)
                            request.fetchLimit = 1
                            
                            do {
                                let context = activity.managedObjectContext!
                                let results = try context.fetch(request)
                                return results.first
                            } catch {
                                print("試合詳細の取得に失敗: \(error)")
                                return nil
                            }
                        }
                        
                        // 練習詳細の取得
                        private func fetchPracticeDetails() -> NSManagedObject? {
                            guard let id = activity.value(forKey: "id") as? UUID else { return nil }
                            
                            let request = NSFetchRequest<NSManagedObject>(entityName: "Practice")
                            request.predicate = NSPredicate(format: "activity.id == %@", id as CVarArg)
                            request.fetchLimit = 1
                            
                            do {
                                let context = activity.managedObjectContext!
                                let results = try context.fetch(request)
                                return results.first
                            } catch {
                                print("練習詳細の取得に失敗: \(error)")
                                return nil
                            }
                        }
                        
                        // ヘルパープロパティ
                        private var activityTypeText: String {
                            let type = activity.value(forKey: "type") as? String ?? ""
                            return type == "match" ? "試合" : "練習"
                        }
                        
                        private var formattedDate: String {
                            let date = activity.value(forKey: "date") as? Date ?? Date()
                            let formatter = DateFormatter()
                            formatter.dateStyle = .long
                            formatter.timeStyle = .short
                            formatter.locale = Locale(identifier: "ja_JP")
                            return formatter.string(from: date)
                        }
                    }

                    #Preview {
                        let context = PersistenceController.preview.container.viewContext
                        let request = NSFetchRequest<NSManagedObject>(entityName: "Activity")
                        let activities = try! context.fetch(request)
                        return ActivityDetailView(activity: activities.first!)
                    }
