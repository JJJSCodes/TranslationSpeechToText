//
//  ViewController.swift
//  speech_translation
//
//  Created by Bayson on 4/16/23.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var language: UILabel!
    
    
    @IBOutlet weak var mic: UIButton!
    
    @IBOutlet weak var input: UILabel!
    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var submit: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        input.layer.cornerRadius = 5;
        input.layer.masksToBounds = true;
        input.layer.borderWidth = 1;
        input.layer.borderColor = UIColor.gray.cgColor

        
        result.layer.cornerRadius = 5;
        result.layer.masksToBounds = true;
        result.layer.borderWidth = 1;
        result.layer.borderColor = UIColor.gray.cgColor

    }


}

