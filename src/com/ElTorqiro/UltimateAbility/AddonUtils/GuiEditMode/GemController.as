import flash.geom.Point;
import gfx.core.UIComponent;

import com.ElTorqiro.UltimateAbility.AddonUtils.GuiEditMode.GemOverlay;


/**
 * 
 * 
 */
class com.ElTorqiro.UltimateAbility.AddonUtils.GuiEditMode.GemController extends UIComponent {

	public function GemController() {

		if ( groupMoveModifiers == undefined ) {
		
			groupMoveModifiers = [
				{	button: 1,
					keys: [
						Key.SHIFT
					]
				}
			];
		}
		
		if ( overlayLinkage == undefined ) {
			overlayLinkage = "GemOverlay";
		}
		
	}
	
	private function configUI() : Void {

		overlays = [ ];
		
		if ( targets instanceof MovieClip ) {
			targets = [ targets ];
		}
		
		for ( var i:Number = 0; i < targets.length; i++ ) {
			
			var overlay:GemOverlay = GemOverlay( attachMovie( overlayLinkage, "", getNextHighestDepth(), { target: targets[i] } ) );
			
			overlay.addEventListener( "press", this, "pressHandler" );
			overlay.addEventListener( "release", this, "releaseHandler" );

			overlay.addEventListener( "scrollWheel", this, "scrollWheelHandler" );
			
			overlays.push( overlay );
			
		}
		
	}

	private function pressHandler( event:Object ) : Void {
		
		prevMousePos = new Point( _xmouse, _ymouse );
		
		dragOverlay = event.target;
		clickEvent = event;
		
		onMouseMove = function() {
			
			var diff:Point = new Point( _xmouse - prevMousePos.x, _ymouse - prevMousePos.y );
			
			if ( !dragging ) {
				dragging = true;
				dispatchEvent( { type: "startDrag", overlay: dragOverlay } );
				
				for ( var s:String in overlays ) {
					dispatchEvent( { type: "targetStartDrag", overlay: overlays[s] } );
				}
				
			}
			
			dispatchEvent( { type: "drag", overlay: dragOverlay, delta: diff } );
			
			for ( var s:String in overlays ) {
				overlays[s].moveBy( diff );
				dispatchEvent( { type: "targetDrag", overlay: overlays[s], delta: diff } );
			}

			prevMousePos = new Point( _xmouse, _ymouse );
			
		}
		
	}
	
	private function releaseHandler( event:Object ) : Void {

		if ( dragging ) {
			dispatchEvent( { type: "endDrag", overlay: dragOverlay } );

			for ( var s:String in overlays ) {
				dispatchEvent( { type: "targetEndDrag", overlay: overlays[s] } );
			}
			
			dragging = false;
		}
		
		else {
			dispatchEvent( { type: "click", overlay: clickEvent.target, button: clickEvent.button, shift: clickEvent.shift, ctrl: clickEvent.ctrl } );
		}
		
		clickEvent = null;
		dragOverlay = null;
		onMouseMove = undefined;
	}
	
	private function scrollWheelHandler( event:Object ) : Void {
		dispatchEvent( { type: "scrollWheel", overlay: event.target, delta: event.delta } );
	}
	
	/**
	 * internal variables
	 */
	
	private var dragging:Boolean;
	private var clickEvent:Object;
	private var dragOverlay:GemOverlay;
	
	private var prevMousePos:Point;
	 
	private var targets;
	private var overlays:Array;
	
	private var groupMoveModifiers:Array;
	
	private var overlayLinkage:String;
	 
	/**
	 * properties
	 */
	 
}