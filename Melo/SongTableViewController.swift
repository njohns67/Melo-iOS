//
//  SongTableViewController.swift
//  Melo
//
//  Created by Nathan Johnston on 11/11/19.
//  Copyright © 2019 Nathan Johnston. All rights reserved.
//

import UIKit

class SongTableViewController: UITableViewController {

    var songs = [Song]()
    var query = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSongs()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    private func loadSongs(){
        let song1 = Song(title: "All Star", artist: "Smash Mouth", URI: "spotify:track:3cfOd4CMv2snFaKAnMdnvK")
        let song2 = Song(title: "We Are The Champions", artist: "Queen", URI: "spotify://song.uri")
        let song3 = Song(title: "Sweet Victory", artist: "David Glenn Eisley", URI: "spotify://song.uri")
        
        songs += [song1, song2, song3]
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
        cell.addToQueueButton.tag = indexPath.row
        cell.songs += songs
        return cell
    }
    
   /* func searchForSong(){
        if query == ""{
            return
        }
        let url = "https://api.spotify.com/v1/search?q=" + query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! + "&type=track"
        var request = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        request.httpMethod = "GET"
        //request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue(), completionHandler:{ (response:URLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            if jsonResult != nil{
                print(jsonResult)
            }
            else{
                print(error as! String)
            }
        })
    }*/
    
    

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
