package org.fifthrevision {
	
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import mx.controls.Button;
	import mx.events.AIREvent;
	import org.fifthrevision.events.InteractionEvent;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.VideoDisplay;
	import spark.components.Window;
	import flash.filters.BlurFilter;
	/**
	 * ...
	 * @author 
	 */
	public class Presentation extends Group {
		
		private var video:VideoDisplay;
		private var label:Label;
		
		private var defWidth:int;
		private var defHeight:int;
		
		private var offsetX: int;
		private var offsetY: int;
			
		public function Presentation(width:int, height:int) {
			this.width = this.defWidth = width;
			this.height = this.defHeight = height;		
		}
		
		public function setVideo(url:String):void {			
			try {
				this.video.source = url;
				this.video.volume = 0;
				this.video.play();
				TweenLite.to(this.video, 5, { alpha: 0.8 } );
			} catch (e:Error) {
				e.getStackTrace();
			}
		}
		
		public function fadeVideo():void {
			TweenLite.to(this.video, 5, { alpha:0 } );
		}		
		
		public function setStaticText(text:String, x:int, y:int, fontSize:int):void {
			this.label.text = text;
			this.label.x = x;
			this.label.y = y;
			this.label.setStyle("fontSize", fontSize);
			TweenLite.to(this.label, 3, { alpha:1, blurFilter: { blurX: 0, blurY: 0 } });
		}
		
		public function endStaticText():void {
			TweenLite.to(this.label, 3, { alpha: 0, blurFilter: { blurX: 100, blurY: 100 } } );
		}
		
		private var timelines:Array = [];
		
		public function setText(text:String, x:int, y:int, fontSize:int, duration:Number, anIn:Number, anOut:Number):void {						
			if (duration == -1) {
				var numWords:int = text.split(" ").length;
				duration = numWords / 2;
			}
			if (anIn == -1) { anIn = 3; }
			if (anOut == -1) { anOut = 5; }
			
			var yFrom:int = Math.random() * 100 - 50;
			var yTo:int = Math.random() * 100- 50;
			
			var label:Label = new Label();
			label.text = text;
			label.styleName = "presentationText";
			label.x = x - 100 || 0;
			label.y = y + yFrom || 0;
			label.alpha = 0;
			label.setStyle("fontSize", fontSize);
			label.filters = [new BlurFilter(100, 100, 1)];
			
			this.addElement(label);			
			
			var self:Presentation = this;
			var newTimeline:TimelineLite = new TimelineLite( 
				{ onComplete: 	function():void {
									self.removeElement(label);
									for (var i:int = self.timelines.length - 1; i >= 0; i--) {
										if (self.timelines[i] == this) {
											self.timelines.splice(i, 1);
										}
									}
								}
				}
			);
			newTimeline.append(new TweenLite(label, anIn, { 
									alpha:1, 
									x: x,
									y: y,
									blurFilter: { blurX:0, blurY:0 }
								} )
							);
			newTimeline.append(new TweenLite(label, anOut, { 
									alpha:0, 
									x: x + 100, 
									y: y + yTo,
									blurFilter: { blurX:100, blurY:100 } 
								} )
							, duration);
			newTimeline.play();
			timelines.push(newTimeline);
		}
		
		public function cancel():void {
			for (var i:int = this.timelines.length - 1; i >= 0; i--) {
				TimelineLite(this.timelines[i]).complete();
				this.timelines.splice(i, 1);
			}
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			if (!this.video) {
				this.video = new VideoDisplay();
				this.video.percentHeight = 100;
				this.video.alpha = 0;
				this.video.autoPlay = false;
				this.addElement(video);
			}
			
			if (!this.label) {
				this.label = new Label();
				this.label.styleName = "presentationText";
				this.label.alpha = 0;
				this.label.filters = [new BlurFilter(100, 100, 1)];
				this.addElement(label);
			}
			
		}
		
	}	

}