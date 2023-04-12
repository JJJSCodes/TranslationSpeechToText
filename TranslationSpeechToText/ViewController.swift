//
//  ViewController.swift
//  TranslationSpeechToText
//
//  Created by Jason Mei on 4/11/23.
//

import UIKit
import MLKit

class ViewController: UIViewController, UINavigationControllerDelegate {
    var pickerVisible: Bool = false
    var targetLanguage = "en"
    var translator: Translator!
    let locale = Locale.current
    lazy var allLanguages = TranslateLanguage.allLanguages().sorted {
      return locale.localizedString(forLanguageCode: $0.rawValue)!
        < locale.localizedString(forLanguageCode: $1.rawValue)!
    }

    @IBOutlet weak var languageInputField: UITextView!
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var languagePicker: UIPickerView!
    
    
    @IBAction func translatePressed(_ sender: Any) {
        if (languageInputField.text!.isEmpty) {
            print("Empty input")
            return
        }
//        print("translating")
        let languageId = LanguageIdentification.languageIdentification()
//        let modelManager = ModelManager.modelManager()
//        modelManager.downloadedTranslateModels.forEach { model in modelManager.deleteDownloadedModel(model) { error in
//              }
//        }
//        print(modelManager.downloadedTranslateModels)
        let text = languageInputField.text!
        // Get language code of input text with MLKit Text recognition
        languageId.identifyLanguage(for: text) { (languageCode, error) in
          if let error = error {
            print("Failed with error: \(error)")
              self.translatedText.text = text
            return
          }
            if let languageCode = languageCode, languageCode != "und", languageCode != self.targetLanguage {
            // Call google translate api defined in GoogleTranslate.Swift
              let task = try? GoogleTranslate.sharedInstance.translateTextTask(text: self.languageInputField.text!, sourceLanguage: languageCode, targetLanguage: self.targetLanguage, completionHandler: { (translatedText: String?, error: Error?) in
                          debugPrint(error?.localizedDescription)
                          DispatchQueue.main.async {
                              if (error == nil) {
                                  self.translatedText.text = translatedText
                              } else {
                                  self.translatedText.text = text
                              }
                              self.translatedText.textColor = UIColor.black
                          }
                      })
                
                      task?.resume()
              
              
              
//              print("language code", languageCode)
//              let options = TranslatorOptions(sourceLanguage: TranslateLanguage(rawValue: languageCode), targetLanguage: self.targetLanguage)
//              self.translator = Translator.translator(options: options)
//              self.translator.downloadModelIfNeeded { error in
//              guard error == nil else { return }
//
//              // Model downloaded successfully. Okay to start translating.
//              print("DONE")
//              let translatorForDownloading = self.translator!
//              if translatorForDownloading == self.translator {
//                        print("in")
//                  translatorForDownloading.translate(self.languageInputField.text!) { result, error in
//                        guard error == nil else {
//                          self.translatedText.text = "Failed with error \(error!)"
//                            print(error)
//                          return
//                        }
//                        if translatorForDownloading == self.translator {
//                          self.translatedText.text = result
//                            print("translated", result)
//                        }
//                      }
//                    }
//              else {
//                  print("nil")
//              }
//          }
          } else {
            print("No language was identified")
            self.translatedText.text = text
          }
        }
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        // Hide picker when done button tapped
        if pickerVisible {
            languagePickerHeightContraint.constant = 0
            pickerVisible = false
        } else {
            languagePickerHeightContraint.constant = 150
            pickerVisible = true
        }
        languagePicker.isHidden = !pickerVisible
        doneButton.isHidden = !pickerVisible
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutSubviews()
            self.view.updateConstraints()
        }
    }
    
    @IBAction func languageSelectorTapped(_ sender: Any) {
        // Hide picker after language button tapped
        if pickerVisible {
            languagePickerHeightContraint.constant = 0
            pickerVisible = false
            
        } else {
            languagePickerHeightContraint.constant = 150
            pickerVisible = true
        }
        languagePicker.isHidden = !pickerVisible
        doneButton.isHidden = !pickerVisible
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutSubviews()
            self.view.updateConstraints()
        }
    }
    
    
    
    @IBOutlet weak var languagePickerHeightContraint: NSLayoutConstraint!
    

    @IBOutlet weak var translatedText: UITextView!
    
    @IBOutlet weak var languageSelectorButton: UIButton!
    
    override func viewDidLoad() {
            super.viewDidLoad()
            configureLanguagePicker()
            // Placeholder text for input and output
            translatedText.text = "Translation"
            translatedText.textColor = UIColor.lightGray
            languageInputField.text = "Input Text"
            languageInputField.textColor = UIColor.lightGray
            // Placeholder function
            languageInputField.delegate = self
            translatedText.delegate = self
            // Handle styling
            languageInputField.layer.borderWidth = 1
            languageInputField.layer.cornerRadius = 5
            languageInputField.layer.borderColor = UIColor.lightGray.cgColor
            
            translatedText.layer.borderWidth = 1
            translatedText.layer.cornerRadius = 5
            translatedText.layer.borderColor = UIColor.lightGray.cgColor
        }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Configuration
    func configureLanguagePicker() {
        languagePicker.dataSource = self
        languagePicker.delegate = self
        languagePicker.isHidden = true
        doneButton.isHidden = true
    }
    
//    func model(forLanguage: TranslateLanguage) -> TranslateRemoteModel {
//      return TranslateRemoteModel.translateRemoteModel(language: forLanguage)
//    }
//
//    func isLanguageDownloaded(_ language: TranslateLanguage) -> Bool {
//      let model = self.model(forLanguage: language)
//      let modelManager = ModelManager.modelManager()
//      return modelManager.isModelDownloaded(model)
//    }

}

// Langauge Picker
extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
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
        let outputLanguage = allLanguages[pickerView.selectedRow(inComponent: 0)]
        languageSelectorButton.setTitle(Locale.current.localizedString(forLanguageCode: outputLanguage.rawValue), for: .normal)
        targetLanguage = outputLanguage.rawValue
    }
}

// Placeholder functions
extension ViewController : UITextViewDelegate {
    func textViewDidBeginEditing(_ languageInputField: UITextView) {
        if languageInputField.textColor == UIColor.lightGray {
            languageInputField.text = nil
            languageInputField.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ languageInputField: UITextView) {
        if languageInputField.text.isEmpty {
            languageInputField.text = "Input Field"
            languageInputField.textColor = UIColor.lightGray
        }
    }
}


