package com.destroytoday.desktop {
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	import org.osflash.signals.Signal;

	public class NativeMenuPlus extends NativeMenu {
		protected var _itemSelected:Signal = new Signal(NativeMenuPlus, NativeMenuItem);
		
		protected var _data:XML;
		
		protected var itemByNameMap:Object;
		
		protected var itemByPathMap:Object;
		
		protected var pathByItemMap:Dictionary = new Dictionary(true);
		
		protected var separatorCount:uint;
		
		public function NativeMenuPlus() {
		}
		
		public function get itemSelectSignal():Signal {
			return _itemSelected;
		}
		
		public function get data():XML {
			return _data;
		}
		
		public function set data(value:XML):void {
			_data = value;
			
			build(this, "", _data);
		}
		
		override public function getItemByName(name:String):NativeMenuItem {
			return (itemByNameMap) ? itemByNameMap[name] : null;
		}
		
		public function getItemByPath(path:String):NativeMenuItem {
			return (itemByPathMap) ? itemByPathMap[path] : null;
		}
		
		public function getItemPath(item:NativeMenuItem):String {
			return pathByItemMap[item];
		}
		
		protected function build(menu:NativeMenu, menuPath:String, data:XML):void {
			var i:uint, m:uint;
			var name:String, path:String, nodeName:String;
			var item:NativeMenuItem;
			var keyEquivalentModifiers:Array;
			
			if (menu == this) {
				itemByNameMap = {};
				itemByPathMap = {};
				separatorCount = 0;
				
				removeAllItems();
			}
			
			for each (var node:XML in data.children()) {
				name = node.@name;
				path = menuPath + (menuPath ? ":" : "") + name;
				nodeName = node.name();
				
				if (nodeName == "item") {
					item = menu.addItem(new NativeMenuItem(node.@label));
					
					if (String(node.@keyEquivalent)) item.keyEquivalent = node.@keyEquivalent;
					
					if (String(node.@keyEquivalentModifiers)) {
						keyEquivalentModifiers = String(node.@keyEquivalentModifiers).split(",");
						
						m = keyEquivalentModifiers.length;
						
						for (i = 0; i < m; ++i) {
							switch (keyEquivalentModifiers[i]) {
								case "command":
									keyEquivalentModifiers[i] = Keyboard.COMMAND;
									break;
								case "control":
									keyEquivalentModifiers[i] = Keyboard.CONTROL;
									break;
								case "option":
								case "alt":
								case "alternate":
									keyEquivalentModifiers[i] = Keyboard.ALTERNATE;
									break;
								case "shift":
									keyEquivalentModifiers[i] = Keyboard.SHIFT;
									break;
							}
						}
					} else {
						keyEquivalentModifiers = [];
					}
					
					item.keyEquivalentModifiers = keyEquivalentModifiers;
						
					item.checked = String(node.@checked) == "true";
					item.enabled = String(node.@enabled) != "false";
					
					item.addEventListener(Event.SELECT, itemSelectHandler, false, 0, true);
				} else if (nodeName == "menu") {
					item = menu.addItem(new NativeMenuItem(node.@label));
					
					item.submenu = new NativeMenu();

					build(item.submenu, path, node);
				} else if (nodeName == "separator") {
					item = menu.addItem(new NativeMenuItem("", true));
					
					if (!name) name = "separator" + separatorCount++;
				}
				
				item.name = name;
				itemByNameMap[name] = item;
				itemByPathMap[path] = item;
				pathByItemMap[item] = path;
			}
		}
		
		protected function itemSelectHandler(event:Event):void {
			_itemSelected.dispatch(this, event.currentTarget as NativeMenuItem);
		}
	}
}