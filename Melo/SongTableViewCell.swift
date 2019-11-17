//
//  SongTableViewCell.swift
//  Melo
//
//  Created by Nathan Johnston on 11/11/19.
//  Copyright © 2019 Nathan Johnston. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import Firebase

class SongTableViewCell: UITableViewCell {
    var lobbyCode = GlobalVars.lobbyCode
    var songs = [Song]()
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var addToQueueButton: UIButton!
    @IBOutlet weak var thumbnail: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func addToQueue(_ sender: UIButton) {
        let song = songs[sender.tag]
        let title = song.title
        let artist = song.artist
        let URI = song.URI
        Database.database().reference().child(lobbyCode).child(title).setValue(URI)
        let banner = GrowingNotificationBanner(title: String(format: "Added %@ by %@ to the queue", title, artist), subtitle: "", style: .success)
        banner.duration = 2.0
        banner.show(bannerPosition: .bottom)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

