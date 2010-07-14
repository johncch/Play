package org.fifthrevision {
	
	import flash.display.Screen;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flashx.textLayout.compose.ITextLineCreator;
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	import mx.events.AIREvent;
	import nl.flexperiments.display.AirAlert;
	import org.fifthrevision.events.EditEvent;
	import org.fifthrevision.events.InteractionEvent;
	import spark.components.Window;
	
	/**
	 * The director controls the animation
	 * 
	 * @author Chua Chong Han
	 */
	
	[Bindable]
	public class Director {
		
		public var presentation:Presentation;
			
		public var actionsList:XMLListCollection;
		
		public var showable:Boolean = false;
		public var editable:Boolean = false;
		public var fullscreenable:Boolean = false;
		
		public var editing:Boolean = false;
		public var presenting:Boolean = false;
		
		private var pWindow:PresentationWindow = new PresentationWindow();
		
		private var pWidth:int;
		private var pHeight:int;
		
		private var aIndex:int = -1;
		
		public function Director() {
			this.pWindow.addEventListener(InteractionEvent.NEXT, interactionHandler);
			this.pWindow.addEventListener(InteractionEvent.PREV, interactionHandler);
			this.pWindow.addEventListener(InteractionEvent.CANCEL_AND_NEXT, interactionHandler);
			this.pWindow.addEventListener(InteractionEvent.CANCEL_AND_PREV, interactionHandler);			
			this.pWindow.addEventListener(Event.CLOSING, windowCloseHandler);
		}
		
		private function windowCloseHandler(e:Event):void {			
			this.editable = true;
			this.showable = true;
			this.fullscreenable = true;
			this.editing = false;
			this.presenting = false;
		}
		
		public function get actionsIndex():int {
			return this.aIndex;
		}
		
		public function set actionsIndex(i:int):void {
			this.aIndex = i;
			var action:XML = this.actionsList.getItemAt(this.aIndex) as XML;
			if (this.editing) {
				this.editAction(action);
			}
			if (this.presenting) {
				this.presentAction(action);
			}
		}
		
		public function labelFunction(item:XML):String {
			function formatString(s:String):String {
				if (s.length > 30) {
					return s.substring(0, 14) + "..." + s.substring(s.length -14, s.length);
				} 
				return s;
			}
						
			var label:String = "";
			if ("marker" in item) {
				label += item.marker;
				return label;
			} 			
			if ("text" in item) {
				if ("@type" in item.text && item.text.@type == "static") {
					label += "Static ";
				}
				label += "Text: " + formatString(item.text);
			}
			if ("video" in item) {
				label += "Video: " + formatString(item.video.@source);
			}
			return label;
		}
		
		private var dir:String;
		
		public function setFilePath(dir:String):void {
			this.dir = dir;
		}
		
		public function load(xml:XML):Boolean {			
			if (xml.localName() != "presentation") {
				AirAlert.show("This not a valid configuration file");
				return false;
			}
			
			xml.prependChild(<action><marker>Start</marker></action>);
			xml.appendChild(<action><marker>End</marker></action>);
			var xmllist:XMLList = new XMLList(xml.children());
			actionsList = new XMLListCollection(xmllist);
			
			pWindow.width = this.pWidth = xml.@width || 1024;
			pWindow.height = this.pHeight = xml.@height || 768;			
			
			this.editable = true;
			this.showable = true;
			this.fullscreenable = false;
			
			this.actionsIndex = 0;
			
			return true;
		}
		
		private function interactionHandler(e:InteractionEvent):void {
			if (e.type == InteractionEvent.NEXT) {
				this.next();
			} else if (e.type == InteractionEvent.PREV) {
				this.previous();
			} else if (e.type == InteractionEvent.CANCEL_AND_NEXT) {
				this.cancel();
				this.next();
			} else if (e.type == InteractionEvent.CANCEL_AND_PREV) {
				this.cancel();
				this.previous();
			}
		}
		
		public function show():void {
			this.presentation = new Presentation(pWidth, pHeight);
			
			this.pWindow.addDisplay(this.presentation);
			this.pWindow.open();
			this.pWindow.activate();
			
			this.presenting = true;
			this.editing = false;
			this.editable = false;
			this.showable = false;
			this.fullscreenable = true;
		}
		
		public var editor:Editor;
		
		public function edit():void {			
			this.editor = new Editor(this.pWidth, this.pHeight);
			this.editor.addEventListener(EditEvent.MOVE, editMoveHandler);
			this.editor.addEventListener(EditEvent.FONTSIZE, editFontSizeHandler);
			this.editor.addEventListener(EditEvent.DURATION, editDurationHandler);
			this.editor.addEventListener(EditEvent.IN, editInHandler);
			this.editor.addEventListener(EditEvent.OUT, editOutHandler);
				
			this.pWindow.addDisplay(this.editor);			
			this.pWindow.open();
			this.pWindow.activate();
			
			this.editing = true;
			this.presenting = false;
			this.editable = false;
			this.showable = false;
			this.fullscreenable = false;
			
			var action:XML = this.actionsList.getItemAt(this.aIndex) as XML;
			this.editAction(action);
		}
		
		private function editMoveHandler(e:EditEvent):void {
			var action:XML = this.actionsList.getItemAt(this.aIndex) as XML;
			if ("text" in action) {
				action.text.@x = e.params.x;
				action.text.@y = e.params.y;
			}
		}
		
		private function editFontSizeHandler(e:EditEvent):void {
			var action:XML = this.actionsList.getItemAt(this.aIndex) as XML;
			if ("text" in action) {
				action.text.@fontSize = e.params.fontSize				
			}
		}
		
		private function editDurationHandler(e:EditEvent):void {			
			var action:XML = this.actionsList.getItemAt(this.aIndex) as XML;
			if ("text" in action) {
				if (e.params.duration == -1) {
					delete(action.text.@duration);
				} else {
					action.text.@duration = e.params.duration;
				}
			}
		}
		
		private function editInHandler(e:EditEvent):void {
			var action:XML = this.actionsList.getItemAt(this.aIndex) as XML;
			if ("text" in action) {
				if (e.params.anIn == -1) {
					delete(action.text.@anin);
				} else {
					action.text.@anin = e.params.anIn;
				}
			}
		}
		
		private function editOutHandler(e:EditEvent):void {
			var action:XML = this.actionsList.getItemAt(this.aIndex) as XML;
			if ("text" in action) {
				if (e.params.anOut == -1) {
					delete(action.text.@out);
				} else {
					action.text.@out = e.params.anOut;
				}
			}
		}
		
		public function fullscreen(screen:Screen):void {
			this.pWindow.fullscreen(screen);
		}
		
		public function cancel():void {
			if(this.presenting) this.presentation.cancel();
		}
		
		public function next():void {
			if (this.aIndex >= this.actionsList.length) {
				return;
			}
			this.actionsIndex++;
			var action:XML = this.actionsList.getItemAt(this.aIndex) as XML;
			
			if (this.editing) {
				this.editAction(action);
			}
			if (this.presenting) {				
				this.presentAction(action);
			}
			
		}
		
		public function previous():void {
			if (this.aIndex == 0) {
				return;
			}
			this.actionsIndex--;
			var action:XML = this.actionsList.getItemAt(this.aIndex) as XML;
			
			if (this.editing) {
				this.editAction(action);
			}
			if (this.presenting) {
				this.presentAction(action);
			}
		}
		
		public static const defaultFontSize:int = 32;
		public static const defaultDuration:Number = -1;
		public static const defaultIn:Number = -1;
		public static const defaultOut:Number = -1;
		
		private function editAction(action:XML):void {
			if ("text" in action) {
				var x:int = parseInt(action.text.@x) || 0;
				var y:int = parseInt(action.text.@y) || 0;				
				var fontSize:int = parseInt(action.text.@fontSize) || defaultFontSize;
				var duration:Number = Number(action.text.@duration) || defaultDuration;
				var anIn:Number = Number(action.text.@anin) || defaultIn;
				var anOut:Number = Number(action.text.@out) || defaultOut;
				this.editor.setText(action.text, x, y, fontSize, duration, anIn, anOut);
			}
		}
		
		private function presentAction(action:XML):void {
			if ("text" in action) {
				var x:int = parseInt(action.text.@x) || 0;
				var y:int = parseInt(action.text.@y) || 0;				
				var fontSize:int = parseInt(action.text.@fontSize) || defaultFontSize;
				
				if ("@type" in action.text && action.text.@type == "static") {
					if (action.text == "") {
						this.presentation.endStaticText();
					} else {
						this.presentation.setStaticText(action.text, x, y, fontSize);
					}
				} else {
					var duration:Number = Number(action.text.@duration) || defaultDuration;
					var anIn:Number = Number(action.text.@anin) || defaultIn;
					var anOut:Number = Number(action.text.@out) || defaultOut;
					this.presentation.setText(action.text, x, y, fontSize, duration, anIn, anOut);
				}
			}
			if ("video" in action) {
				if (action.video.@action == "fadeout") {
					this.presentation.fadeVideo();
				} else {
					this.presentation.setVideo(this.dir + action.video.@source);
				}
			}
		}		
		
	}

}