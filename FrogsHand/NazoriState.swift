/*
NazoriState.swift
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

protocol NazoriState
{
}
struct Tracking: NazoriState
{
	var mouseLocationWhenDown: CGPoint
	var windowNumber: Int
	var hasDragged = false
	var lastVelocity = CGPoint.zero
	var lastScrollTime = Date()
	
	init(mouseLocationWhenDown: CGPoint, windowNumber: Int)
	{
		self.mouseLocationWhenDown = mouseLocationWhenDown
		self.windowNumber = windowNumber
	}
}
struct Momentum: NazoriState
{
	static let frameInterval = TimeInterval(1.0 / 60.0)
	static let minimumVelocity: CGFloat = 100.0
	
	var mouseDownIdentifier = NSUUID()
	var velocity = CGPoint.zero
	var mouseLocationWhenDown: CGPoint
	var windowNumber: Int
	
	init(velocity: CGPoint, mouseLocationWhenDown: CGPoint, windowNumber: Int)
	{
		self.velocity = velocity
		self.mouseLocationWhenDown = mouseLocationWhenDown
		self.windowNumber = windowNumber
	}
}
