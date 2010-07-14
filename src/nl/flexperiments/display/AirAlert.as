package nl.flexperiments.display
{
    import flash.desktop.NativeApplication;
    import flash.display.NativeWindow;
    import flash.display.NativeWindowType;
    import flash.display.Screen;
    import flash.events.Event;
    
    import mx.controls.Alert;
    import mx.core.EdgeMetrics;
    import mx.core.FlexVersion;
    import mx.core.Window;
    import mx.events.AIREvent;
    
    public class AirAlert extends Window {
        
        public var text:String = "";
        public var defaultButtonFlag:uint = Alert.OK;
        public var buttonFlags:uint = Alert.OK;
        public var iconClass:Class;

        public static var buttonHeight:Number = 22;
        public static var buttonWidth:Number = FlexVersion.compatibilityVersion < FlexVersion.VERSION_3_0 ? 60 : 65;
        
        public var alertForm:AirAlertForm;
        
        private var positioned:Boolean = false;
        
        public function AirAlert()
        {
            super();
            this.alpha = 0;
            this.alwaysInFront = true;
            this.showGripper =
            this.showStatusBar = false;
            this.type = NativeWindowType.UTILITY;
            /* this.width = 200;
            this.height = 50; */
            this.horizontalScrollPolicy =
            this.verticalScrollPolicy = "off";
            for each(var nw:NativeWindow in NativeApplication.nativeApplication.openedWindows) {
                if(!nw is AirAlert)
                    nw.stage.mouseChildren = false;
            }
            this.enabled = true;
            this.addEventListener(Event.CLOSING, _close);
            this.addEventListener(AIREvent.WINDOW_DEACTIVATE, _stealFocus);
        }
        
        private function _close(event:Event):void {
            this.removeEventListener(AIREvent.WINDOW_DEACTIVATE, _stealFocus);
            var nw:NativeWindow;
            for each(nw in NativeApplication.nativeApplication.openedWindows) {
                if(nw is AirAlert) return;
            }
            for each(nw in NativeApplication.nativeApplication.openedWindows) {
                nw.stage.mouseChildren = true;
            }
        }
        
        private function _stealFocus(event:AIREvent):void {
            this.activate();
            this.orderToFront();
        }
        
        public static function show(text:String = "", 
                                    title:String = "", 
                                    flags:uint = 0x4,
                                    closeHandler:Function = null,
                                    iconClass:Class = null,
                                    defaultButtonFlag:uint = 0x4):AirAlert {
            
            var alert:AirAlert = new AirAlert();
            if (flags & Alert.OK||
                flags & Alert.CANCEL ||
                flags & Alert.YES ||
                flags & Alert.NO) {
                    
                alert.buttonFlags = flags;
            }
            
            if (defaultButtonFlag == Alert.OK ||
                defaultButtonFlag == Alert.CANCEL ||
                defaultButtonFlag == Alert.YES ||
                defaultButtonFlag == Alert.NO) {
                    
                alert.defaultButtonFlag = defaultButtonFlag;
            }
            
            alert.text = text;
            alert.title = title;
            alert.iconClass = iconClass;
            
            if (closeHandler != null)
                alert.addEventListener("airClose", closeHandler);
                
            alert.setActualSize(alert.getExplicitOrMeasuredWidth(),
                            alert.getExplicitOrMeasuredHeight());
            alert.open();
            alert.activate();
            return alert;
        }
        
        override protected function createChildren():void {
            super.createChildren();
            
            var messageStyleName:String = getStyle("messageStyleName");
            if (messageStyleName)
                styleName = messageStyleName;
            
            if (!alertForm) {   
                alertForm = new AirAlertForm();
                alertForm.styleName = this;
                addChild(alertForm);
            }
        }
        
        override protected function measure():void {   
            super.measure();
            
            var m:EdgeMetrics = viewMetrics;
            
            // The width is determined by the title or the AlertForm,
            // whichever is wider.
            measuredWidth = Math.max(measuredWidth, alertForm.getExplicitOrMeasuredWidth() + m.left + m.right);
            width = measuredWidth;
            measuredHeight = alertForm.getExplicitOrMeasuredHeight() + m.top + m.bottom;
            if(!positioned) {
                this.nativeWindow.x = (Screen.mainScreen.visibleBounds.width / 2) - this.nativeWindow.width / 2;
                this.nativeWindow.y = (Screen.mainScreen.visibleBounds.height / 2) - this.nativeWindow.height / 2;
                this.alpha = 1;
                positioned = true;
            }
        }
        
        /**
        *  @private
        */
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            // Position the AlertForm inside the "client area" of the Panel
            var vm:EdgeMetrics = viewMetrics;
            alertForm.setActualSize(unscaledWidth - vm.left - vm.right -
                                    getStyle("paddingLeft") -
                                    getStyle("paddingRight"),
                                    unscaledHeight - vm.top - vm.bottom -
                                    getStyle("paddingTop") -
                                    getStyle("paddingBottom"));
        }

    }
}