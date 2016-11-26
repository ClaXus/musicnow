//
//  MainController.swift
//  MusicNow
//
//  Created by Mohsen raeisi on 26/11/16.
//  Copyright © 2016 mohsen. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


class MainController: UIViewController, UITableViewDelegate ,UITableViewDataSource {
    
    
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var musicSlider: UISlider!
    @IBOutlet weak var artistLable: UILabel!
    @IBOutlet weak var nameLable: UILabel!
    
    @IBOutlet weak var musicTableView: UITableView!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    var mplayer = AVPlayer();
    
    var arrayOfMusics = [Music]();
    var isPlaying = 0;
    var correntPlayingItem = 0;
    
    override func viewDidLoad() {
        let music = Music();
        music.name = "sound.mp3";
        
        let music2 = Music();
        music2.name = "sound2.mp3";
        
        arrayOfMusics = [music,music2];
        
        
        arrayOfMusics = getMusicInfo();
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrayOfMusics.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("TableViewCell", owner: self, options: nil)?.first as! TableViewCell;
        cell.titleLabel.text =  arrayOfMusics[indexPath.row].name;
        cell.playButton.tag = indexPath.row
        
        
        cell.didPlayTapped = {[weak self] in
            self?.streamMusic(music: (self?.arrayOfMusics[indexPath.row])!);
            
        }
        
        return cell;
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        streamMusic(music: arrayOfMusics[indexPath.row]);
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72;
    }
    
    
    
    func getMusicInfo() -> [Music]{
        
        var musicList = [Music]();
        
        
        
        URLSession.shared.dataTask(with: NSURL(string: AppDelegate.endPoint+"/mamusic/api/getAll")! as URL, completionHandler: { (data, response, errorURL) -> Void in
            
            if errorURL == nil && data != nil {
                
                
                
                
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSArray {
                        
                        
                        for i in 0...jsonResult.count-1 {
                            
                            
                            var jsonObject = jsonResult[i] as! [String:AnyObject];
                            
                            let music = Music();
                            music.name = jsonObject["name"] as? String;
                            music.album = jsonObject["album"] as? String;
                            music.artist = jsonObject["artist"] as? String
                            music.duration = jsonObject["duration"] as? CLong;
                            music.annee = jsonObject["annee"] as? String
                            
                            musicList.append(music);
                            
                            
                        }
                        self.arrayOfMusics = musicList;
                        
                        DispatchQueue.main.async{
                            self.musicTableView.reloadData()
                        }
                        
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
            
                
                
                
                
                
            }).resume()
            
            return musicList;
            
        }
        
        
        func streamMusic(music : Music)  {
            
            
            let url = AppDelegate.endPoint+"/mamusic/api/dlMusic?name="+music.name
            
            let playerItem = AVPlayerItem( url:NSURL( string:url ) as! URL )
            print(playerItem.duration.seconds.description);
            mplayer = AVPlayer(playerItem:playerItem)
            mplayer.rate = 1.0;
            mplayer.volume = 1.0;
            isPlaying = 1;
            
            playButton.setTitle("Pause", for: .normal)
            nameLable.text = music.name.replacingOccurrences(of: ".mp3", with: "");
            artistLable.text = music.artist;
            
            
            mplayer.play()
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: mplayer.currentItem)
            
            
            
            
        }
        
        func playerDidFinishPlaying(note: NSNotification){
            playButton.setTitle("Play", for: .normal)
            isPlaying = 0;
            
            
        }
        
        @IBAction func onPlayOrPauseClick(_ sender: AnyObject) {
            if(mplayer != nil){
                if(isPlaying == 1){
                    mplayer.pause();
                    isPlaying = 0;
                    playButton.setTitle("Play", for: .normal)
                }else{
                    mplayer.play();
                    isPlaying = 1;
                    playButton.setTitle("Pause", for: .normal)
                }
            }
            
        }
        
        
        
}
