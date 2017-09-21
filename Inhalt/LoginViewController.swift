//
//  LoginViewController.swift
//  Inhalt
//
//  Created by digvijay.s on 29/08/17.
//  Copyright © 2017 digvijay.s. All rights reserved.
//

import UIKit
import TwitterKit

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("If session is set: \(String(describing: Twitter.sharedInstance().sessionStore.session() ))")
        if (Twitter.sharedInstance().sessionStore.session() != nil) {
            LoginSuccess()
        }
        else {
            addLoginButton()
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func LoginSuccess() {
        //print("If session is set: \(String(describing: Twitter.sharedInstance().sessionStore.session() ))")
        DispatchQueue.main.async(){
//            self.performSegue(withIdentifier: "Show Tweets After Login", sender: nil)
//            UIView.transition(from: self.view, to: , duration: <#T##TimeInterval#>, options: <#T##UIViewAnimationOptions#>, completion: <#T##((Bool) -> Void)?##((Bool) -> Void)?##(Bool) -> Void#>)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homeTabBarController = storyboard.instantiateViewController(withIdentifier: "HomeTabBarController")
            self.present(homeTabBarController, animated: true, completion: nil)
        }
    }
    
    private func addLoginButton() {
        let logInButton = TWTRLogInButton(logInCompletion: { [weak self] session, error in
            if (session != nil) {
                print("signed in as \(session?.userName ?? "")")
                UserDefaults.standard.set(session?.userID, forKey: "userID")
                self?.LoginSuccess()
            } else {
                print("error: \(error?.localizedDescription ?? "")")
            }
        })
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
