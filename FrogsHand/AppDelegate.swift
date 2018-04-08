/*
AppDelegate.swift
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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
	var statusItemController = StatusItemController()
	var nazoriController: NazoriController?
	
	func applicationDidFinishLaunching(_ aNotification: Notification)
	{
		statusItemController.menuWillOpenHandlers.append { [weak self] menu in
			guard let `self` = self else { return }
			self.closePreferences()
		}
		nazoriController = NazoriController()
	}
	
	var preferencesPopover: NSPopover? //not nil only when visible
	@IBAction func showPreferences(_ sender: Any?)
	{
		if (preferencesPopover != nil) {
			return
		}
		if let statusItemButton = statusItemController.statusItem.button {
			NSApp.activate(ignoringOtherApps: true)
			
			let buttonBounds = statusItemButton.bounds
			let popover = NSPopover(); do {
				popover.contentViewController = NSStoryboard(name: .main, bundle: nil).instantiateController(withIdentifier: .preferencesView) as? NSViewController
				popover.behavior = .transient
				popover.delegate = self
			}
			popover.show(relativeTo: buttonBounds, of: statusItemButton, preferredEdge: .maxY)
			self.preferencesPopover = popover
		}
	}
	func closePreferences()
	{
		preferencesPopover?.close()
		self.preferencesPopover = nil
	}
}

extension AppDelegate: NSPopoverDelegate
{
	func popoverShouldDetach(_ popover: NSPopover) -> Bool
	{
		return true
	}
}
