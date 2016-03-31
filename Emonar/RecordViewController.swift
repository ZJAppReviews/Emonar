//
//  RecordViewController.swift
//  Emonar
//
//  Created by ZengJintao on 3/8/16.
//  Copyright © 2016 ZengJintao. All rights reserved.
//

import UIKit
//import Gifu

class RecordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EZMicrophoneDelegate, EZRecorderDelegate, EZAudioPlayerDelegate {
    
    @IBOutlet weak var recordTableView: UITableView!
    
    @IBOutlet weak var soundWaveView: EZAudioPlotGL!
    
    @IBOutlet weak var recordButton: UIButton!
    
    var data = ["Happy"]

    let fileManager = FileManager.sharedInstance
    var isRecording = false
    var microphone:EZMicrophone!
    var recorder: EZRecorder!
    var player: EZAudioPlayer!
    //var temp = 1
    
    var timer:NSTimer?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let session: AVAudioSession = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setActive(true)
        } catch {
            NSLog("Error setting up audio session category")
            NSLog("Error setting up audio session active")
        }
        
        self.soundWaveView.backgroundColor = UIColor(red: 0.984, green: 0.71, blue: 0.365, alpha: 1)
        self.soundWaveView.color = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.soundWaveView.plotType = EZPlotType.Rolling
        self.soundWaveView.shouldFill = true
        self.soundWaveView.shouldMirror = true

        self.microphone = EZMicrophone(delegate: self)
        self.player = EZAudioPlayer(delegate: self)
        //
        // Override the output to the speaker. Do this after creating the EZAudioPlayer
        do {
            try session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        } catch {
            NSLog("Error overriding output to the speaker")
        }
        
        
        
        
        
        
//        recordTableView.backgroundColor = UIColor.blackColor()
        
        
        self.navigationController?.navigationBarHidden = true
        
        recordTableView.delegate = self
        recordTableView.dataSource = self
//        recordTableView.rowHeight = UITableViewAutomaticDimension
        recordTableView.estimatedRowHeight = 125
        recordTableView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI))
//        recordButton.setTitle("Start", forState: .Normal)
        recordButton.selected = false
        // Do any additional setup after loading the view.
        fileManager.deleteFileFromStorate(1)
        let array = fileManager.getAllLocalFileStorage()
        for elemtn in array! {
            print(elemtn)
        }
    }

    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        weak var weakSelf = self
        dispatch_async(dispatch_get_main_queue(), {() -> Void in
            //
            // All the audio plot needs is the buffer data (float*) and the size.
            // Internally the audio plot will handle all the drawing related code,
            // history management, and freeing its own resources. Hence, one badass
            // line of code gets you a pretty plot :)
            //
            weakSelf!.soundWaveView.updateBuffer(buffer[0], withBufferSize: bufferSize)
        })
        
    }
    func microphone(microphone: EZMicrophone!, hasBufferList bufferList: UnsafeMutablePointer<AudioBufferList>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        if self.isRecording {
            self.recorder.appendDataFromBufferList(bufferList, withBufferSize: bufferSize)
        }
        
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RecordTableViewCell", forIndexPath: indexPath) as! RecordTableViewCell
        cell.transform = CGAffineTransformMakeRotation(CGFloat(M_PI));
        cell.emotionLabel.text = data[data.count-1-indexPath.row]

        cell.emotionImg.image = UIImage(named: "temp")
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.alpha = 0
        UIView.animateWithDuration(0.3) { () -> Void in
            cell.alpha = 1
        }
    }
    
    
    
    @IBAction func cancelPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func recordPressed(sender: UIButton) {

        if sender.selected == true {
            //stop recording
            sender.selected = false
            self.isRecording = false
            self.microphone.stopFetchingAudio()
            if (self.recorder != nil) {
                self.recorder.closeAudioFile()
                fileManager.insertFileToStorage(testFilePathURL())
            }
            timer?.invalidate()
        } else {
            //start recording
            sender.selected = true
            self.microphone.startFetchingAudio()
            timer = NSTimer.scheduledTimerWithTimeInterval(20, target: self, selector: "timerFinished:", userInfo: nil, repeats: true)
            self.recorder = EZRecorder(URL: self.testFilePathURL(), clientFormat: self.microphone.audioStreamBasicDescription(), fileType: EZRecorderFileType.WAV, delegate: self)
            let a = 
            self.isRecording = true;
        }
    }
    

    func applicationDocumentsDirectory() -> String? {
        let paths: [AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        if  paths.count > 0 {
            return paths[0] as? String
        }
        return nil
    }
    //------------------------------------------------------------------------------
    
    func testFilePathURL() -> NSURL {
        let content = "\(self.applicationDocumentsDirectory()!)/\(fileManager.getNumberOfFile()).wav"
        print("content :\(content)")
        return NSURL.fileURLWithPath(content)
    }
    func timerFinished(timer: NSTimer) {
//        let a = temp
//        delay(3) { () -> () in
//            self.data[a] = "changed\(a)"
////            self.recordTableView.reloadData()
//        }
        data.append("WOWww")
//        print(data)
        recordTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Left)
        //self.isRecording = false;
        if (self.recorder != nil) {
            self.recorder.closeAudioFile()
            fileManager.insertFileToStorage(testFilePathURL())
            self.recorder = EZRecorder(URL: self.testFilePathURL(), clientFormat: self.microphone.audioStreamBasicDescription(), fileType: EZRecorderFileType.WAV, delegate: self)
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    deinit {
        self.recordTableView = nil
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
