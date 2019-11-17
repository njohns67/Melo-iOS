//
//  LobbyUserViewController.swift
//  Melo
//
//  Created by Nathan Johnston on 11/8/19.
//  Copyright © 2019 Nathan Johnston. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift

class LobbyUserViewController: UIViewController, SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    var progress: Float = 0
    var currentSong = ""
    var currentArtist = ""
    var songLength = 0
    var isPaused = false
    var timer = Timer()
    var timeInterval = 0.0
    fileprivate let SpotifyClientID = "ba9b13ccba204ed9a25f1a9bb73ceb8e"
    fileprivate let SpotifyRedirectURI = URL(string: "Melo://SpotifyAuthentication")!
    fileprivate var lastPlayerState: SPTAppRemotePlayerState?
    var refreshAPI = "http://melo.us-east-1.elasticbeanstalk.com/api/refresh_token"
    var tokenAPI = "http://melo.us-east-1.elasticbeanstalk.com/api/token"
    var lobbyCode = GlobalVars.lobbyCode
    
    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURI)
        configuration.playURI = ""
        configuration.tokenSwapURL = URL(string: tokenAPI)
        configuration.tokenRefreshURL = URL(string: refreshAPI)
        return configuration
    }()

    lazy var sessionManager: SPTSessionManager = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        manager.delegate = self
        return manager
      }()

    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.delegate = self
        return appRemote
      }()

    @IBOutlet weak var lobbyCodeLabel: UILabel!

    @IBOutlet weak var searchSong: UITextField!
    @IBOutlet weak var searchButton: UIButton!
  
    @IBOutlet weak var currentSongLabel: UILabel!
    @IBOutlet weak var currentArtistLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lobbyCodeLabel.text = lobbyCode
        print(lobbyCode)
        let scope: SPTScope = [.appRemoteControl]
        if #available(iOS 11, *) {
            print("ios 11")
            //sessionManager.initiateSession(with: scope, options: .clientOnly)
            print("Trying to initiate in if")
        } else {
            print("Not 11")
            sessionManager.initiateSession(with: scope, options: .clientOnly, presenting: self)
        }
        Database.database().reference().child(lobbyCode).child("userAdded").setValue("true")
        let ref = Database.database().reference().child(lobbyCode).child("currentSong")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            self.currentSong = snapshot.childSnapshot(forPath: "title").value as! String
            self.currentArtist = snapshot.childSnapshot(forPath: "artist").value as! String
            self.songLength = Int(snapshot.childSnapshot(forPath: "duration").value as! String)!
            self.timeInterval = Double(self.songLength)/100000
            let _progress = snapshot.childSnapshot(forPath: "position").value as! String
            self.progress = Float(Float(_progress)!/Float((self.songLength)/1000))
            print(String(self.progress))
            self.currentSongLabel.text = self.currentSong
            self.currentArtistLabel.text = self.currentArtist
            self.progressBar.setProgress(self.progress, animated: false)
            self.timer = Timer.scheduledTimer(timeInterval: self.timeInterval, target: self, selector: #selector(self.timerFunc), userInfo: nil, repeats: true)
            print("Set progress2 ", String(self.progress))
            
        })
        ref.observe(.childChanged, with: {(snapshot) -> Void in
                switch snapshot.key{
                case "title":
                    self.currentSong = snapshot.value as! String
                    print(self.currentSong)
                    self.currentSongLabel.text = self.currentSong
                    self.progressBar.setProgress(0, animated: false)
                case "artist":
                    self.currentArtist = snapshot.value as! String
                    self.currentArtistLabel.text = self.currentArtist
                case "duration":
                    self.songLength = Int(snapshot.value as! String)!
                    self.timeInterval = Double(self.songLength)/100000
                    self.timer.invalidate()
                    self.timer = Timer.scheduledTimer(timeInterval: self.timeInterval, target: self, selector: #selector(self.timerFunc), userInfo: nil, repeats: true)
                case "position":
                    let value = snapshot.value as! String
                    self.progress = Float(Float(value)!/Float((self.songLength)/1000))
                    print("Set progress " + String(self.progress))
                    self.timer.invalidate()
                    self.timer = Timer.scheduledTimer(timeInterval: self.timeInterval, target: self, selector: #selector(self.timerFunc), userInfo: nil, repeats: true)
                case "isPaused":
                    let value = snapshot.value as! String
                    if(value == "true"){
                        self.isPaused = true
                    }
                    else{
                        self.isPaused  = false
                    }
                default:
                    break
                }
        })
        
        // Do any additional setup after loading the view.
    }
    
    @objc func timerFunc(){
        if(!self.isPaused){
            progressBar.setProgress(progress, animated: true)
            progress += 0.01
        }
    }
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("Connected I think")
        appRemote.playerAPI?.delegate = self
        fetchPlayerState()
    }
    
    func fetchPlayerState() {
        print("Getting player state")
        appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
            if let error = error {
                print("Error getting player state:" + error.localizedDescription)
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
                self?.update(playerState: playerState)
            }
        })
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
    //        presentAlertController(title: "Authorization Failed", message: error.localizedDescription, buttonTitle: "Bummer")
            print("Bad init")
            print(error.localizedDescription)
        }

        func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
    //        presentAlertController(title: "Session Renewed", message: session.description, buttonTitle: "Sweet")
            print("Renewed")
        }

        func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
            print("Trying to connect")
            appRemote.connectionParameters.accessToken = session.accessToken
            print(session.accessToken)
            //appRemote.connect()
        }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        lastPlayerState = nil
        print("Error connecting to app remote")
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        lastPlayerState = nil
        print("Another error connectiong to app remote")
    }

    // MARK: - SPTAppRemotePlayerAPIDelegate

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        print("Player state changed")
        update(playerState: playerState)
    }
    
    func update(playerState: SPTAppRemotePlayerState){
        
    }
    

    @IBAction func hitReturn(_ sender: Any) {
        searchSong.resignFirstResponder()
        if(searchSong?.text?.isEmpty ?? true){
            return
        }
        searchButton.sendActions(for: .touchUpInside)
    }
    @IBAction func enter(_ sender: UIButton) {
        searchSong.resignFirstResponder()
    }
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool{
        if(identifier == "toSongTableViewController"){
            if(searchSong?.text?.isEmpty ?? true) {
                let banner = GrowingNotificationBanner(title: "Error:", subtitle: "You must enter a song to search for", style: .danger)
                banner.duration = 2.0
                banner.show(bannerPosition: .bottom)
                return false
            }
            else{
                return true
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let vc = segue.destination as? SongTableViewController
        vc?.query = searchSong.text!
        searchSong.text?.removeAll()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
