//
//  LobbyAdminViewController.swift
//  Melo
//
//  Created by Nathan Johnston on 11/8/19.
//  Copyright © 2019 Nathan Johnston. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift

class LobbyAdminViewController: UIViewController, SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    var lobbyCode: String = ""
    var progress: Float = 0
    var currentSong = ""
    var currentArtist = ""
    var songLength = 0
    var isPaused = false
    fileprivate let SpotifyClientID = "ba9b13ccba204ed9a25f1a9bb73ceb8e"
    fileprivate let SpotifyRedirectURI = "melo://SpotifyAuthentication"
    fileprivate let SpotifyClientSecret = "327fb0ad3001470db0c94260b74cf120"
    fileprivate var lastPlayerState: SPTAppRemotePlayerState?
    var refreshAPI = "http://melo.us-east-1.elasticbeanstalk.com/api/refresh_token"
    var tokenAPI = "http://melo.us-east-1.elasticbeanstalk.com/api/token"

    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: SpotifyClientID, redirectURL: URL(string: SpotifyRedirectURI)!)
           configuration.playURI = ""
           configuration.tokenSwapURL = URL(string: tokenAPI)
           configuration.tokenRefreshURL = URL(string: refreshAPI)
           return configuration
       }()
    //var sessionManager: SPTSessionManager? = nil
       lazy var sessionManager: SPTSessionManager = {
           let manager = SPTSessionManager(configuration: configuration, delegate: self)
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
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var pausePlayButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var currentArtistLabel: UILabel!
    @IBOutlet weak var currentSongLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!

    
    override func viewDidLoad() {
        print("Ran")
        let random = Int(arc4random_uniform(900000) + 100000)
        lobbyCode = String(random)
        print("Got lobby code: " + lobbyCode)
        lobbyCodeLabel.text = lobbyCode
        GlobalVars.lobbyCode = lobbyCode
        var dbref: DatabaseReference!
        dbref = Database.database().reference()
        dbref.child(lobbyCode).child("null").setValue("null")
        
        let ref = Database.database().reference().child(lobbyCode)
               ref.observe(.childAdded, with: {(snapshot) -> Void in
                   if(snapshot.key == "currentSong"){
                       return
                   }
                   if(snapshot.value as! String != "null"){
                    self.appRemote.playerAPI?.enqueueTrackUri(snapshot.value as! String)
                       ref.child(snapshot.key).removeValue()
                   }
               })
    }
    
    func update(playerState: SPTAppRemotePlayerState) {
       if lastPlayerState?.track.uri != playerState.track.uri {
            //fetchArtwork(for: playerState.track)
       }
        print("Updating")
        lastPlayerState = playerState
        print(playerState.track.name)
        let track = playerState.track
        let lobbyRef = Database.database().reference().child(lobbyCode)
        if(playerState.track.name != ""){
            currentSongLabel.text = track.name
            currentArtistLabel.text = track.artist.name
            progressBar.setProgress(Float(songLength/1000), animated: false)
            songLength = Int(track.duration)
            if(currentSong != track.name){
                currentSong = track.name
                progressBar.setProgress(0, animated: false)
                progress = 0
                let ref = lobbyRef.child("currentSong")
                ref.child("title").setValue(track.name)
                ref.child("artist").setValue(track.artist.name)
                ref.child("isPaused").setValue("false")
            }
            else{
                if(playerState.isPaused){
                    isPaused = true
                    lobbyRef.child("currentSong").child("isPaused").setValue("true")
                    pausePlayButton.setBackgroundImage(UIImage(systemName: "play"), for: .normal)
                    return
                }
                else{
                    if(isPaused){
                        isPaused = false
                        lobbyRef.child("currentSong").child("isPaused").setValue("false")
                        pausePlayButton.setBackgroundImage(UIImage(systemName: "pause"), for: .normal)
                        return
                    }
                progressBar.setProgress(0, animated: false)
                progress = 0
                lobbyRef.child("currentSong").child("position").setValue("0")
                }
            }
        }
        else{
            progressBar.setProgress(0, animated: false)
            progress = 0
            lobbyRef.child("currentSong").child("position").setValue("0")
        }
        currentSongLabel.text = playerState.track.name
        currentArtistLabel.text = playerState.track.artist.name
        if playerState.isPaused {
            pausePlayButton.setBackgroundImage(UIImage(systemName: "play"), for: .normal)
            isPaused = true
            lobbyRef.child("currentSong").child("isPaused").setValue("true")
        } else {
            pausePlayButton.setBackgroundImage(UIImage(systemName: "pause"), for: .normal)
            isPaused = false
            lobbyRef.child("currentSong").child("isPaused").setValue("false")
        }
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

    @IBAction func onTap_pausePlayButton(_ sender: UIButton) {
        print("tapped")
        let lobbyRef = Database.database().reference().child(lobbyCode)
        if let lastPlayerState = lastPlayerState, lastPlayerState.isPaused {
            pausePlayButton.setBackgroundImage(UIImage(systemName: "pause"), for: .normal)
            isPaused = false
            lobbyRef.child("currentSong").child("isPaused").setValue("false")
            appRemote.playerAPI?.resume(nil)
            print("Resuming")
        } else {
            appRemote.playerAPI?.pause(nil)
            pausePlayButton.setBackgroundImage(UIImage(systemName: "play"), for: .normal)
            isPaused = false
            lobbyRef.child("currentSong").child("isPaused").setValue("true")
            print("Pausing")
        }
    }
    
    @IBAction func onTap_skipButton(_ sender: Any) {
        appRemote.playerAPI?.skip(toNext: nil)
    }
    
    @IBAction func onTap_previousButton(_ sender: Any) {
        appRemote.playerAPI?.skip(toPrevious: nil)
    }
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
//        presentAlertController(title: "Authorization Failed", message: error.localizedDescription, buttonTitle: "Bummer")
        print("Bad init")
        print(error.localizedDescription)
    }

    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
//      presentAlertController(title: "Session Renewed", message: session.description, buttonTitle: "Sweet")
        print("Renewed")
    }

    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("Trying to connect")
        appRemote.connectionParameters.accessToken = session.accessToken
        //print(session.accessToken)
        DispatchQueue.main.async {[weak self] in
            self?.appRemote.connect()
        }
        //appRemote.connect()
    }

    // MARK: - SPTAppRemoteDelegate

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("Connected I think")
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
            if let error = error {
                print("Error subscribing to player state:" + error.localizedDescription)
            }
        })
        print("Lobby code: " + lobbyCode)
        fetchPlayerState()
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

    // MARK: - Private Helpers

    fileprivate func presentAlertController(title: String, message: String, buttonTitle: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
        controller.addAction(action)
        present(controller, animated: true)
    }
    
    @IBAction func hitReturn(_ sender: Any) {
        searchSong.resignFirstResponder()
        if(searchSong?.text?.isEmpty ?? true){
            return
        }
        searchButton.sendActions(for: .touchUpInside)
    }
    
    @IBAction func enter(_ sender: Any) {
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
      }

    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */

}
