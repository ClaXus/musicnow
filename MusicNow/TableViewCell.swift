//
//  TableViewCell.swift
//  MusicNow
//
//  Created by Mohsen raeisi on 26/11/16.
//  Copyright © 2016 mohsen. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {


    @IBAction func onClick(_ sender: AnyObject) {
        didPlayTapped!();
    }

    
    var didPlayTapped: (() -> Void)?
    
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    var isPlaying  = false;
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        
       
        
        
        if(selected){
            //rgb(38, 50, 56)
        self.contentView.backgroundColor = UIColor.darkGray
        
        }else{
            
            self.contentView.backgroundColor = UIColor.black;
            
        
        }
        
        
    
        
        
    }
}
