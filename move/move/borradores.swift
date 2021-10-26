//
//  borradores.swift
//  move
//
//  Created by Emmanuel Zambrano Quitian on 10/22/21.
//

import SwiftUI

struct ShowProg: View {
    var progreso:CGFloat
    var label:String
    var size:Double
    var rotation:Double
    
    var body: some View {
        ZStack {
            
            Circle()
                .trim(from: 0, to: size)
                .stroke(Color.gray.opacity(0.25),style: StrokeStyle(lineWidth: 31, lineCap: .round)).frame(width: 175, height: 175).rotationEffect(.init(degrees: Double(rotation)))
            Circle()
                .trim(from: 0, to: abs((progreso/10)*0.25))
                .stroke((progreso > 0) ? Color.red:Color.blue,style: StrokeStyle(lineWidth: 24, lineCap: .round))
                .frame(width: 175, height: 175).rotationEffect(.init(degrees: rotation))
            VStack{
                Text("\(progreso)").font(.title)
                Text(label).font(.title)
            }
            
            
            
        }
                
    }
}

struct borradores_Previews: PreviewProvider {
    static var previews: some View {
        ShowProg(progreso: -0.3, label: "X",size: 0.5,rotation: -180)
    }
}


