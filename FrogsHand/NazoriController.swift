/*
NazoriController.swift
FrogsHand

Created by zumuya on 2018/04/07.

Copyright 2018 zumuya

Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR
APARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Cocoa

class NazoriController: NSObject
{
	//MARK: - User Properties
	
	@objc dynamic var speedFactor = 2
	@objc dynamic var momentumDecreaseFactor = 0.94
	@objc dynamic var triggerModifierFlags: NSEvent.ModifierFlags = [.shift, .control]
	
	//MARK: - Init & Deinit
	
	let speedFactorObservingContext = UnsafeMutableRawPointer.allocate(bytes: 1, alignedTo: 1)
	let triggerModifierFlagsObservingContext = UnsafeMutableRawPointer.allocate(bytes: 1, alignedTo: 1)
	let momentumDecreaseFactorObservingContext = UnsafeMutableRawPointer.allocate(bytes: 1, alignedTo: 1)
	var deinitHandlers: [()->Void] = []
	
	var eventTapRunLoop: RunLoop!
	
	override init()
	{
		super.init()
		
		//1. Make Run Loop for Event Tap
		
		let runLoopWaitSemaphore = DispatchSemaphore(value: 0)
		DispatchQueue.global().async {
			self.eventTapRunLoop = RunLoop.current
			runLoopWaitSemaphore.signal()
			
			while true {
				RunLoop.current.run(mode: .defaultRunLoopMode, before: .distantFuture)
			}
		}
		runLoopWaitSemaphore.wait()
		
		//2. Register defaults:
		
		let defaults = UserDefaults.standard
		let defaultKeyPrefix = "Nazori-"

		let keyInfos: [(key: String, defaultValue: Any, observingContext: UnsafeMutableRawPointer)] = [
			(key: #keyPath(speedFactor), defaultValue: speedFactor, observingContext: speedFactorObservingContext),
			(key: #keyPath(triggerModifierFlags), defaultValue: triggerModifierFlags.rawValue, observingContext: triggerModifierFlagsObservingContext),
			(key: #keyPath(momentumDecreaseFactor), defaultValue: momentumDecreaseFactor, observingContext: momentumDecreaseFactorObservingContext),
		]
		keyInfos.forEach { keyInfo in
			let defaultKeyPath = (defaultKeyPrefix + keyInfo.key)
			defaults.register(defaults: [defaultKeyPath: keyInfo.defaultValue])
			defaults.addObserver(self, forKeyPath: defaultKeyPath, options: [.initial, .new], context: keyInfo.observingContext)
			deinitHandlers.append {
				defaults.removeObserver(self, forKeyPath: defaultKeyPath, context: keyInfo.observingContext)
				keyInfo.observingContext.deallocate(bytes: 1, alignedTo: 1)
			}
		}

		//3. Register event tap:
		
		let tapEventMask = CGEventMask(.mouseMoved, .leftMouseDown, .leftMouseDragged, .leftMouseUp, .scrollWheel)
		eventTap = CGEvent.tapCreate(tap: .cghidEventTap, place: .headInsertEventTap, options: .defaultTap, eventsOfInterest: tapEventMask, callback: { (proxy, type, event, userInfo) -> Unmanaged<CGEvent>? in
			let `self` = Unmanaged<NazoriController>.fromOpaque(userInfo!).takeUnretainedValue()
			if let newEvent = self.handleEventTap(proxy: proxy, eventType: type, event: event) {
				if (newEvent == event) {
					return Unmanaged.passUnretained(newEvent)
				} else {
					return Unmanaged.passRetained(newEvent)
				}
			} else {
				return nil
			}
		}, userInfo: Unmanaged.passUnretained(self).toOpaque())
		
		if let eventTap = eventTap {
			let runLoopSource = CFMachPortCreateRunLoopSource(nil, eventTap, 0)
			CFRunLoopAddSource(eventTapRunLoop.getCFRunLoop(), runLoopSource, .defaultMode)
		}
	}
	deinit
	{
		deinitHandlers.forEach { $0() }
	}
	
	//MARK: - Key Value Observing
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
	{
		if let context = context, let keyPath = keyPath {
			switch context {
			case speedFactorObservingContext:
				eventTapRunLoop.perform {
					self.speedFactor = UserDefaults.standard.integer(forKey: keyPath)
				}
				return
			case momentumDecreaseFactorObservingContext:
				eventTapRunLoop.perform {
					self.momentumDecreaseFactor = UserDefaults.standard.double(forKey: keyPath)
				}
				return
			case triggerModifierFlagsObservingContext:
				eventTapRunLoop.perform {
					self.triggerModifierFlags = NSEvent.ModifierFlags(rawValue: UInt(UserDefaults.standard.integer(forKey: keyPath)))
				}
				return
			default:
				break
			}
			
		}
		super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
	}
	
	//MARK: - Other Properties
	
	var eventTap: CFMachPort?
	var momentumTimer: Timer?
	
	//MARK: - State
	
	var nazoriState: NazoriState? = nil
	{
		didSet {
			let oldMomentum = (oldValue as? Momentum)
			let newMomentum = (nazoriState as? Momentum)
			
			if let oldMomentum = oldMomentum, let newMomentum = newMomentum, (oldMomentum.mouseDownIdentifier != newMomentum.mouseDownIdentifier) {
				self.scrollEvent(momentumPhase: .end, windowNumber: oldMomentum.windowNumber)?.post(tap: .cgSessionEventTap)
			} else if (oldMomentum == nil), (newMomentum != nil) {
				let timer = Timer(timeInterval: Momentum.frameInterval, target: self, selector: #selector(momentumTimerDidFire(_:)), userInfo: nil, repeats: true)
				RunLoop.main.add(timer, forMode: .defaultRunLoopMode)
				momentumTimer = timer
			} else if (oldMomentum != nil), (newMomentum == nil) {
				momentumTimer?.invalidate()
				momentumTimer = nil
			}
		}
	}
	
	//MARK: - Event Tap
	
	func handleEventTap(proxy: CGEventTapProxy, eventType: CGEventType, event: CGEvent) -> CGEvent?
	{
		switch event.type {
		case .leftMouseDown:
			if (triggerModifierFlags != []), event.flags.contains(triggerModifierFlags.cgEventFlags) {
				let tracking = Tracking(mouseLocationWhenDown: event.location, windowNumber: NSWindow.windowNumber(at: NSEvent.mouseLocation, belowWindowWithWindowNumber: -0))
				scrollEvent(phase: .mayBegin, windowNumber: tracking.windowNumber, location: tracking.mouseLocationWhenDown)?.post(tap: .cgSessionEventTap)
				scrollEvent(phase: .began, windowNumber: tracking.windowNumber, location: tracking.mouseLocationWhenDown)?.post(tap: .cgSessionEventTap)
				self.nazoriState = tracking
				return nil
			}
		case .leftMouseDragged:
			if let tracking = self.nazoriState as? Tracking {
				let wheel1 = event.getIntegerValueField(.mouseEventDeltaY)
				let wheel2 = event.getIntegerValueField(.mouseEventDeltaX)
				
				var newTracking = tracking; do {
					newTracking.lastScrollTime = Date()
					if tracking.hasDragged {
						let timeDelta = newTracking.lastScrollTime.timeIntervalSince(tracking.lastScrollTime)
						newTracking.lastVelocity.x = ((tracking.lastVelocity.x + (CGFloat(Double(wheel2) / timeDelta))) * 0.5)
						newTracking.lastVelocity.y = ((tracking.lastVelocity.y + (CGFloat(Double(wheel1) / timeDelta))) * 0.5)
					} else {
						newTracking.hasDragged = true
					}
				}
				self.nazoriState = newTracking
				
				if (event.getIntegerValueField(.mouseEventSubtype) != 1/*tablet*/) {
					CGWarpMouseCursorPosition(tracking.mouseLocationWhenDown)
				}
				if let scrollEvent = self.scrollEvent(phase: .changed, wheel1: Int(wheel1), wheel2: Int(wheel2), windowNumber: tracking.windowNumber) {
					return scrollEvent
				}
				return nil
			}
			
		case .leftMouseUp:
			if let nazoriState = self.nazoriState {
				if let tracking = nazoriState as? Tracking {
					CGWarpMouseCursorPosition(tracking.mouseLocationWhenDown)
					
					if (abs(tracking.lastVelocity.x) > Momentum.minimumVelocity) || (abs(tracking.lastVelocity.y) > Momentum.minimumVelocity) {
						//end scroll
						scrollEvent(phase: .ended, windowNumber: tracking.windowNumber)?.post(tap: .cgSessionEventTap)
						
						let momentum = Momentum(velocity: tracking.lastVelocity, mouseLocationWhenDown: tracking.mouseLocationWhenDown, windowNumber: tracking.windowNumber)
						self.nazoriState = momentum
						
						let wheel1 = (momentum.velocity.y * CGFloat(Momentum.frameInterval))
						let wheel2 = (momentum.velocity.x * CGFloat(Momentum.frameInterval))
						if let beginMomentumEvent = self.scrollEvent(momentumPhase: .begin, wheel1: Int(wheel1), wheel2: Int(wheel2), windowNumber: momentum.windowNumber, location: momentum.mouseLocationWhenDown) {
							return beginMomentumEvent
						}
					} else {
						self.nazoriState = nil
						
						if let endScrollEvent = self.scrollEvent(phase: .ended, windowNumber: tracking.windowNumber) {
							return endScrollEvent
						}
					}
				}
				return nil
			}
		case .scrollWheel:
			self.nazoriState = nil
		default:
			break
		}
		return event
	}
	
	//MARK: - Making Event
	
	func scrollEvent(phase: CGScrollPhase? = nil, momentumPhase: CGMomentumScrollPhase = .none, wheel1: Int = 0, wheel2: Int = 0, windowNumber: Int, location: CGPoint? = nil) -> CGEvent?
	{
		if let event = CGEvent(source: nil) {
			//let event = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 2, wheel1: Int32(wheel1), wheel2: Int32(wheel2), wheel3: 0)
			event.type = .scrollWheel
			event.flags = CGEventFlags(rawValue: 0)
			
			let wheel1 = (wheel1 * speedFactor)
			let wheel2 = (wheel2 * speedFactor)
			
			//Used by NSScrollView:
			event.setIntegerValueField(.scrollWheelEventPointDeltaAxis1, value: Int64(wheel1))
			event.setIntegerValueField(.scrollWheelEventPointDeltaAxis2, value: Int64(wheel2))
			
			//Used by Adobe products, etc...:
			event.setDoubleValueField(.scrollWheelEventFixedPtDeltaAxis1, value: Double(wheel1) * 0.1)
			event.setDoubleValueField(.scrollWheelEventFixedPtDeltaAxis2, value: Double(wheel2) * 0.1)
			
			event.setIntegerValueField(.scrollWheelEventIsContinuous, value: 1)
			if let phase = phase {
				event.setIntegerValueField(.scrollWheelEventScrollPhase, value: Int64(phase.rawValue))
			} else {
				event.setIntegerValueField(.scrollWheelEventScrollPhase, value: 0)
			}
			if (momentumPhase != .none) {
				event.setIntegerValueField(.scrollWheelEventMomentumPhase, value: Int64(momentumPhase.rawValue))
			}
			event.setIntegerValueField(.mouseEventWindowUnderMousePointer, value: Int64(windowNumber))
			
			if let location = location {
				event.location = location
			}
			return event
		}
		return nil
	}
	
	//MARK: - Timer
	
	@objc func momentumTimerDidFire(_ timer: Timer)
	{
		if let momentum = nazoriState as? Momentum {
			var newMomentum = momentum; do {
				newMomentum.velocity.x *= CGFloat(momentumDecreaseFactor)
				newMomentum.velocity.y *= CGFloat(momentumDecreaseFactor)
			}
			if (abs(newMomentum.velocity.x) < Momentum.minimumVelocity), (abs(newMomentum.velocity.y) < Momentum.minimumVelocity) {
				self.nazoriState = nil
			} else {
				let wheel1 = (newMomentum.velocity.y * CGFloat(Momentum.frameInterval))
				let wheel2 = (newMomentum.velocity.x * CGFloat(Momentum.frameInterval))
				self.scrollEvent(momentumPhase: .continuous, wheel1: Int(wheel1), wheel2: Int(wheel2), windowNumber: momentum.windowNumber)?.post(tap: .cgSessionEventTap)
				
				self.nazoriState = newMomentum
			}
		}
	}
}
