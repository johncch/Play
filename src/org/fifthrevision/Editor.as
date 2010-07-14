package org.fifthrevision {
	import flash.events.MouseEvent;
	import org.fifthrevision.events.EditEvent;
	import org.fifthrevision.events.EditPanelEvent;
	import spark.components.Group;
	import spark.components.Label;
	
	/**
	 * ...
	 * @author Chua Chong Han
	 */
	public class Editor extends Group {
		
		private var defWidth:int;
		private var defHeight:int;
		
		public function Editor(width:int, height:int) {
			this.width = this.defWidth = width;
			this.height = this.defHeight = height;
			this.setStyle("backgroundColor", 0);
		}

		private var label:Label;
		private var editPanel:EditPanel;
		
		public function setText(text:String, x:int, y:int, fontSize:int, duration:Number, anIn:Number, anOut:Number):void {
			this.label.text = text;
			this.label.x = x || 0;
			this.label.y = y || 0;
			this.label.setStyle("fontSize", fontSize);
			this.editPanel.duration = duration;
			this.editPanel.anIn = anIn;
			this.editPanel.anOut = anOut;
		}
		
		private function mouseEventListener(e:MouseEvent):void {			
			this.label.x = e.localX;
			this.label.y = e.localY;
		}
		
		private var mouseMove:Boolean = false;
		private var labelOffsetX:int;
		private var labelOffsetY:int;
		
		private function mouseDownListener(e:MouseEvent):void {						
			this.labelOffsetX = e.stageX - this.label.x;
			this.labelOffsetY = e.stageY - this.label.y;						
			this.mouseMove = false;
			this.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveListener);			
		}
		
		private function mouseUpListener(e:MouseEvent):void {			
			this.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveListener);
			this.dispatchEvent(new EditEvent(EditEvent.MOVE, { x: this.label.x, y:this.label.y } ));			
		}
		
		private function mouseMoveListener(e:MouseEvent):void {
			this.label.x = e.stageX - this.labelOffsetX;
			this.label.y = e.stageY - this.labelOffsetY;			
		}		
	
		override protected function createChildren():void {
			super.createChildren();
						
			if (!this.label) {
				this.label = new Label();				
				this.label.styleName = "presentationText";
				this.addElement(label);
				this.label.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener);
				this.label.addEventListener(MouseEvent.MOUSE_UP, mouseUpListener);		
			}
			
			if (!this.editPanel) {
				this.editPanel = new EditPanel();
				
				this.editPanel.addEventListener(EditPanelEvent.SIZE_PLUS, sizeChangeHandler);
				this.editPanel.addEventListener(EditPanelEvent.SIZE_MINUS, sizeChangeHandler);
				this.editPanel.addEventListener(EditPanelEvent.DURATION_CHANGE, durationChangeHandler);
				this.editPanel.addEventListener(EditPanelEvent.IN_CHANGE, inChangeHandler);
				this.editPanel.addEventListener(EditPanelEvent.OUT_CHANGE, outChangeHandler);
				
				this.editPanel.x = this.defWidth - 280;
				this.editPanel.y = this.defHeight - 300;
				this.addElement(editPanel);
			}
		}
		
		public static const FONT_STEP:int = 4;
		
		private function sizeChangeHandler(e:EditPanelEvent):void { 
			var fontSize:int = this.label.getStyle("fontSize");
			if (e.type == EditPanelEvent.SIZE_PLUS) {
				fontSize += FONT_STEP;
			} else if (e.type == EditPanelEvent.SIZE_MINUS && fontSize > 4) {
				fontSize -= FONT_STEP;
			}			
			this.label.setStyle("fontSize", fontSize);
			this.dispatchEvent(new EditEvent(EditEvent.FONTSIZE, { fontSize: fontSize } ));
		}
		
		private function durationChangeHandler(e:EditPanelEvent):void {
			var duration:int = e.param.duration;
			this.dispatchEvent(new EditEvent(EditEvent.DURATION, { duration: duration } ));
		}
		
		private function inChangeHandler(e:EditPanelEvent):void {
			var anIn:Number = e.param.anIn;
			this.dispatchEvent(new EditEvent(EditEvent.IN, { anIn: anIn } ));
		}
		
		private function outChangeHandler(e:EditPanelEvent):void {
			var anOut:Number = e.param.anOut;
			this.dispatchEvent(new EditEvent(EditEvent.OUT, { anOut: anOut } ));
		}
		
	}

}