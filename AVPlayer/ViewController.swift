//
//  ViewController.swift
//  AVPlayer
//
//  Created by apple on 2017/8/17.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit
import AVFoundation
let WIDTHSWIFT:CGFloat=UIScreen.main.bounds.size.width//整个界面的宽度
let HEIGHTSWIFT:CGFloat=UIScreen.main.bounds.size.height//整个界面的高度
class ViewController: UIViewController {
   
    var playerItem:AVPlayerItem!
    var avplayer:AVPlayer!
    var playerLayer:AVPlayerLayer!
    
    var link:CADisplayLink!
    var slider:AC_ProgressSlider?
    override func viewDidLoad() {
        super.viewDidLoad()
        // 检测连接是否存在 不存在报错
        self.slider=AC_ProgressSlider.init(frame: CGRect(x:WIDTHSWIFT*0.1,y:HEIGHTSWIFT*0.9,width:WIDTHSWIFT*0.8,height:40), direction: AC_SliderDirection.horizonal)
        self.view.addSubview(self.slider!)
        self.slider?.isEnabled=false
        self.slider?.addTarget(self, action: #selector(progressValueChange(_:)), for: UIControlEvents.valueChanged)
         let url = URL(string: "http://7xqhmn.media1.z0.glb.clouddn.com/femorning-20161106.mp4")
        
        playerItem = AVPlayerItem.init(url: url!)// 创建视频资源
        // 监听缓冲进度改变
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
        // 监听状态改变
        playerItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        self.avplayer = AVPlayer(playerItem: playerItem)
        self.avplayer.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue: DispatchQueue.main) { (time:CMTime) in
            //当前播放的时间
            let current:TimeInterval=CMTimeGetSeconds(time)
            let total:TimeInterval=CMTimeGetSeconds((self.avplayer.currentItem?.duration)!)
            print(current)
            print(total)
            if self.slider != nil {
                self.slider?.sliderPercent = CGFloat(current/total)
            }
            
        }
        playerLayer = AVPlayerLayer(player: avplayer)
        //设置模式
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        playerLayer.contentsScale = UIScreen.main.scale
        playerLayer.frame=self.view.bounds
        self.view.layer.addSublayer(playerLayer)
         NotificationCenter.default.addObserver(self, selector: #selector(endplayer), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
      
    }
    func progressValueChange(_ myslider:AC_ProgressSlider)  {
        if self.avplayer.status==AVPlayerStatus.readyToPlay {
            let duration:TimeInterval=TimeInterval(self.slider!.sliderPercent) * CMTimeGetSeconds(self.avplayer.currentItem!.duration)
            let seektime:CMTime=CMTimeMake(Int64(duration), 1)
            self.avplayer.seek(to: seektime, completionHandler: { (finish:Bool) in
                
            })
        }
    }
    func endplayer() {
        print("结束")
    }
    func tapClick(_ tap:UITapGestureRecognizer)  {
        if tap.view?.tag==160 {
            self.avplayer.pause()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit{
        playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
        playerItem.removeObserver(self, forKeyPath: "status")
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let playerItem = object as? AVPlayerItem else { return }
        if keyPath == "loadedTimeRanges"{
            //            通过监听AVPlayerItem的"loadedTimeRanges"，可以实时知道当前视频的进度缓冲
            let loadedTime = avalableDurationWithplayerItem()
            let totalTime = CMTimeGetSeconds(playerItem.duration)
            let percent = loadedTime/totalTime
            
//            self.playerView.progressView.progress = Float(percent)
        }else if keyPath == "status"{
            //            AVPlayerItemStatusUnknown,AVPlayerItemStatusReadyToPlay, AVPlayerItemStatusFailed。只有当status为AVPlayerItemStatusReadyToPlay是调用 AVPlayer的play方法视频才能播放。
            print(playerItem.status.rawValue)
            if playerItem.status == AVPlayerItemStatus.readyToPlay{
                // 只有在这个状态下才能播放
                self.avplayer.play()
                 self.slider?.isEnabled=true
                let bgview=UIView.init(frame: CGRect(x:0,y:0,width:WIDTHSWIFT,height:HEIGHTSWIFT*0.9))
                bgview.backgroundColor=UIColor.clear
                let tapone=UITapGestureRecognizer.init(target:self , action: Selector("tapClick:"))
                bgview.tag=160
                bgview.addGestureRecognizer(tapone)
                self.view.addSubview(bgview)

            }else{
                print("加载异常")
            }
        }
    }
    
    func avalableDurationWithplayerItem()->TimeInterval{
        guard let loadedTimeRanges = avplayer?.currentItem?.loadedTimeRanges,let first = loadedTimeRanges.first else {fatalError()}
        let timeRange = first.timeRangeValue
        let startSeconds = CMTimeGetSeconds(timeRange.start)
        let durationSecound = CMTimeGetSeconds(timeRange.duration)
        let result = startSeconds + durationSecound
        return result
    }
    
       func formatPlayTime(_ secounds:TimeInterval)->String{
        if secounds.isNaN{
            return "00:00"
        }
        let Min = Int(secounds / 60)
        let Sec = Int(secounds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", Min, Sec)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}



