//
//  ViewController.swift
//  MyLittleMonster
//
//  Created by Greg Willis on 11/10/16.
//  Copyright © 2016 Willis Programming. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var monsterImg: MonsterImage!
    @IBOutlet weak var foodImg: DragImage!
    @IBOutlet weak var heartImg: DragImage!
    
    @IBOutlet weak var skull1Img: UIImageView!
    @IBOutlet weak var skull2Img: UIImageView!
    @IBOutlet weak var skull3Img: UIImageView!
    
    
    
    let DIM_ALPHA: CGFloat = 0.2
    let OPAQUE: CGFloat = 1.0
    let MAX_PENALTIES = 3
    
    var penalties = 0
    var timer: Timer!
    var monsterHappy = false
    var currentItem: UInt32 = 0
    
    var musicPlayer: AVAudioPlayer!
    var sfxBite: AVAudioPlayer!
    var sfxHeart: AVAudioPlayer!
    var sfxDeath: AVAudioPlayer!
    var sfxSkull: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        foodImg.dropTarget = monsterImg
        heartImg.dropTarget = monsterImg
        
        skull1Img.alpha = DIM_ALPHA
        skull2Img.alpha = DIM_ALPHA
        skull3Img.alpha = DIM_ALPHA
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.itemDroppedOnCharacter(notif:)), name: NSNotification.Name(rawValue: "onTargetDropped"), object: nil)
        
        startTimer()
        
        do {
            try musicPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: Bundle.main.path(forResource: "cave-music", ofType: "mp3")!) as URL)
            try sfxBite = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: Bundle.main.path(forResource: "bite", ofType: "wav")!) as URL)
            try sfxDeath = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: Bundle.main.path(forResource: "death", ofType: "wav")!) as URL)
            try sfxHeart = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: Bundle.main.path(forResource: "heart", ofType: "wav")!) as URL)
            try sfxSkull = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: Bundle.main.path(forResource: "skull", ofType: "wav")!) as URL)
            
        } catch let err as NSError{
            print(err.localizedDescription)
        }
        
        musicPlayer.prepareToPlay()
        musicPlayer.play()
        
        sfxBite.prepareToPlay()
        sfxDeath.prepareToPlay()
        sfxHeart.prepareToPlay()
        sfxSkull.prepareToPlay()
    }
    
    func itemDroppedOnCharacter(notif: AnyObject) {

        monsterHappy = true
        startTimer()
        
        foodImg.alpha = DIM_ALPHA
        foodImg.isUserInteractionEnabled = false
        heartImg.alpha = DIM_ALPHA
        heartImg.isUserInteractionEnabled = false
        
        if currentItem == 0 {
            sfxHeart.play()
        } else {
            sfxBite.play()
        }
    }
    
    func startTimer() {
        
        if timer != nil {
            timer.invalidate()
        }
        
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(ViewController.changeGameState), userInfo: nil, repeats: true)
    }
    
    func changeGameState() {
        
        if !monsterHappy {
            
            penalties += 1
            sfxSkull.play()
            
            if penalties == 1 {
                skull1Img.alpha = OPAQUE
                skull2Img.alpha = DIM_ALPHA
            } else if penalties == 2 {
                skull2Img.alpha = OPAQUE
                skull3Img.alpha = DIM_ALPHA
            } else if penalties >= 3 {
                skull3Img.alpha = OPAQUE
            } else {
                skull1Img.alpha = DIM_ALPHA
                skull2Img.alpha = DIM_ALPHA
                skull3Img.alpha = DIM_ALPHA
            }
            
            if penalties >= MAX_PENALTIES {
                gameOver()
            }
        }
        
        let rand = arc4random_uniform(2)
        
        if rand == 0 {
            foodImg.alpha = DIM_ALPHA
            foodImg.isUserInteractionEnabled = false
            
            heartImg.alpha = OPAQUE
            heartImg.isUserInteractionEnabled = true
            
        } else {
            foodImg.alpha = OPAQUE
            foodImg.isUserInteractionEnabled = true
            
            heartImg.alpha = DIM_ALPHA
            heartImg.isUserInteractionEnabled = false
        }
        
        currentItem = rand
        monsterHappy = false
    }

    func gameOver() {
        timer.invalidate()
        monsterImg.playDeathAnimation()
        sfxDeath.play()
        musicPlayer.stop()
        wantToRestart()
    }
    
    func wantToRestart() {
        let alertController = UIAlertController(title: "You died", message: "Play Again?", preferredStyle: UIAlertControllerStyle.alert)
        
        let okayAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.playAgainHandler()
        }

        let cancelAction = UIAlertAction(title: "No", style: .cancel) 
        
        alertController.addAction(cancelAction)
        alertController.addAction(okayAction)
        
        self.present(alertController, animated: true)
    }
    
    func resetDefaults() {
        penalties = 0
        monsterHappy = false
        currentItem = 0
    }
    
    func playAgainHandler() {
        self.resetDefaults()
        self.viewDidLoad()
        monsterImg.playIdleAnimation()
    }
}

