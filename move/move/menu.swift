//
//  menu.swift
//  move
//
//  Created by Emmanuel Zambrano Quitian on 10/23/21.
//

import SwiftUI
struct menu: View {
    @StateObject var settings = classtime()
    @State var timeS:String = "3"
    @State var myStrings: [String] = []
    var body: some View {
            TabView {
                NavigationView{
                    ContentView(timeS: timeS)
                        .navigationTitle("Aceleration")
                        .navigationBarItems(trailing:
                                                Button(action: {
                                                    print("boton")
                                                }, label: {
                                                    TextField("S", text: $timeS,onCommit:  {settings.amont = timeS}).background(Color.gray.opacity(0.10)).frame(width: 50, height: 35)
                                                })
                        )
                }.environmentObject(settings)
                .navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Label("Menu", systemImage: "gyroscope")
                }
                NavigationView{
                    actions(myStrings:myStrings).navigationTitle("Speak")
                }.navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Label("Menu", systemImage: "ear.and.waveform")
                }
                NavigationView{
                    motions(myStrings:myStrings,sentence: myStrings).navigationTitle("Motion")
                }.navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Label("Motion", systemImage: "hand.wave")
                }

            }.onAppear{
                
                if let path = Bundle.main.path(forResource: "labels", ofType: "txt") {
                    do {
                        let data = try String(contentsOfFile: path, encoding: .utf8)
                        myStrings = data.components(separatedBy: .newlines)
                        print("path: \(path)")
                        print("fin del path")
                        
                    } catch {
                        print(error)
                    }
                }
            }
        
    }
}
class classtime: ObservableObject {
    @Published var amont = "3"
}

struct menu_Previews: PreviewProvider {
    static var previews: some View {
        menu()
    }
}
