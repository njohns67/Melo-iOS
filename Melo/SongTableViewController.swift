//
//  SongTableViewController.swift
//  Melo
//
//  Created by Nathan Johnston on 11/11/19.
//  Copyright © 2019 Nathan Johnston. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class SongTableViewController: UITableViewController {

    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchBar: UITextField!

    var songs = [Song]()
    var query = ""
    var token = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        getAuth()
        searchBar.text = query
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func onTap_searchButton(_ sender: Any) {
        searchBar.resignFirstResponder()
        if(searchBar?.text?.isEmpty ?? true) {
            let banner = GrowingNotificationBanner(title: "Error:", subtitle: "You must enter a song to search for", style: .danger)
            banner.duration = 2.0
            banner.show(bannerPosition: .bottom)
        }
        else{
            query = (searchBar?.text)!
            getAuth()
        }
    }
    @IBAction func hitReturn(_ sender: Any) {
        searchBar.resignFirstResponder()
        if(searchBar?.text?.isEmpty ?? true) {
            return
        }
        else{
            searchButton.sendActions(for: .touchUpInside)
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(songs.count == 0){
            let emptyLabel = UILabel()
            emptyLabel.text = "No Results"
            emptyLabel.textAlignment = NSTextAlignment.center
            self.tableView.backgroundView = emptyLabel
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            return 0
        }
        return songs.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SongTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SongTableViewCell else{
            fatalError("Couldn't load the cell idk")
        }
        let song = songs[indexPath.row]
        cell.titleLabel.text = song.title
        cell.artistLabel.text = song.artist
        cell.thumbnail.contentMode = .scaleAspectFit
        let url = URL(string: song.imageURL)
        let data = try? Data(contentsOf: url!)
        cell.thumbnail.image = UIImage(data: data!)
//        DispatchQueue.global().async {
//            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
//            DispatchQueue.main.async {
//                cell.thumbnail.image = UIImage(data: data!)
//            }
//        }
        cell.addToQueueButton.tag = indexPath.row
        cell.songs += songs
        return cell
    }
    
   func searchForSong(){
        if query == ""{
            return
        }
    self.songs.removeAll()
    let url = "https://api.spotify.com/v1/search?q=" + query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! + "&type=track"
    let session = URLSession.shared
    var request = URLRequest(url: URL(string: url)!)
    request.httpMethod = "GET"
    request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
    let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
        guard error == nil else {
            print(error?.localizedDescription as Any)
            return
        }
        guard let data = data else {
            print(error?.localizedDescription as Any)
            return
        }
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                let tracks = json["tracks"] as? [String: Any]
                let items = tracks?["items"] as? [Any]
                for case let item as [String: Any] in items!{
                    let artists = item["artists"] as? [Any]
                    let artistItem = artists?[0] as? [String: Any]
                    let artist = artistItem?["name"] as? String
                    let title = item["name"] as? String
                    let uri = item["uri"] as? String
                    let album = item["album"] as? [String: Any]
                    let images = album?["images"] as? [Any]
                    let image = images?[0] as? [String: Any]
                    let imageURL = image?["url"] as? String
                    let song = Song(title: title!, artist: artist!, URI: uri!, imageURL: imageURL!)
                    self.songs.append(song)
                    print(String(format: "%@, %@, %@", title!, artist!, uri!))
                }
                DispatchQueue.main.async {[weak self] in
                    self?.tableView.reloadData()
                    self?.removeSpinner()
                }
                }
        } catch let error {
            print(error.localizedDescription)
                              
        }
    })
    task.resume()
    }
    
    func getAuth(){
        self.showSpinner(onView: self.view)
        let url = "https://accounts.spotify.com/api/token?grant_type=client_credentials"
        let session = URLSession.shared
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.addValue("Basic YmE5YjEzY2NiYTIwNGVkOWEyNWYxYTliYjczY2ViOGU6MzI3ZmIwYWQzMDAxNDcwZGIwYzk0MjYwYjc0Y2YxMjA=", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
               guard error == nil else {
                print(error?.localizedDescription as Any)
                   return
               }
               guard let data = data else {
                print(error?.localizedDescription as Any)
                   return
               }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print(json)
                        self.token = (json["access_token"] as? String)!
                        self.searchForSong()
                        }
                } catch let error {
                    print(error.localizedDescription)
                                      
                }
            })
            task.resume()
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}
