//
//  NavStackView.swift
//  Brief
//
//  Created by Rachel Radford on 3/2/25.
//

import SwiftUI
import SwiftData

struct NavStackView: View {
    @Environment(\.modelContext) var context
    @Environment(\.colorScheme) var colorScheme
    @State private var articlePath = NavigationPath()
    @State private var text: String = ""
    @State private var title: String = ""
    @State var showNotes: Bool = false
    @Binding var editNote: Bool
    @Bindable var articleVM: ArticleViewModel = .shared
    @Query var articles: [ArticleModel]
    @Query var notes: [NoteModel]
    var articleManager: SharedArticleManager
    
    init(
        editNote: Binding<Bool> = .constant(false),
        articleManager: SharedArticleManager,
        noteTitle: Binding<String> = .constant(""),
        noteText: Binding<String> = .constant("")
    ) {
        self._editNote = editNote   
        self.articleManager = articleManager
    }
    
    var body: some View {
        navStackView
    }
}

extension NavStackView {
    
    var navStackView: some View {
        VStack(alignment: .leading) {
            
            toggleView
            
            HStack {
                NavigationStack(path: $articlePath) {
                    NavListView(showNotes: $showNotes, articleManager: articleManager)
                        .navigationTitle(navTitleView)
                        .navigationDestination(for: ArticleModel.self) { article in
                            if !showNotes {
                                
                                navDestinationFromList(article: article)
                                
                            } else if showNotes, let note = article.note {
                                CurrentNoteView(editNote: editNote, note: note)
                                    
                            }
                            else {
                                CreateNoteView(title: $title, text: $text, note: article.note ?? NoteModel(), article: article)
                            }
                           
                        }
                        .navigationDestination(for: UUID.self) { articleID in
                            if let article = articles.first(where: { $0.id == articleID }) {
                                navDestinationFromSiri(article: article)
                            } else {
                                Text("Article not found")
                            }
                        }
                        .navigationDestination(for: NoteModel.self) { note in
                               CurrentNoteView(editNote: editNote, note: note)
                           }
                        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("OpenNoteByIDNotification"))) { notification in
                            onReceiveNote(notification: notification)
                        }
                        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("OpenArticleByIDNotification"))) { notification in
                            onReceive(notification: notification)
                        }
                }
                .tint(colorScheme == .dark ? Color.accentColor : .black)
                .onAppear {
                    Task {
                        articleVM.fetchData()
                    }
                }
            }
        }
    }
    
    var toggleView: some View {
        Toggle(toggleLabel, isOn: $showNotes)
            .font(.custom("BarlowCondensed-SemiBold", size: 20))
            .tint(.accentColor)
            .padding(.horizontal, 30)
            .padding(.top, 10)
    }
    
    var toggleLabel: String {
        String(showNotes ? "Notes" : "Articles")
    }
    
    var navTitleView: Text {
        Text(!showNotes ? "ARTICLES" : "NOTES")
            .font(.custom("Merriweather-SemiBold", size: 35).bold())
        // This is bad but I want to customize, may change later
    }
    
    func navDestinationFromList(article: ArticleModel) -> some View {
        ArticleView(articleManager: articleManager, url: article.url ?? articleManager.sharedURL!)
            .customToolbar(url: articleManager.sharedURL, buttons: [
                ("message", { articleVM.showShareSheet.toggle() }),
                ("briefcase.fill", { articleVM.getBriefed.toggle() }),
                ("trash.square", {
                    articleVM.deleteArticle(id: article.id, title: article.title, url: article.url!, read: article.read, dateSaved: article.dateSaved)
                    articlePath.removeLast()
                    
                })
            ])
            .sheet(isPresented: $articleVM.getBriefed) {
                    BriefView(article: article)
            }
    }
    
    func navDestinationFromSiri(article: ArticleModel) -> some View  {
        ArticleView(articleManager: articleManager, url: article.url ?? articleManager.sharedURL!)
            .customToolbar(url: articleManager.sharedURL, buttons: [
                ("message", { articleVM.showShareSheet.toggle() }),
                ("briefcase.fill", { articleVM.getBriefed.toggle() }),
                ("trash.square", {
                    articleVM.deleteArticle(id: article.id, title: article.title, url: article.url!, read: article.read, dateSaved: article.dateSaved)
                })
            ])
    }
    
    @MainActor
    func onReceive(notification: NotificationCenter.Publisher.Output) {
        if let articleID = notification.userInfo?["articleID"] as? UUID {
            print("ContentView received notification to open article with ID: \(articleID)")
            
            if articles.first(where: { $0.id == articleID }) != nil {
                articlePath.append(articleID)
            } else {
                for article in articles {
                    print("- \(article.id): \(article.title)")
                }
            }
        }
    }
    
    @MainActor
    func onReceiveNote(notification: NotificationCenter.Publisher.Output) {
        if let noteID = notification.userInfo?["noteID"] as? UUID {
            
            showNotes = true
            
            if let note = notes.first(where: { $0.id == noteID }) {

                if let articleWithNote = articles.first(where: { $0.note?.id == note.id }) {
                    articlePath.append(articleWithNote)
                } else {
                    articlePath.append(note)
                }
            } else {
                print("Note with ID \(noteID) not found - available notes:")
            }
        }
    }
}

