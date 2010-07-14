package org.fifthrevision.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class EditPanelEvent extends Event {

		public static const SIZE_PLUS:String = "sizePlus";
		public static const SIZE_MINUS:String = "sizeMinus";
		public static const DURATION_CHANGE:String = "durationChange";
		public static const IN_CHANGE:String = "inChange";
		public static const OUT_CHANGE:String = "outChange";
		
		public var param:Object;
		
		public function EditPanelEvent(type:String, param:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);						
			this.param = param;
		} 
		
		public override function clone():Event { 
			return new EditPanelEvent(type, param, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("EditPanelEvent", "type", "param", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}