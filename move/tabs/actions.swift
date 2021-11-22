//
//  actions.swift
//  move
//
//  Created by Emmanuel Zambrano Quitian on 10/23/21.
//

import SwiftUI
import AVFoundation
import CoreMotion
import TensorFlowLite

extension FileManager {
    func documentDirectory() -> URL {
        return self.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
import Foundation

// Source: https://stackoverflow.com/questions/28219848/how-to-download-file-in-swift
class FileDownloader {

    static func loadFileSync(url: URL, completion: @escaping (String?, Error?) -> Void)
    {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)

        if FileManager().fileExists(atPath: destinationUrl.path)
        {
            print("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl.path, nil)
        }
        else if let dataFromURL = NSData(contentsOf: url)
        {
            if dataFromURL.write(to: destinationUrl, atomically: true)
            {
                print("file saved [\(destinationUrl.path)]")
                completion(destinationUrl.path, nil)
            }
            else
            {
                print("error saving file")
                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                completion(destinationUrl.path, error)
            }
        }
        else
        {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
            completion(destinationUrl.path, error)
        }
    }

    static func loadFileAsync(url: URL, completion: @escaping (String?, Error?) -> Void)
    {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)

        if FileManager().fileExists(atPath: destinationUrl.path)
        {
            print("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl.path, nil)
        }
        else
        {
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = session.dataTask(with: request, completionHandler:
            {
                data, response, error in
                if error == nil
                {
                    if let response = response as? HTTPURLResponse
                    {
                        if response.statusCode == 200
                        {
                            if let data = data
                            {
                                if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                                {
                                    completion(destinationUrl.path, error)
                                }
                                else
                                {
                                    completion(destinationUrl.path, error)
                                }
                            }
                            else
                            {
                                completion(destinationUrl.path, error)
                            }
                        }
                    }
                }
                else
                {
                    completion(destinationUrl.path, error)
                }
            })
            task.resume()
        }
    }
}

extension Data {
  /// Creates a new buffer by copying the buffer pointer of the given array.
  ///
  /// - Warning: The given array's element type `T` must be trivial in that it can be copied bit
  ///     for bit with no indirection or reference-counting operations; otherwise, reinterpreting
  ///     data from the resulting buffer has undefined behavior.
  /// - Parameter array: An array with elements of type `T`.
  init<T>(copyingBufferOf array: [T]) {
    self = array.withUnsafeBufferPointer(Data.init)
  }
}

extension Array {
  /// Creates a new array from the bytes of the given unsafe data.
  ///
  /// - Warning: The array's `Element` type must be trivial in that it can be copied bit for bit
  ///     with no indirection or reference-counting operations; otherwise, copying the raw bytes in
  ///     the `unsafeData`'s buffer to a new array returns an unsafe copy.
  /// - Note: Returns `nil` if `unsafeData.count` is not a multiple of
  ///     `MemoryLayout<Element>.stride`.
  /// - Parameter unsafeData: The data containing the bytes to turn into an array.
  init?(unsafeData: Data) {
    guard unsafeData.count % MemoryLayout<Element>.stride == 0 else { return nil }
    #if swift(>=5.0)
    self = unsafeData.withUnsafeBytes { .init($0.bindMemory(to: Element.self)) }
    #else
    self = unsafeData.withUnsafeBytes {
      .init(UnsafeBufferPointer<Element>(
        start: $0,
        count: unsafeData.count / MemoryLayout<Element>.stride
      ))
    }
    #endif  // swift(>=5.0)
  }
}


struct actions: View {
    let motion = CMMotionManager()
    let sf:Double = 1/25
    let timer = Timer.publish(every: 1/25, on: .main, in: .common).autoconnect()
    let defaults = UserDefaults.standard
    @State var to:CGFloat = 0
    @State var start:Bool = false
    @State var myStrings: [String]
    @State var Xarry:[Double] = []
    @State var Yarry:[Double] = []
    @State var Zarry:[Double] = []
    @State var XYZ:[[Double]] = []
    @State var time:(Double) = 3
    

    
    var body: some View {
        VStack{
            timerDis(to: $to,time: $time).padding().onReceive(timer) { input in
                if (start){
                    withAnimation(.default){
                        to += sf
                    }
                    if (to>=time){
                        withAnimation(.default){
                            to = 0
                            start = false
                            motion.stopAccelerometerUpdates()
                            if XYZ.count < 75 {
                                XYZ.append(XYZ.last!)
                            }
                            if XYZ.count > 75 {
                                XYZ.removeLast()
                            }
                            makepredictions(mydata: XYZ)
                            XYZ = []
                        }
                    }
                }
            }
            Button(action: {
                withAnimation(.default){
                    start.toggle()
                }
                if (start){
                    talk(words: "Start")
                    //collect data
                    motion.accelerometerUpdateInterval = sf
                    motion.startAccelerometerUpdates(to: .main) {
                            (data, error) in
                            guard let data = data, error == nil else {
                                return
                            }
                        let x = data.acceleration.x
                        let y = data.acceleration.y
                        let z = data.acceleration.z
                        XYZ.append([x,y,z])
                    }
                }
            }, label: {
                buttonPP(start: $start)
            })
        }
    }
}
func makepredictions(mydata: [[Double]]){
    var labels: [String] = []
    func loadLabels(filename: String, type: String) {
        let filename = filename
        let fileExtension = type
        guard let fileURL = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
          fatalError("Labels file not found in bundle. Please add a labels file with name " +
                       "\(filename).\(fileExtension) and try again.")
        }
        do {
          let contents = try String(contentsOf: fileURL, encoding: .utf8)
          labels = contents.components(separatedBy: .newlines)
        } catch {
          fatalError("Labels file named \(filename).\(fileExtension) cannot be read. Please add a " +
                       "valid labels file and try again.")
        }
      }
    loadLabels(filename: "labels", type: "txt")


    do {
            let modelPath = Bundle.main.path(forResource: "model", ofType: "tflite")
                 
            var options = Interpreter.Options()
     
            var interpreter = try Interpreter(modelPath: modelPath!, options: options)
            
        //     Allocate memory for the model's input `Tensor`s.
            try interpreter.allocateTensors()
            var arr = [Data]()
            for x in mydata {
                arr.append(Data(copyingBufferOf: x))
            }
            print(arr.count)
            
            var inputData = Data(copyingBufferOf: arr)  // Should be initialized
        //     input data preparation...
           
            // Copy the input data to the input `Tensor`.
            try interpreter.copy(inputData, toInputAt: 0)

            // Run inference by invoking the `Interpreter`.
            try interpreter.invoke()

            // Get the output `Tensor`
            var outputTensor = try interpreter.output(at: 0)

            // Copy output to `Data` to process the inference results.
            var outputSize = outputTensor.shape.dimensions.reduce(1, {x, y in x * y})
            var outputData =
                UnsafeMutableBufferPointer<Float32>.allocate(capacity: outputSize)
            outputTensor.data.copyBytes(to: outputData)
            for v in outputData {
                print("v = \(v)")
            }
            print(outputData.max())
            var highScore = outputData.max()
            var chosenIndex = outputData.firstIndex(of: highScore!)
            var chosenLabel = labels[chosenIndex!]
            outputData.deallocate()
            
            
            talk(words: "\(chosenLabel)")
        }
        catch {
            talk(words: "An Error has occurred: \(error)")
        }
}

func talk(words: String){
    let utterance = AVSpeechUtterance(string: words)
    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
    utterance.rate = 0.4

    let synthesizer = AVSpeechSynthesizer()
    synthesizer.speak(utterance)
    return
}

struct actions_Previews: PreviewProvider {
    static var previews: some View {
        actions(myStrings:[""])
    }
}

struct timerDis: View {
    @Binding var to:CGFloat
    @Binding var time:Double
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 1)
                .stroke(Color.gray.opacity(0.25),style: StrokeStyle(lineWidth: 35, lineCap: .round)).frame(width: 250, height: 250).rotationEffect(.init(degrees: Double(0)))
            Circle()
                .trim(from: 0, to: to/time)
                .stroke(Color.blue,style: StrokeStyle(lineWidth: 26, lineCap: .round))
                .frame(width: 250, height: 250).rotationEffect(.init(degrees: -90))
            VStack{
                Text("\(Int(to))").font(.system(size: 65)).fontWeight(.bold)
            }
        }
    }
}

struct buttonPP: View {
    @Binding var start:Bool
    var body: some View {
        Capsule().fill(Color("WB")).frame(width: 120, height: 50).overlay(
            HStack{
                Image(systemName: start ? "pause.fill":"play.fill").foregroundColor(Color.white)
                Text(start ? "Pause":"Start").foregroundColor(.white)
            }
        )
    }
}
