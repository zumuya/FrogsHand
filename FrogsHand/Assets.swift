/*
Assets.swift
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

extension NSStoryboard.Name
{
	//NSStoryboard.main is only available on macOS 10.13.
	static var main = NSStoryboard.Name(rawValue: "Main")
}
extension NSStoryboard.SceneIdentifier
{
	static var preferencesView = NSStoryboard.SceneIdentifier(rawValue: "PreferencesView")
}
extension NSImage.Name
{
	static var statusItemIconTemplate = NSImage.Name(rawValue: "StatusItemIconTemplate")
}
