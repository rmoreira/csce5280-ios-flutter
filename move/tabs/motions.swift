//
//  motions.swift
//  move
//
//  Created by Emmanuel Zambrano Quitian on 10/25/21.
//

import SwiftUI

struct motions: View {
    let defaults = UserDefaults.standard
    @State var myStrings: [String]
    @State var sentence:[String]
    var body: some View {
        VStack{
            ScrollView{
                
                ForEach(0..<myStrings.count) { i in
                    RectangleMotions(Icon: "arrow.counterclockwise", name: myStrings[i], sentence: $sentence[i]).padding(5)
                        }
            }

            
            
        }.onAppear{
            sentence = defaults.object(forKey:"SavedArray") as? [String] ?? myStrings
            
        }
        .onTapGesture { hideKeyboardAndSave() }
        
    }
    private func hideKeyboardAndSave() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
 
            defaults.set(sentence, forKey: "SavedArray")
        }
    
}

struct motions_Previews: PreviewProvider {
    static var previews: some View {
        motions(myStrings: ["hi"],sentence: ["hi"])
    }
}

struct RectangleMotions: View {
    var Icon:String
    var name:String
    @Binding var sentence:String
    var body: some View {
        Rectangle().fill(Color.blue)
            .cornerRadius(15)
            .overlay(
                HStack{
                    VStack{
                        Image(systemName: Icon)
                            .resizable().frame(width: 50, height: 50)
                            .padding()
                            
                        Text(name).font(.title).frame(width: 150)
                    }
                    TextEditor(text: $sentence).frame(height: 140).background(Color.white).cornerRadius(15)
                        .multilineTextAlignment(.leading).font(.system(size: 25))
                }.padding()
            )
            .frame(height: 160)
            .shadow(radius: 5)
            
            
    }
    
    
}
