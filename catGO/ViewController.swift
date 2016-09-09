//
//  ViewController.swift
//  catGO
//
//  Created by daiki terai on 2016/09/08.
//  Copyright © 2016年 teradonburi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var myoButton: UIButton!
    @IBOutlet weak var ballImage: UIImageView!
    @IBOutlet weak var catImage: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!

    var myo:Myo!
    var timer:NSTimer!
    var posY:CGFloat!
    var isThrow:Bool = false

    @IBAction func reset(sender: AnyObject) {
        self.resetButton.hidden = true
        
        self.catImage.transform = CGAffineTransformMakeScale(1, 1)
        self.messageLabel.text = "Lock On!"
        self.isThrow = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.myo = Myo()
        self.posY = self.ballImage.top
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if(myo.isConnected){
            self.myoButton.hidden = true
            self.catImage.hidden = false
            self.ballImage.hidden = false

            
            if self.timer != nil{
                if self.timer.valid == true {
                    // timerを破棄する
                    self.timer.invalidate()
                }
            }

            // タイマーを作る
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(ViewController.onUpdate(_:)), userInfo: nil, repeats: true)

        }
        else{
            self.myoButton.hidden = false
            self.catImage.hidden = true
            self.ballImage.hidden = true
            
            if self.timer != nil{
                if self.timer.valid == true {
                    // timerを破棄する
                    self.timer.invalidate()
                }
            }
        }
 
        
    }
    
    
    
    // 更新処理
    func onUpdate(timer : NSTimer){
        
        if(!self.isThrow){
            self.ballImage.layer.transform = self.myo.rotation
        }
        
        if(self.myo.isUnlock){
            
            //lockon
            self.messageLabel.hidden = false
            
            // 上に投げる
            if(self.myo.magnitude > 1.01 && self.myo.accel.x < 0.4){
                self.isThrow = true

                UIView.animateWithDuration(1.0,
                    // アニメーション中の処理
                    animations: { () -> Void in
                        
                        // 移動用のアフィン行列作成
                        self.ballImage.transform = CGAffineTransformMakeTranslation( 0.0, -self.posY+100.0)
                        
                        // 連続したアニメーション処理.
                }) { (Bool) -> Void in
                    UIView.animateWithDuration(3.0,
                                               
                        // アニメーション中の処理
                        animations: { () -> Void in
                            
                            // 縮小のアフィン行列作成
                            self.catImage.transform = CGAffineTransformMakeScale(0.1, 0.1)
                            
                            // アニメーション完了時の処理
                    }) { (Bool) -> Void in
                        self.messageLabel.text = "Gotta catch 'em all!"
                        self.resetButton.hidden = false

                    }
                }
                
            }
        
        }else{
            self.messageLabel.hidden = true
        }
    }
    
    

    
    @IBAction func ConnectToMyo(sender: AnyObject) {
        self.myo.openConnectingSetting(self)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

