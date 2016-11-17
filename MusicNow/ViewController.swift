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
    
    
    @IBOutlet weak var playButton: UIButton!
    
    
    private var player : AVAudioPlayer?

    private var musicData : Music?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playButton.isEnabled = false;
        // Do any additional setup after loading the view, typically from a nib.
        
       musicData = getMusic(name: "sound.mp3");
        
        
        
        //http://10.1.3.59:9000/mamusic/api/getAll
        
        
        
    }
    
    
    func getMusic(name : String) -> Music{
        
        
        let music = Music();
 
        
        URLSession.shared.dataTask(with: NSURL(string: "http://10.1.3.59:9000/mamusic/api/getmusic?name=sound2.mp3")! as URL, completionHandler: { (data, response, error) -> Void in

            if error == nil && data != nil {
                
                
                do {

                    
                    
                    do {
                        
                        let jsonArray = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String:AnyObject]
                        
                        music.data =  jsonArray["data"] as! String;
                        music.name = jsonArray["name"] as? String;
                        music.album = jsonArray["album"] as? String;
                        music.artist = jsonArray["artist"] as? String
                        music.duration = jsonArray["duration"] as? CLong;
                        music.annee = jsonArray["annee"] as? String
                        
                        self.nameLabel.text = jsonArray["name"] as? String
                        self.durationLabel.text = (jsonArray["duration"] as? Int)?.description
                        
                   
                        
                        self.playButton.isEnabled = true;

                        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPlayClick(_ sender: AnyObject) {
        
        
        playMusic(music: musicData!)
        
        
    }
    
    func playMusic (music : Music){
        
        let audioData: NSData! = NSData(base64Encoded: music.data , options: NSData.Base64DecodingOptions(rawValue:0))
        
        if audioData != nil
        {
            if let sound = try? AVAudioPlayer(data: audioData as Data){
                sound.play()
                self.player = sound;
            }
        }
        else
        {
            print("Data Not Exist")
        }

    }
    
}

