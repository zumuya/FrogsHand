/*
PreferencesViewController.swift
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

class PreferencesViewController: NSViewController
{
	@IBOutlet var modifiersSegmentedControl: NSSegmentedControl!
	
	let modifierKeyInfos: [(name: String, modifier: NSEvent.ModifierFlags)] = [
		("command", .command), ("shift", .shift), ("option", .option), ("control", .control),
	]
	let defaultsTriggerModifierFlagsKey = ("Nazori-" + #keyPath(NazoriController.triggerModifierFlags))
	
	override func viewDidLoad()
	{
		super.viewDidLoad()

		let selectedModifiers = NSEvent.ModifierFlags(rawValue: UInt(UserDefaults.standard.integer(forKey: defaultsTriggerModifierFlagsKey)))
		for segment in 0..<modifierKeyInfos.count {
			if let info = modifierKeyInfos.first(where: {$0.name == modifiersSegmentedControl.label(forSegment: segment)}), selectedModifiers.contains(info.modifier) {
				modifiersSegmentedControl.setSelected(true, forSegment: segment)
			} else {
				modifiersSegmentedControl.setSelected(false, forSegment: segment)
			}
		}
	}
	@IBAction func segmentedControlDidChangeSelection(_ sender: NSSegmentedControl)
	{
		var modifierFlags: NSEvent.ModifierFlags = []
		for segment in 0..<modifierKeyInfos.count {
			if let info = modifierKeyInfos.first(where: {$0.name == modifiersSegmentedControl.label(forSegment: segment)}), modifiersSegmentedControl.isSelected(forSegment: segment) {
				modifierFlags.formUnion(info.modifier)
			}
		}
		UserDefaults.standard.set(Int(modifierFlags.rawValue), forKey: defaultsTriggerModifierFlagsKey)
	}
}

