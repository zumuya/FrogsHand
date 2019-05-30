/*
Extensions.swift
FrogsHand

Copyright © 2018-2019 zumuya

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

extension CGEventMask
{
	init(_ eventTypes: CGEventType...)
	{
		self = eventTypes.reduce(CGEventMask(0)) { $0 | CGEventMask(1 << $1.rawValue)}
	}
}
extension NSEvent.ModifierFlags
{
	static let CGEventFlagsForModifierFlags: [(modifierFlags: NSEvent.ModifierFlags, cgEventFlags: CGEventFlags)] = [
		(.command, .maskCommand),
		(.shift, .maskShift),
		(.control, .maskControl),
		(.option, .maskAlternate)
	]
	init(cgEventFlags: CGEventFlags)
	{
		self = NSEvent.ModifierFlags.CGEventFlagsForModifierFlags.reduce(NSEvent.ModifierFlags()) {
			cgEventFlags.contains($1.cgEventFlags) ? $0.union($1.modifierFlags) : $0
		}
	}
	var cgEventFlags: CGEventFlags
	{
		return NSEvent.ModifierFlags.CGEventFlagsForModifierFlags.reduce(CGEventFlags()) {
			contains($1.modifierFlags) ? $0.union($1.cgEventFlags) : $0
		}
	}
}
