//
//  Myo.swift
//  catGO
//
//  Created by daiki terai on 2016/09/08.
//  Copyright © 2016年 teradonburi. All rights reserved.
//

import UIKit

class Myo: NSObject {
    
    var isConnected:Bool = false
    var accel:TLMVector3!
    var magnitude:CGFloat!
    var rotation:CATransform3D!
    var currentPose:TLMPose!
    var isUnlock:Bool = false
    
    override init() {
        super.init()
        
        // Posted whenever a TLMMyo connects
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Myo.didConnectDevice(_:)), name: TLMHubDidConnectDeviceNotification, object: nil)
        // Posted whenever a TLMMyo disconnects.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Myo.didDisconnectDevice(_:)), name: TLMHubDidDisconnectDeviceNotification, object: nil)
        // Posted whenever the user does a successful Sync Gesture.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Myo.didSyncArm(_:)), name: TLMMyoDidReceiveArmSyncEventNotification, object: nil)
        // Posted whenever Myo loses sync with an arm (when Myo is taken off, or moved enough on the user's arm).
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Myo.didUnsyncArm(_:)), name: TLMMyoDidReceiveArmUnsyncEventNotification, object: nil)
        // Posted whenever Myo is unlocked and the application uses TLMLockingPolicyStandard.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Myo.didUnlockDevice(_:)), name: TLMMyoDidReceiveUnlockEventNotification, object: nil)
        // Posted whenever Myo is locked and the application uses TLMLockingPolicyStandard.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Myo.didLockDevice(_:)), name: TLMMyoDidReceiveLockEventNotification, object: nil)
        // Posted when a new orientation event is available from a TLMMyo. Notifications are posted at a rate of 50 Hz.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Myo.didReceiveOrientationEvent(_:)), name: TLMMyoDidReceiveOrientationEventNotification, object: nil)
        // Posted when a new accelerometer event is available from a TLMMyo. Notifications are posted at a rate of 50 Hz.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Myo.didReceiveAccelerometerEvent(_:)), name: TLMMyoDidReceiveAccelerometerEventNotification, object: nil)
        // Posted when a new pose is available from a TLMMyo.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Myo.didReceivePoseChange(_:)), name: TLMMyoDidReceivePoseChangedNotification, object: nil)
        
        
    }
    
    func didConnectDevice(notification:NSNotification) {
        // Access the connected device.
        let myo:TLMMyo = notification.userInfo![kTLMKeyMyo] as! TLMMyo;
        print("Connected to %@.", myo.name)
        self.isConnected = true
        
    }
    
    func didDisconnectDevice(notification:NSNotification) {
        // Access the disconnected device.
        let myo:TLMMyo = notification.userInfo![kTLMKeyMyo] as! TLMMyo;
        print("Disconnected from  %@.", myo.name)
        self.isConnected = false
    }
    
    func didSyncArm(notification:NSNotification) {
        // Retrieve the arm event from the notification's userInfo with the kTLMKeyArmSyncEvent key.
        let armEvent:TLMArmSyncEvent = notification.userInfo![kTLMKeyArmSyncEvent] as! TLMArmSyncEvent;
        
        // Update the armLabel with arm information.
        let armString = armEvent.arm == TLMArm.Right ? "Right" : "Left";
        let directionString = armEvent.xDirection == TLMArmXDirection.TowardWrist ? "Toward Wrist" : "Toward Elbow";
        print("Arm: %@ X-Direction: %@", armString, directionString)
    }
    
    func didUnsyncArm(notification:NSNotification) {
        // Reset the labels.
        print("Unsync Arm")
    }

    
    func didUnlockDevice(notification:NSNotification) {
        print("Unlocked")
        self.isUnlock = true
    }
    
    func didLockDevice(notification:NSNotification) {
        print("Locked")
        self.isUnlock = false
    }
    
    func didReceiveOrientationEvent(notification:NSNotification) {
        self.isConnected = true
        
        // Retrieve the orientation from the NSNotification's userInfo with the kTLMKeyOrientationEvent key.
        let orientationEvent:TLMOrientationEvent = notification.userInfo![kTLMKeyOrientationEvent] as! TLMOrientationEvent;
        
        // Create Euler angles from the quaternion of the orientation.
        let angles:TLMEulerAngles = TLMEulerAngles(quaternion: orientationEvent.quaternion)
        
        // Next, we want to apply a rotation and perspective transformation based on the pitch, yaw, and roll.
        let rotationAndPerspectiveTransform:CATransform3D = CATransform3DConcat(CATransform3DConcat(CATransform3DRotate (CATransform3DIdentity,CGFloat(angles.pitch.radians), -1.0, 0.0, 0.0), CATransform3DRotate(CATransform3DIdentity, CGFloat(angles.yaw.radians), 0.0, 1.0, 0.0)), CATransform3DRotate(CATransform3DIdentity, CGFloat(angles.roll.radians), 0.0, 0.0, -1.0));
        
        // Apply the rotation and perspective transform to helloLabel.
        //print(rotationAndPerspectiveTransform)
        
        self.rotation = rotationAndPerspectiveTransform
    }
    
    func didReceiveAccelerometerEvent(notification:NSNotification) {
        self.isConnected = true
        
        // Retrieve the accelerometer event from the NSNotification's userInfo with the kTLMKeyAccelerometerEvent.
        let accelerometerEvent:TLMAccelerometerEvent = notification.userInfo![kTLMKeyAccelerometerEvent] as! TLMAccelerometerEvent;
        
        // Get the acceleration vector from the accelerometer event.
        let accelerationVector:TLMVector3 = accelerometerEvent.vector;
        
        // Calculate the magnitude of the acceleration vector.
        let magnitude = TLMVector3Length(accelerationVector);
        
        // Update the progress bar based on the magnitude of the acceleration vector.
        //print(magnitude / 8)
        
        /* Note you can also access the x, y, z values of the acceleration (in G's) like below
         float x = accelerationVector.x;
         float y = accelerationVector.y;
         float z = accelerationVector.z;
         */
        print(magnitude)
        print(accelerationVector)
        
        self.magnitude = CGFloat(magnitude)
        self.accel = accelerationVector

    }
    
    func didReceivePoseChange(notification:NSNotification) {
        // Retrieve the pose from the NSNotification's userInfo with the kTLMKeyPose key.
        let pose:TLMPose = notification.userInfo![kTLMKeyPose] as! TLMPose;
        self.currentPose = pose;
        
        // Handle the cases of the TLMPoseType enumeration, and change the color of helloLabel based on the pose we receive.
        switch (pose.type) {
        case TLMPoseType.Unknown:
            print("Pose Unknown")
            break
        case TLMPoseType.Rest:
            print("Pose Rest")
            break
        case TLMPoseType.DoubleTap:
            // Changes helloLabel's font to Helvetica Neue when the user is in a rest or unknown pose.
            print("Pose DoubleTap")
            break
        case TLMPoseType.Fist:
            // Changes helloLabel's font to Noteworthy when the user is in a fist pose.
            print("Pose Fist")
            break
        case TLMPoseType.WaveIn:
            // Changes helloLabel's font to Courier New when the user is in a wave in pose.
            print("Pose WaveIn")
            break
        case TLMPoseType.WaveOut:
            // Changes helloLabel's font to Snell Roundhand when the user is in a wave out pose.
            print("Pose WaveOut")
            break
        case TLMPoseType.FingersSpread:
            // Changes helloLabel's font to Chalkduster when the user is in a fingers spread pose.
            print("Pose FingersSpread")
            break
        }
        
        // Unlock the Myo whenever we receive a pose
        if (pose.type == TLMPoseType.Unknown || pose.type == TLMPoseType.Rest) {
            // Causes the Myo to lock after a short period.
            pose.myo.unlockWithType(TLMUnlockType.Hold)
        } else {
            // Keeps the Myo unlocked until specified.
            // This is required to keep Myo unlocked while holding a pose, but if a pose is not being held, use
            // TLMUnlockTypeTimed to restart the timer.
            pose.myo.unlockWithType(TLMUnlockType.Hold)
            // Indicates that a user action has been performed.
            pose.myo.indicateUserAction()
            
        }

    }
    
    func openConnectingSetting(viewController:UIViewController){
        // Note that when the settings view controller is presented to the user, it must be in a UINavigationController.
        let controller:UINavigationController = TLMSettingsViewController.settingsInNavigationController()
        // Present the settings view controller modally.
        viewController.presentViewController(controller, animated: true, completion: nil)

    }
    
   
}
