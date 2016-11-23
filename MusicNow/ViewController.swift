//
//  ViewController.swift
//  MusicNow
//
//  Created by mohsen on 16/11/16.
//  Copyright © 2016 mohsen. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    
    private var player : AVAudioPlayer?

    private var musicData : Music?
    var mplayer = AVPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        
        //pour recuperer toutes les musics
        //http://10.1.3.59:9000/mamusic/api/getAll
        
        
        
    }
    
    @IBAction func onStreamClick(_ sender: AnyObject) {
        
      
        streamMusic(name: "sound4.mp3")
        print("clicked");
    }
    

    
    
    @IBAction func onGetInfoClick(_ sender: AnyObject) {
        getMusicInfo(name : "sound4.mp3")
    }
    
    
    func getMusicInfo(name : String) -> Music{
        
        
        let music = Music();
 
        
        URLSession.shared.dataTask(with: NSURL(string: AppDelegate.endPoint+"/mamusic/api/getmusic?name="+name)! as URL, completionHandler: { (data, response, error) -> Void in

            if error == nil && data != nil {
                
                
                do {

                    
                    
                    do {
                        
                        let jsonArray = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String:AnyObject]
                        
                        music.name = jsonArray["name"] as? String;
                        music.album = jsonArray["album"] as? String;
                        music.artist = jsonArray["artist"] as? String
                        music.duration = jsonArray["duration"] as? CLong;
                        music.annee = jsonArray["annee"] as? String
                        
                        self.nameLabel.text = jsonArray["name"] as? String
                        self.durationLabel.text = (jsonArray["duration"] as? Int)?.description
                        self.durationLabel.text = self.durationLabel.text! + " sec";
                   
                        
                    } catch {
                        print("Error: \(error)")
                    }
                    
                } catch {
                    print("error");
                }
            }
            
        }).resume()
        
        return music;
        
    }
    
    func streamMusic(name : String)  {
        
        
        let url = AppDelegate.endPoint+"/mamusic/api/dlMusic?name="+name
        
        let playerItem = AVPlayerItem( url:NSURL( string:url ) as! URL )
        print(playerItem.duration.seconds.description);
        mplayer = AVPlayer(playerItem:playerItem)
        mplayer.rate = 1.0;
        mplayer.volume = 1.0;
        
        mplayer.play()
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}

