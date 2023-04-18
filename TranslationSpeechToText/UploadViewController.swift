//
//  UploadViewController.swift
//  TranslationSpeechToText
//
//  Created by Tenzin Chonzom on 4/17/23.
//

import UIKit
import MLKit
import PhotosUI

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
    
    @IBAction func translatePressed(_ sender: Any) {
        if (pickedImage == nil) {
            self.showAlert(description: "No Image Uploaded")
        }
        print("got picked image")
        let languageId = LanguageIdentification.languageIdentification()
        
        // translate uploaded image
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

