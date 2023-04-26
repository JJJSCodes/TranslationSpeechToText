//
//  ViewController.swift
//  test
//
//  Created by Baosheng on 4/19/23.
//

import UIKit
import Speech
import AVFoundation
import MLKit

class SpeechToText: UIViewController{
    
    // all languages
    let data = ["en-US", "es-ES", "zh-CN"]
    // record input language
    var input_language = "en-US"
    // record input language
    var output_language = "en-US"
    
    //import alllanguage packet
    let locale = Locale.current
    lazy var allLanguages = TranslateLanguage.allLanguages().sorted {
      return locale.localizedString(forLanguageCode: $0.rawValue)!
        < locale.localizedString(forLanguageCode: $1.rawValue)!
    }
    
//    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    let audioEngine = AVAudioEngine()
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    
    // input text
    @IBOutlet weak var textView: UITextView!
    // output text
    @IBOutlet weak var output: UITextView!
    // record button
    @IBOutlet weak var recordButton: UIButton!
    // input language picker
    @IBOutlet weak var input: UIPickerView!
    // output language picker
    @IBOutlet weak var output_picker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the tag for each picker
        input.tag = 1
        output_picker.tag = 2
        
        input.dataSource = self
        input.delegate = self
        output_picker.dataSource = self
        output_picker.delegate = self
        
        // border for input and output boxes
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.layer.borderColor = UIColor.lightGray.cgColor
        
        output.layer.borderWidth = 1
        output.layer.cornerRadius = 5
        output.layer.borderColor = UIColor.lightGray.cgColor

        // init speechRecognizer
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)

//        speechRecognizer?.delegate = self

        // check authorization
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .authorized:
                print("Speech recognition authorized")
            case .denied:
                print("Speech recognition denied")
            case .restricted:
                print("Speech recognition restricted")
            case .notDetermined:
                print("Speech recognition not determined")
            @unknown default:
                fatalError()
            }
        }
    }
    
    // translation button
    @IBAction func translateButtonTapped(_ sender: UIButton) {
        if (textView.text!.isEmpty) {
            print("Empty input")
            return
        }
        let task = try? GoogleTranslate.sharedInstance.translateTextTask(text: self.textView.text!, sourceLanguage: self.input_language, targetLanguage: self.output_language, completionHandler: { (translatedText: String?, error: Error?) in
                          debugPrint(error?.localizedDescription)
                          DispatchQueue.main.async {
                              if (error == nil) {
                                  self.output.text = translatedText
                              } else {
                                  self.output.text = self.textView.text
                              }
                              self.output.textColor = UIColor.black
                          }
                      })

                      task?.resume()
    }

    // record or not
    @objc func recordButtonTapped() {
        if audioEngine.isRunning {
            stopRecording()
        } else {
            // clean up input textview
            textView.text = ""
            startRecording()
        }
    }

    // record function
    func startRecording() {
        
        // init speechRecognizer
        let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: input_language))
        speechRecognizer?.delegate = self

        recognitionTask?.cancel()
        recognitionTask = nil

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session error: \(error.localizedDescription)")
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object")
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine error: \(error.localizedDescription)")
        }

        // start to record
        textView.text = "Say something, I'm listening!"
        recordButton.setTitle("Stop Recording", for: .normal)

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { result, error in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                self.textView.text = bestString
            } else if let error = error {
                print("Speech recognition error: \(error)")
            }
        })
    }

    // stop audio engine
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recordButton.setTitle("Start Recording", for: .normal)
    }

}

// record button available
extension SpeechToText: SFSpeechRecognizerDelegate {

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
        } else {
            recordButton.isEnabled = false
        }
    }

}

// Langauge Picker
extension SpeechToText: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allLanguages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Locale.current.localizedString(forLanguageCode: allLanguages[row].rawValue)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1{
            let outputLanguage = allLanguages[pickerView.selectedRow(inComponent: 0)]
            input_language = outputLanguage.rawValue
            print("=-=-=-=-=-=-=-=-=-=-")
            print(input_language)
        }
        else{
            let outputLanguage = allLanguages[pickerView.selectedRow(inComponent: 0)]
            output_language = outputLanguage.rawValue
            print("+_+_+_+_+_+_+_+_+_+_")
            print(output_language)
        }
    }
}
//extension SpeechToText: UIPickerViewDataSource, UIPickerViewDelegate {
//
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return data.count
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return data[row]
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        if pickerView.tag == 1{
//            let outputLanguage = data[pickerView.selectedRow(inComponent: 0)]
//            input_language = outputLanguage
//            print("=-=-=-=-=-=-=-=-=-=-")
//            print(input_language)
//        }
//        else{
//            let outputLanguage = data[pickerView.selectedRow(inComponent: 0)]
//            output_language = outputLanguage
//            print("+_+_+_+_+_+_+_+_+_+_")
//            print(output_language)
//        }
//    }
//}
