import SwiftUI

@Observable
class PathStore {
    var path: NavigationPath {
        didSet {
            savePath()
        }
    }
    
    private let pathToSave = URL.documentsDirectory.appending(path: "SavedPath")
    
    init() {
        if let data = try? Data(contentsOf: pathToSave) {
            if let decodedData = try? JSONDecoder().decode(NavigationPath.CodableRepresentation.self, from: data) {
                path = NavigationPath(decodedData)
                return
            }
        }
        path = NavigationPath()
    }
    
    func savePath() {
        guard let representation = path.codable else {
            return
        }
        do {
            let encodedData =  try JSONEncoder().encode(representation)
            try encodedData.write(to: pathToSave)
        } catch {
            print("Failed to save navigation data.")
        }
    }
}

struct HomeView: View {
    @State private var pathStore = PathStore()
    var body: some View {
        NavigationStack(path: $pathStore.path) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Welcome to Swift Widzards!")
                            .foregroundStyle(.black)
                            .font(.title.weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        HStack(spacing: 12) {
                            Button("About Swift") {
                                let swiftLanguage = SwiftLanguage(
                                    name: "Swift",
                                    version: "6.0.2",
                                    yearReleased: "2016",
                                    description: "A programming language that combines the power of Objective-C with the flexibility of C++."
                                )
                                pathStore.path.append(swiftLanguage)
                            }.buttonStyle(.borderedProminent)
                                .tint(.orange)
                                .foregroundStyle(.white)
                            Button("Basic Lessons") {
                                let swiftLessons = [
                                    SwiftLesson(title: "Hello, World!", description: "A basic Swift lesson that introduces the Swift programming language."),
                                    SwiftLesson(title: "Variables", description: "A basic Swift lesson that introduces variables."),
                                ]
                                pathStore.path.append(swiftLessons)
                            }.buttonStyle(.borderedProminent)
                                .tint(.black)
                                .foregroundStyle(.white)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }.frame(maxWidth: .infinity)
                }.padding(12)
            }.background(LinearGradient(gradient: Gradient(colors: [.red, .yellow]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .toolbar(.hidden)
                .navigationDestination(for: SwiftLanguage.self) { swiftLanguage in
                    AboutView(
                        swiftLanguage: swiftLanguage,
                        navigationPath: $pathStore.path
                    )
                }
                .navigationDestination(for: [SwiftLesson].self) {
                    swiftLessons in
                    LessonsView(
                        swiftLessons: swiftLessons,
                        navigationPath: $pathStore.path
                    )
                }
        }
    }
}

struct AboutView: View {
    let swiftLanguage: SwiftLanguage
    @Binding var navigationPath: NavigationPath
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                Text("\(swiftLanguage.name) (\(swiftLanguage.version))")
                Text(swiftLanguage.description)
            }.padding(20)
                .foregroundStyle(.white)
        }.background(LinearGradient(gradient: Gradient(colors: [.red, .yellow]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .navigationTitle("About Swift")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark)
            .toolbarBackground(.red)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button("Home") {
                        navigationPath = NavigationPath()
                    }.foregroundStyle(.white)
                }
            }
            .navigationBarBackButtonHidden()
    }
}

struct LessonsView: View {
    let swiftLessons: [SwiftLesson]
    @Binding var navigationPath: NavigationPath
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(swiftLessons, id: \.self.id) { swiftLesson in
                    NavigationLink {
                        VStack {
                            Text(swiftLesson.title)
                            Button("Home") {
                                navigationPath = NavigationPath()
                            }.buttonStyle(.borderedProminent)
                                .tint(.black)
                                .foregroundStyle(.white)
                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [.red, .yellow]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    } label : {
                        Text(swiftLesson.title)
                    }
                }.foregroundStyle(.white)
            }.padding(20)
        }.background(LinearGradient(gradient: Gradient(colors: [.red, .yellow]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .navigationTitle("Basic Lessons")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark)
            .toolbarBackground(.red)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button("Home") {
                        navigationPath = NavigationPath()
                    }.foregroundStyle(.white)
                }
            }
            .navigationBarBackButtonHidden()
    }
}

struct SwiftLanguage: Hashable, Codable {
    let name: String
    let version: String
    let yearReleased: String
    let description: String
}

struct SwiftLesson: Hashable, Codable {
    var id = UUID()
    let title: String
    let description: String
}

#Preview {
    HomeView()
}
