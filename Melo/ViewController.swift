//
//  ViewController.swift
//  Melo
//
//  Created by Nathan Johnston on 11/8/19.
//  Copyright © 2019 Nathan Johnston. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import Firebase

class ViewController: UIViewController, UITextFieldDelegate  {
    
    fileprivate let SpotifyClientID = "ba9b13ccba204ed9a25f1a9bb73ceb8e"
    fileprivate let SpotifyRedirectURI = "Melo://SpotifyAuthentication"
    var refreshAPI = "http://melo.us-east-1.elasticbeanstalk.com/api/refresh_token"
    var tokenAPI = "http://melo.us-east-1.elasticbeanstalk.com/api/token"
    //MARK: Properties
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var lobbyCode: UITextField!
    
    @IBOutlet weak var headingText: UILabel!
    @IBOutlet weak var enter: UIButton!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        lobbyCode.keyboardType = UIKeyboardType.numberPad
        if traitCollection.userInterfaceStyle == .dark{
            let image = CIImage(cgImage: (logo?.image?.cgImage!)!)
            if let filter = CIFilter(name: "CIColorInvert"){
                filter.setDefaults()
                filter.setValue(image, forKey: kCIInputImageKey)
                let context = CIContext(options: nil)
                let imageRef = context.createCGImage(filter.outputImage!, from: image.extent)
                logo.image = UIImage(cgImage: imageRef!)
            }
        }
        //getAccessToken()
    }
    
//    @IBAction func hitReturn(_ sender: Any) {
//        lobbyCode.resignFirstResponder()
//        enter.sendActions(for: .touchUpInside)
//    }
    
    @IBAction func enter(_ sender: UIButton) {
        lobbyCode.resignFirstResponder()
        //GlobalVars.lobbyCode = lobbyCode.text!
    }
    
    @IBAction func createLobby(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.startSession()
    }
    func getAccessToken(){
        let url = URL(string: "https://accounts.spotify.com/authorize?client_id=" + SpotifyClientID + "&response_type=code&redirect_uri=" + SpotifyRedirectURI + "&scope=user-modify-playback-state%20user-read-currently-playing%20user-read-private")!
        if #available(iOS 10.0, *){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        else{
            UIApplication.shared.openURL(url)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool{
        if(identifier == "toLobbyUserViewController"){
            if(lobbyCode.text != ""){
                self.showSpinner(onView: self.view)
                let ref = Database.database().reference().child(lobbyCode.text!)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    if !snapshot.exists(){
                        self.removeSpinner()
                        let banner = GrowingNotificationBanner(title: "Error:", subtitle: "Lobby " + self.lobbyCode.text! + " does not exist", style: .danger)
                        banner.duration = 2.0
                        banner.show(bannerPosition: .bottom)
                    }
                    else{
                        self.removeSpinner()
                        GlobalVars.lobbyCode = self.lobbyCode.text!
                        self.performSegue(withIdentifier: "toLobbyUserViewController", sender: self)
                    }
                })
            }
            else{
                let banner = GrowingNotificationBanner(title: "Error:", subtitle: "You must enter a lobby code", style: .danger)
                banner.duration = 2.0
                banner.show(bannerPosition: .bottom)
                return false
            }
        }
        else{
            return true
        }
        return false
    }
}


