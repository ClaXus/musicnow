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


class MainController: UIViewController, UITableViewDelegate ,UITableViewDataSource,UINavigationControllerDelegate {
    
    
    
    @IBOutlet weak var shufflButton: UIButton!
    
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var musicSlider: UISlider!
    @IBOutlet weak var artistLable: UILabel!
    @IBOutlet weak var nameLable: UILabel!
    
    @IBOutlet weak var musicTableView: UITableView!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    var currentTableViewCell: TableViewCell!
    var mplayer = AVPlayer();
    
    var arrayOfMusics = [Music]();
    var isPlaying = false;
    var correntPlayingItem = -1;
    var shuffle = false;
    
    override func viewDidLoad() {
        
        let music = Music();
        music.name = "sound.mp3";
        
        let music2 = Music();
        music2.name = "sound2.mp3";
        
        arrayOfMusics = [music,music2];
        
        
        arrayOfMusics = getMusicInfo();
        
        nameLable.text = "";
        artistLable.text = "";
    }
    
    
    func updateSlider (){
        
        musicSlider.value = Float(mplayer.currentTime().seconds);
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrayOfMusics.count;
    }
    
    
    @IBAction func onSliderChange(_ sender: AnyObject) {
        mplayer.seek(to: CMTimeMake(Int64(musicSlider.value), 1))
        print(mplayer.currentTime().value);
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("TableViewCell", owner: self, options: nil)?.first as! TableViewCell;
        cell.titleLabel.text =  arrayOfMusics[indexPath.row].name;
        cell.playButton.tag = indexPath.row
        cell.artistLabel.text = arrayOfMusics[indexPath.row].artist;
        cell.isPlaying = arrayOfMusics[indexPath.row].isSelected;
        
       
        
        
        if(cell.isPlaying){
            cell.playButton.setImage(UIImage(named: "stop-circle.png"), for: UIControlState.normal)
        }else{
            cell.playButton.setImage(UIImage(named: "play-circle.png"), for: UIControlState.normal)
        }
 
        cell.didPlayTapped = {[weak self] in
            
            self?.correntPlayingItem = indexPath.row;
            if((self?.currentTableViewCell) != nil){
                self?.currentTableViewCell.playButton.setImage(UIImage(named: "play-circle.png"), for: UIControlState.normal)
                self?.currentTableViewCell.isPlaying = cell.isPlaying;
                
                self?.currentTableViewCell.setSelected(false, animated: true);
                
            }
            
            
            if(!cell.isPlaying){
                self?.streamMusic(music: (self?.arrayOfMusics[indexPath.row])!);
                cell.isPlaying = true;
                self?.arrayOfMusics[indexPath.row].isSelected = true;
                cell.playButton.setImage(UIImage(named: "stop-circle.png"), for: UIControlState.normal)
            }else{
                cell.isPlaying = false;
                self?.arrayOfMusics[indexPath.row].isSelected = false;

                self?.mplayer.seek(to: CMTimeMake(0, 1))
                self?.mplayer.pause();
                self?.playButton.setImage(UIImage(named: "play-circle.png"), for: UIControlState.normal)
                cell.playButton.setImage(UIImage(named: "play-circle.png"), for: UIControlState.normal)
            }
            
            
            self?.currentTableViewCell = cell;
            cell.setSelected(true, animated: true);
            
            
        }
        
        return cell;
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
    
    var timerRuned = false
    func streamMusic(music : Music)  {
        
        
        let url = AppDelegate.endPoint+"/mamusic/api/dlMusic?name="+music.name
        
        let playerItem = AVPlayerItem( url:NSURL( string:url ) as! URL )
        mplayer = AVPlayer(playerItem:playerItem)
        mplayer.rate = 1.0;
        mplayer.volume = 1.0;
        isPlaying = true;
        
        musicSlider.value = Float(mplayer.currentTime().value);
        musicSlider.minimumValue = 0;
        
        musicSlider.maximumValue = Float(music.duration);
        
        playButton.setImage(UIImage(named: "pause-circle.png"), for: UIControlState.normal)
        
        nameLable.text = music.name.replacingOccurrences(of: ".mp3", with: "");
        artistLable.text = music.artist;
        
        
        mplayer.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: mplayer.currentItem)
        
        if(!timerRuned){
            _ = Timer.scheduledTimer(timeInterval: 0.1, target: self,selector: #selector(MainController.updateSlider), userInfo: nil, repeats: true);
            timerRuned = true;
        }
        
        
    }
    
    func playerDidFinishPlaying(note: NSNotification){
        playButton.setImage(UIImage(named: "play-circle.png"), for: UIControlState.normal)
        isPlaying = false;
        currentTableViewCell.playButton.setImage(UIImage(named: "play-circle.png"), for: UIControlState.normal)
        currentTableViewCell.isPlaying = false;
        
        mplayer.seek(to: CMTimeMake(0, 1))
        
        playNext(random: shuffle);
    }
    
    @IBAction func onPlayOrPauseClick(_ sender: AnyObject) {
        if(mplayer != nil){
            if(isPlaying == true){
                mplayer.pause();
                isPlaying = false;
                playButton.setImage(UIImage(named: "play-circle.png"), for: UIControlState.normal)
            }else if(correntPlayingItem != -1){
                mplayer.play();
                isPlaying = true;
                playButton.setImage(UIImage(named: "pause-circle.png"), for: UIControlState.normal)
            }
        }
        
    }
    
    
    @IBAction func onNextClick(_ sender: AnyObject) {
        
        playNext(random: shuffle);
        
    }
    @IBAction func onPrevClick(_ sender: AnyObject) {
        
        var prev = correntPlayingItem - 1;
        if(prev == -1){
            prev = arrayOfMusics.count-1;
        }
        
        
        
        currentTableViewCell.setSelected(false, animated: true);
        currentTableViewCell.playButton.setImage(UIImage(named: "play-circle.png"), for: UIControlState.normal)
        currentTableViewCell.isPlaying = false;
        
        streamMusic(music : arrayOfMusics[prev])
        
        let indexPath = IndexPath(row: prev, section: 0)
        let nextCell = musicTableView.cellForRow(at: indexPath) as! TableViewCell!;
        
        /*
        arrayOfMusics[prev].isSelected = true;
        arrayOfMusics[correntPlayingItem].isSelected = false;
        */
        
        if(nextCell != nil){
            nextCell?.setSelected(true, animated: true);
            nextCell?.playButton.setImage(UIImage(named: "stop-circle.png"), for: UIControlState.normal)
            nextCell?.isPlaying = true;
        }
        
        correntPlayingItem = prev;
        currentTableViewCell = nextCell
        
    }
    
    func playNext (random : Bool) {
        
        var next = correntPlayingItem;
        let size = arrayOfMusics.count;
        if(!random){
            next = correntPlayingItem + 1;
            if(next == arrayOfMusics.count){
                next = 0;
            }
        }else{
            while(correntPlayingItem == next){
                next = Int(arc4random_uniform(UInt32(size)-1))
            }
        }
        
        currentTableViewCell.setSelected(false, animated: true);
        currentTableViewCell.playButton.setImage(UIImage(named: "play-circle.png"), for: UIControlState.normal)
        currentTableViewCell.isPlaying = false;
        
        streamMusic(music : arrayOfMusics[next])
        
        let indexPath = IndexPath(row: next, section: 0)
        let nextCell = musicTableView.cellForRow(at: indexPath) as! TableViewCell!;
        
        /*
        arrayOfMusics[next].isSelected = true;
        arrayOfMusics[correntPlayingItem].isSelected = false;
        */
        
        if(nextCell != nil){
            nextCell?.setSelected(true, animated: true);
            nextCell?.playButton.setImage(UIImage(named: "stop-circle.png"), for: UIControlState.normal)
            nextCell?.isPlaying = true;
        }
        
        correntPlayingItem = next;
        currentTableViewCell = nextCell
        
    }
    
    @IBAction func onShuffleClick(_ sender: AnyObject) {
        
        shuffle = !shuffle;
        
        if(shuffle){
            shufflButton.setImage(UIImage(named: "shuffle-variant.png"), for: UIControlState.normal);
        }else{
            shufflButton.setImage(UIImage(named: "shuffle-variant-2.png"), for: UIControlState.normal);
        }
        
        
    }
    
    
    
}
