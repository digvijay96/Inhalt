//
//  NewTweetViewController.swift
//  Inhalt
//
//  Created by digvijay.s on 18/09/17.
//  Copyright © 2017 digvijay.s. All rights reserved.
//

import UIKit

class NewTweetViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tweetText: UITextView!
    @IBOutlet weak var tweetButton: UIButton!
    @IBOutlet weak var tweetProgressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    
    private var request: Request?
    
    @IBAction func tweetButton(_ sender: UIButton) {
        let parameters: Dictionary<String, String> = ["status": tweetText.text]
        request = Request(Request.RequestType.new_status.rawValue, parameters)
        request?.performTweetsPostRequest(handler: { [weak self] tweet in
            self?.navigationController?.popViewController(animated: true)
            self?.dismiss(animated: true, completion: nil)
        })
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if tweetText.textColor == UIColor.lightGray {
            tweetText.text = nil
            tweetText.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if tweetText.text.isEmpty {
            tweetText.text = "What's happening?"
            tweetText.textColor = UIColor.lightGray
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.setImage(UIImage(named: "Delete"), for: .normal)
        tweetText.delegate = self
        tweetText.text = "What's happening?"
        tweetText.textColor = UIColor.lightGray
        tweetText.layer.borderColor = UIColor.black.cgColor
        tweetText.layer.borderWidth = 1.0
        tweetText.layer.cornerRadius = 5.0
        progressLabel.text = "140 characters left"
        tweetProgressView.progress = 0.0
//        tweetButton.setImage(UIImage(named: "Retweet"), for: .normal)
//        tweetText.becomeFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newTweetText = (tweetText.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfCharacters = newTweetText.characters.count
        tweetProgressView.progress = Float(Float(numberOfCharacters)/140.0)
        progressLabel.text = String(140 - numberOfCharacters) + " characters left"
        return numberOfCharacters<140
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
