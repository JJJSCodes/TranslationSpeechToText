//
//  UploadViewController.swift
//  TranslationSpeechToText
//
//  Created by Tenzin Chonzom on 4/17/23.
//

import UIKit
import MLKit
import PhotosUI
import SwiftyJSON

class UploadViewController: UIViewController {
    
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
    @IBOutlet weak var languageSelectorButton: UIButton!
    @IBOutlet weak var translatedText: UITextView!
    @IBOutlet weak var languagePickerHeightConstraint: NSLayoutConstraint!
    
    private var pickedImage: UIImage?
    private var inputText: String?
    let group = DispatchGroup()
    
    private var gotInputText: Bool = false
    
    let session = URLSession.shared
    var googleAPIKey = "AIzaSyAw9seNh0duA11NBHiYvflZoJY3XA7mhWo"
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    
    @IBAction func translatePressed(_ sender: Any) {
        print("translate pressed")
        if (pickedImage == nil) {
            self.showAlert(description: "No Image Uploaded")
        } else {
            let languageId = LanguageIdentification.languageIdentification()
            
            print("back in translate function")
            group.wait()
            print(inputText)
            languageInputField.text = inputText
            languageInputField.textColor = UIColor.black
            
            let text = languageInputField.text!
            languageId.identifyLanguage(for: text) { (languageCode, error) in
              if let error = error {
                print("Failed with error: \(error)")
                return
              }
              if let languageCode = languageCode, languageCode != "und", languageCode != self.targetLanguage {
                  print("Identified Language: \(languageCode)")
                  
                  // Call google translate api defined in GoogleTranslate.Swift
                  let task = try? GoogleTranslate.sharedInstance.translateTextTask(text: self.languageInputField.text!, sourceLanguage: languageCode, targetLanguage: self.targetLanguage, completionHandler: {
                      (translatedText: String?, error: Error?) in
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
                  
                  
              } else {
                print("No language was identified")
              }
            }
            
        }
    }
    
    @IBAction func uploadImagePressed(_ sender: Any) {
        var config = PHPickerConfiguration()

        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        // Hide picker when done button tapped
        if pickerVisible {
            languagePickerHeightConstraint.constant = 0
            pickerVisible = false
        } else {
            languagePickerHeightConstraint.constant = 150
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
            languagePickerHeightConstraint.constant = 0
            pickerVisible = false
        } else {
            languagePickerHeightConstraint.constant = 150
            pickerVisible = true
        }
        languagePicker.isHidden = !pickerVisible
        doneButton.isHidden = !pickerVisible
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutSubviews()
            self.view.updateConstraints()
        }
    }
    
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
    
    func configureLanguagePicker() {
        languagePicker.dataSource = self
        languagePicker.delegate = self
        languagePicker.isHidden = true
        doneButton.isHidden = true
    }
    
    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}

// Image Processing

extension UploadViewController {
    func analyzeResults(_ dataToParse: Data) {
        // Use SwiftyJSON to parse results
        do {
            print("parsing json")
            let json = try JSON(data: dataToParse)
            let text: JSON = json["responses"][0]["fullTextAnnotation"]["text"]
            DispatchQueue.main.async {
                self.inputText = text.stringValue
                self.gotInputText = true
            }
        }
        catch {
            print("couldn't parse JSON")
            showAlert(description: "Could not parse JSON response from API")
        }
    }
}


extension UploadViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
           provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in

           guard let image = object as? UIImage else {
              // ❌ Unable to cast to UIImage
              self?.showAlert()
              return
           }
            
           if let error = error {
              self?.showAlert(description: error.localizedDescription)
              return
           } else {
              DispatchQueue.main.async {
                 self?.pickedImage = image
                 print("set pickedImage")
                 print("encoding image in base64string")
                  
                 // Base64 encode image and create request
                  let imageBase64String = self?.convertImageToBase64String((self?.pickedImage)!)
                  self?.createRequest(with: imageBase64String!)
              }
           }
        }
    }
}

extension UploadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("❌📷 Unable to get image")
            return
        }

        pickedImage = image
    }

}

extension UploadViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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
extension UploadViewController : UITextViewDelegate {
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

// Networking
extension UploadViewController {
    func convertImageToBase64String(_ image: UIImage, compressionQuality: CGFloat = 1.0) -> String? {
        // Step 1: Get the data representation of the UIImage (in this case, as a JPEG)
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            return nil
        }
        
        // Step 2: Encode the data as a base64 string
        let base64String = imageData.base64EncodedString(options: .lineLength64Characters)
        
        return base64String
    }
    
    func createRequest(with imageBase64: String) {
        print("creating API request")
        // Create our request URL
        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // Build our API Request
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageBase64
                ],
                "features": [
                    "type": "TEXT_DETECTION"
                ]
            ]
        ]
        let jsonObject = JSON(jsonRequest)
        
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            return
        }
        
        request.httpBody = data
        
//        // Run the request on a background thread
//        DispatchQueue.global().async {
//            self.runRequestOnBackgroundThread(request)
//        }
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
                
            self.analyzeResults(data)
        }
            
        task.resume()
    }
    
    func runRequestOnBackgroundThread(_ request: URLRequest) {
        // run the request
            
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
                
            self.analyzeResults(data)
        }
            
        task.resume()
    }
    
}
