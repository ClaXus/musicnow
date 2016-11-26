//
//  TableViewController.swift
//  MusicNow
//
//  Created by Mohsen raeisi on 26/11/16.
//  Copyright © 2016 mohsen. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: UITableViewController {
    var arrayOfMusics = [Music]();

    
    override func viewDidLoad() {
        let music = Music();
        music.name = "name 1";
        
        let music2 = Music();
        music2.name = "name 2";
        
        arrayOfMusics = [music,music2];
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
       return arrayOfMusics.count;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("TableViewCell", owner: self, options: nil)?.first as! TableViewCell;
        cell.titleLabel.text =  arrayOfMusics[indexPath.row].name;
        cell.playButton.tag = indexPath.row

        
        return cell;
    }
 
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72;
    }
    
}
