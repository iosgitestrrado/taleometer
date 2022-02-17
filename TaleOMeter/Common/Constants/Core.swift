//
//  Core.swift
//  TaleOMeter
//
//  Created by Durgesh on 15/02/22.
//

import Foundation
import AVFoundation
import SystemConfiguration
import NVActivityIndicatorView
import UIKit

class Core: NSObject {
    private var activityIndicatorView: NVActivityIndicatorView?
    
    /* Loading progress bar remove from view */
    static func showProgress(viewV: UIView, activityIndicator: inout NVActivityIndicatorView) {
        let xAxis = (viewV.frame.size.width / 2.0)
        let yAxis = (viewV.frame.size.height / 2.0)

        let frame = CGRect(x: (xAxis - 17.5), y: (yAxis - 17.5), width: 35.0, height: 35.0)
        activityIndicator = NVActivityIndicatorView(frame: frame)
        activityIndicator.type = .ballPulse // add your type
        activityIndicator.color = .black // add your color
        activityIndicator.tag = 9566
        //        NVActivityIndicatorPresenter.sharedInstance.setMessage("Fetching Data...")
        viewV.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }

    static func hideProgress(activityIndicator: NVActivityIndicatorView) {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    /*
     * Push to another view controller using navigation controller
     */
    static func push(_ controller: UIViewController, storyboard: String, storyboardId: String) {
        let myobject = UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: storyboardId)
        (controller.sideMenuController?.rootViewController as! UINavigationController).pushViewController(myobject, animated: true)
    }
    
    /*
     * Present to another view controller using navigation controller
     */
    static func present(_ controller: UIViewController, storyboard: String, storyboardId: String) {
        let myobject = UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: storyboardId)
        (controller.sideMenuController?.rootViewController as! UINavigationController).present(myobject, animated: true, completion: nil)
    }
    
    /*
     * Get controller using storyboardId
     */
    static func getController(_ storyboard: String, storyboardId: String) -> UIViewController {
        return UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: storyboardId)
    }

    /*
     * Show/Hide navigationbar when view will apear.
     * Swap menu option enable/disable.
     * From UIController
     */
    static func showNavigationBar(cont: UIViewController, setNavigationBarHidden: Bool, isRightViewEnabled: Bool) {
        cont.sideMenuController?.isRightViewEnabled = isRightViewEnabled
        cont.navigationController?.setNavigationBarHidden(setNavigationBarHidden, animated: true)
        //cont.navigationController?.navigationBar.barTintColor = .white
        cont.navigationController?.navigationBar.tintColor = .white
        //cont.navigationController?.navigationBar.isTranslucent = false
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        cont.navigationController?.navigationBar.titleTextAttributes = textAttributes
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)
        cont.navigationItem.backBarButtonItem = backButton
    }
    
    
    /*
     *  Custom Bottom tabbar for application
     *  Add custom bottom tabbar to view
     */
    static func addBottomTabBar(_ view: UIView) {
        if let myobject = UIStoryboard(name: Storyboard.dashboard, bundle: nil).instantiateViewController(withIdentifier: "FooterViewController") as? FooterViewController {
            myobject.view.shadow = true
            myobject.homeButton.addShadow(shadowColor: UIColor.white.cgColor, shadowOffset: CGSize(width: 1.0, height: 1.0), shadowOpacity: 0.5, shadowRadius: 10.0)
            myobject.view.frame = CGRect(x: 40.0, y: view.frame.size.height - ((80.0 * UIScreen.main.bounds.size.height) / 667.0) , width: view.frame.size.width - 80.0, height: 60.0)
            view.addSubview(myobject.view)
        }
    }
    
    /*
     *  Calculate audio meter
     *
     */
    static func getAudioMeters(_ audioFileURL: URL, forChannel channelNumber: Int, completionHandler: @escaping(_ success: [Float]) -> ()) {
        let audioFile = try! AVAudioFile(forReading: audioFileURL)
        let audioFilePFormat = audioFile.processingFormat
        let audioFileLength = audioFile.length
        
        //Set the size of frames to read from the audio file, you can adjust this to your liking
        let frameSizeToRead = Int(audioFilePFormat.sampleRate/20)
        
        //This is to how many frames/portions we're going to divide the audio file
        let numberOfFrames = Int(audioFileLength)/frameSizeToRead
        
        //Create a pcm buffer the size of a frame
        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFilePFormat, frameCapacity: AVAudioFrameCount(frameSizeToRead)) else {
            fatalError("Couldn't create the audio buffer")
        }
        
        //Do the calculations in a background thread, if you don't want to block the main thread for larger audio files
        DispatchQueue.global(qos: .userInitiated).async {
            
            //This is the array to be returned
            var returnArray : [Float] = [Float]()
            
            //We're going to read the audio file, frame by frame
            for i in 0..<numberOfFrames {
                
                //Change the position from which we are reading the audio file, since each frame starts from a different position in the audio file
                audioFile.framePosition = AVAudioFramePosition(i * frameSizeToRead)
                
                //Read the frame from the audio file
                try! audioFile.read(into: audioBuffer, frameCount: AVAudioFrameCount(frameSizeToRead))
                
                //Get the data from the chosen channel
                let channelData = audioBuffer.floatChannelData![channelNumber]
                
                //This is the array of floats
                let arr = Array(UnsafeBufferPointer(start:channelData, count: frameSizeToRead))
                
                //Calculate the mean value of the absolute values
                let meanValue = arr.reduce(0, {$0 + abs($1)})/Float(arr.count)
                
                //Calculate the dB power (You can adjust this), if average is less than 0.000_000_01 we limit it to -160.0
                let dbPower: Float = meanValue > 0.000_000_01 ? 20 * log10(meanValue) : -160.0
                
                //append the db power in the current frame to the returnArray
                returnArray.append(Float((Double((dbPower * 1.5	) / 100.0).roundToDecimal(2) * -1.0)))
            }
            completionHandler(returnArray)
        }
    }
}
