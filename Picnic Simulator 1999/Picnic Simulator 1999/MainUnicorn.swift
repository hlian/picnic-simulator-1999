//
//  ViewController.swift
//  Picnic Simulator 1999
//
//  Created by Hao Lian on 6/10/15.
//
//

import AVFoundation
import UIKit

class Unicorn: UIViewController {
}

class Centaur: NSObject {
}

class Eden: NSObject {

}

private var typewriterAudio: AVAudioPlayer = {
    let path = NSBundle.mainBundle().pathForResource("typewriter", ofType: "mp3")!
    let player = try! AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: path))
    player.prepareToPlay()
    return player
}()

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

extension AVAudioPlayer {
    func fade(delta: Float) {
        self.volume += delta
        if (self.volume >= 0 && self.volume <= 1) {
            delay(0.1) {
                self.fade(delta)
            }
        } else {
            self.volume = min(1, max(0, self.volume))
            self.stop()
        }
    }
}

class Scene: Centaur {
    let text: String = ""
    let choices: [String] = [""]

    init(text: String) {
        let parts = text.sp
    }

    var textHeartbeat: RACSignal {
        return RACSignal.empty()
    }
}

class MainCentaur: Centaur {
    let texts = ["You awake on the floor, everything hurting. You're holding a knife covered in thigh blood. You stand and wobble. - Wobble more/Stabilize/Flash back to three days earlier/Am I a blood identification expert?"]
    let scenes: [Scene]
    let scenesI = 0

    override init() {
        self.scenes = texts.map { Scene(text: $0) }
        super.init()
    }

    var currentScene : Scene {
        return self.scenes[self.scenesI]
    }
}

class MainUnicorn: Unicorn {
    let textView = UITextView()
    let centaur = MainCentaur()
    let buttons = UIView()

    override func loadView() {
        self.view = UIView(frame: CGRectMake(0, 0, 100, 100))
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight];
        view.backgroundColor = UIColor.whiteColor()

        textView.autoresizingMask = [UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleBottomMargin]
        textView.frame = CGRectMake(10, 40, 350, 1000);
        textView.textContainer.lineFragmentPadding = 0
        textView.userInteractionEnabled = false
        textView.font = UIFont(name: "American Typewriter", size: 20)

        view.addSubview(textView)

        buttons.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleBottomMargin];
        buttons.frame = CGRectMake(0, 100, 100, 100);
        buttons.hidden = true
        view.addSubview(buttons)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.provoke(self.centaur.currentScene).subscribeCompleted {
            [unowned self] () -> Void in
            self.textView.sizeToFit()

            let y = CGRectGetMaxY(self.textView.frame)
            self.buttons.frame = CGRectMake(0, y, self.view.width, 44)
        };
    }

    func provoke(scene: Scene) -> RACSignal {
        typewriterAudio.play()
        return scene.textHeartbeat.doNext ({
            [unowned self] (x) -> Void in
            let s = x as! String
            self.textView.text = s
        }).doCompleted({
            [unowned self] () -> Void in
            for v in self.buttons.subviews {
                v.removeFromSuperview()
            }
            for (i, choice) in scene.choices.enumerate() {
                self.buttons.addSubview(self.button(i, t: choice))
            }
            self.buttons.hidden = false
            typewriterAudio.fade(-0.12)
        }).replayLast()
    }

    func button(i: Int, t: String) -> UIButton {
        let b = UIButton(type: UIButtonType.System)
        b.layer.borderColor = UIColor.blackColor().CGColor
        b.layer.borderWidth = 1
        b.layer.cornerRadius = 5
        b.frame = CGRectMake(10, 50 * CGFloat(i), 300, 44)
        b.setTitle(t, forState: UIControlState.Normal)
        return b
    }
}

