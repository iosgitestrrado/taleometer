//
//  NowPlayViewController.swift
//  TaleOMeter
//
//  Created by Durgesh on 16/02/22.
//

import UIKit
import SoundWave
import CoreMedia
import AVFoundation

class NowPlayViewController: UIViewController {

    // MARK: - Weak Properties -
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var storyNameLabel: UILabel!
    @IBOutlet weak var plotNameLabel: UILabel!
    @IBOutlet weak var narrotionNameLabel: UILabel!
    @IBOutlet weak var visualizationWave: AudioVisualizationView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    // MARK: - Private Properties -
    private var waveFormcount = 0
    private var totalTimeDuration:Float = 0.0
    private var shouldAutoUpdateWaveform = true

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.imageView.cornerRadius = self.imageView.frame.size.height / 2.0
        configureAudioWare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Core.showNavigationBar(cont: self, setNavigationBarHidden: false, isRightViewEnabled: true)
    }
    
    // MARK: Set audio wave meter
    private func configureAudioWare() {
        guard let url = Bundle.main.url(forResource: "file_example_MP3_5MG", withExtension: "mp3") else { return }
        visualizationWave.audioVisualizationMode = .write
        visualizationWave.add(meteringLevel: 0.6)

        visualizationWave.meteringLevelBarWidth = 1.0
        visualizationWave.meteringLevelBarInterItem = 1.0
        visualizationWave.audioVisualizationTimeInterval = 0.30
        visualizationWave.gradientStartColor = .white
        visualizationWave.gradientEndColor = .red

        visualizationWave.reset()
        AudioPlayManager.shared.configAudio(url)

        Core.getAudioMeters(url, forChannel: 0) { [self] result in
            waveFormcount = result.count
            visualizationWave.audioVisualizationMode = .read
            visualizationWave.meteringLevels = result
            let player = AudioPlayManager.shared.playerAV
            if let duration11 = player.currentItem?.asset.duration {
                totalTimeDuration = Float(CMTimeGetSeconds(duration11));
                visualizationWave.play(for: TimeInterval(totalTimeDuration))
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                    visualizationWave.pause()
                }
            }
        }
        
        // Pan gesture for scrubbing support.
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGestureRecognizer.cancelsTouchesInView = false
        visualizationWave.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
      
      switch recognizer.state {
          case .began:
            shouldAutoUpdateWaveform = false
          case .changed:
            let xLocation = Float(recognizer.location(in: self.visualizationWave).x)
          updateWaveWith(xLocation)
          case .ended:
              let xLocation = Float(recognizer.location(in: self.visualizationWave).x)
              if let totalAudioDuration = AudioPlayManager.shared.playerAV.currentItem?.asset.duration {
                  let percentageInSelf = Double(xLocation / Float(self.visualizationWave.bounds.width))
                  let totalAudioDurationSeconds = CMTimeGetSeconds(totalAudioDuration)
                  let scrubbedDutation = totalAudioDurationSeconds * percentageInSelf
                  let scrubbedDutationMediaTime = CMTimeMakeWithSeconds(scrubbedDutation, preferredTimescale: 1000)
                  AudioPlayManager.shared.playerAV.seek(to: scrubbedDutationMediaTime)
              }
          default:
            break
      }
    }
    
    private func updateWaveWith(_ location: Float) {
        let percentageInSelf = location / Float(self.visualizationWave.bounds.width)
        var waveformsToBeRecolored = Float(totalTimeDuration) * percentageInSelf
        if waveformsToBeRecolored >= totalTimeDuration {
            waveformsToBeRecolored = waveformsToBeRecolored - 1.0
        }
        if let chronometer = self.visualizationWave.playChronometer {
            chronometer.timerCurrentValue = TimeInterval(waveformsToBeRecolored)
            chronometer.timerDidUpdate?(TimeInterval(waveformsToBeRecolored))
        }
    }
    
    // MARK: - SPN stands Story(0) Plot(1) and Narrotion(2)
    @IBAction func tapOnSPNButton(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            //Story
            break
        case 1:
            //Plot
            break
        default:
            //Narrotion
            break
        }
    }
    
    // MARK: - Play(0) Previouse(1) Favorite(2) Back10Sec(3) Forward10Sec(4) Share(5)
    @IBAction func tapOnAudioController(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            //Play
            let player = AudioPlayManager.shared.playerAV
            print(formatTimeFor(seconds: player.currentItem!.currentTime().seconds))
            if player.isPlaying {
                player.pause()
                visualizationWave.pause()
                sender.setBackgroundImage(UIImage(named: AudioPlayManager.playImageName), for: .normal)
            } else {
                player.play()
                if let duration11 = player.currentItem?.asset.duration {
                    totalTimeDuration = Float(CMTimeGetSeconds(duration11));
                    visualizationWave.play(for: TimeInterval(totalTimeDuration))
                }
                sender.setBackgroundImage(UIImage(named: AudioPlayManager.pauseImageName), for: .normal)
            }
            break
        case 1:
            //Previouse
            break
        case 2:
            //Favorite
            break
        case 3:
            //Back 10 Second
            break;
        case 4:
            //Forward 10 Second
            break
        default:
            //Share
            break
        }
    }
    
    // MARK: Convert seconds to current time for playing audio
    private func getHoursMinutesSecondsFrom(seconds: Double) -> (hours: Int, minutes: Int, seconds: Int) {
        let secs = Int(seconds)
        let hours = secs / 3600
        let minutes = (secs % 3600) / 60
        let seconds = (secs % 3600) % 60
        return (hours, minutes, seconds)
    }
    
    private func formatTimeFor(seconds: Double) -> String {
        let result = getHoursMinutesSecondsFrom(seconds: seconds)
        let hoursString = "\(result.hours)"
        var minutesString = "\(result.minutes)"
        if minutesString.utf8.count == 1 {
            minutesString = "0\(result.minutes)"
        }
        var secondsString = "\(result.seconds)"
        if secondsString.utf8.count == 1 {
            secondsString = "0\(result.seconds)"
        }
        var time = "\(hoursString):"
        if result.hours >= 1 {
            time.append("\(minutesString):\(secondsString)")
        }
        else {
            time = "\(minutesString):\(secondsString)"
        }
        return time
    }
}

