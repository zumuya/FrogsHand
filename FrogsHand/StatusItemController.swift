/*
StatusItemController.swift
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

class StatusItemController: NSObject
{
	var statusItem: NSStatusItem
	var menuWillOpenHandlers: [(NSMenu)->Void] = []
	
	override init()
	{
		statusItem = NSStatusBar.system.statusItem(withLength: 28); do {
			statusItem.button?.image = NSImage(named: .statusItemIconTemplate)
			let menu = NSMenu(); do {
				menu.addItem(NSMenuItem(title: "Preferences…", action: #selector(AppDelegate.showPreferences(_ :)), keyEquivalent: ""))
				menu.addItem(.separator())
				menu.addItem(NSMenuItem(title: "Quit Frog's Hand", action: #selector(NSApplication.terminate(_ :)), keyEquivalent: ""))
			}
			statusItem.menu = menu
			statusItem.highlightMode = true
		}

		super.init()
		
		statusItem.menu?.delegate = self
	}
}

extension StatusItemController: NSMenuDelegate
{
	func menuWillOpen(_ menu: NSMenu)
	{
		menuWillOpenHandlers.forEach { $0(menu) }
	}
}
