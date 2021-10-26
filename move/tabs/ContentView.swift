//
//  ContentView.swift
//  move
//
//  Created by Emmanuel Zambrano Quitian on 10/22/21.
//

import SwiftUI
import CoreMotion
struct ContentView: View {
    let motion = CMMotionManager()
    @State var x:Double = 0
    @State var y:Double = 0
    @State var z:Double = 0
    @State var Xarry:[Double] = []
    @State var Yarry:[Double] = []
    @State var Zarry:[Double] = []
    @State var time:Double = 3.0
    @State var timeS:String
    @EnvironmentObject var settings: classtime
    @State var stop:Bool = false //stop and start collecting data
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()//set sub timer, match sf
    let sf = 0.1//sample frequency
    var body: some View {
        ScrollView{
            if (motion.isDeviceMotionAvailable){// acelerometer aveilable
                    VStack{
                        ShowProg(progreso: CGFloat(x),label: "X",size: 0.5,rotation: -180).padding(.horizontal).padding(.top)
                        ShowProg(progreso: CGFloat(y),label: "Y",size: 0.5,rotation: -180)
                        ShowProg(progreso: CGFloat(z),label: "Z",size: 0.5,rotation: -180)
                        Button(action: {
                            time = Double(settings.amont) ?? 0
                            stop.toggle()
                            Xarry = []
                            Yarry = []
                            Zarry = []
                            if (stop){
                                motion.accelerometerUpdateInterval = sf// set sample frequency for  sensores
                                motion.startAccelerometerUpdates(to: .main) {
                                        (data, error) in
                                        guard let data = data, error == nil else {
                                            return
                                        }
                                    x = data.acceleration.x*10
                                    y = data.acceleration.y*10
                                    z = data.acceleration.z*10
                                }
                            }else{
                                motion.stopAccelerometerUpdates()
                            }
                        }, label: {
                            buttonPP(start: $stop)
                        })
                        
                    }//.environmentObject(settings)
            }else{
                Text("not Available")
            }
            
        }
        .onReceive(timer){ input in
            let n = Int(time/sf)
            
            if (Xarry.count==n){
                stop = false
                motion.stopAccelerometerUpdates()
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(timeS: "3")
    }
}
