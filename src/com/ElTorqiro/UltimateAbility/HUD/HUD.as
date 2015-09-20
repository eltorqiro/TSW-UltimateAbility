import gfx.core.UIComponent;
import com.GameInterface.DistributedValue;
import flash.geom.Point;
import com.Utils.GlobalSignal;
import com.Utils.Signal;

import com.ElTorqiro.UltimateAbility.App;
import com.ElTorqiro.UltimateAbility.Const;
import com.ElTorqiro.UltimateAbility.AddonUtils.MovieClipHelper;
import com.ElTorqiro.UltimateAbility.AddonUtils.GuiEditMode.GemController;
import com.ElTorqiro.UltimateAbility.HUD.UltimateAbilityButton;

/**
 * 
 * 
 */
class com.ElTorqiro.UltimateAbility.HUD.HUD extends UIComponent {
	
	public static var __className:String = "com.ElTorqiro.UltimateAbility.HUD.HUD";

	/**
	 * constructor
	 */
	public function HUD() {
		
		// start up invisible
		visible = false;
		
		SignalGeometryChanged = new Signal();
	}

	private function configUI() : Void {
		
		loadScale();
		loadPosition();
		
		// attach button
		m_Ultimate = UltimateAbilityButton( MovieClipHelper.attachMovieWithClass( "UltimateAbilityButton", UltimateAbilityButton, "m_Ultimate", this, getNextHighestDepth() ) );
		
		// listen for resolution changes
		guiResolutionScale = DistributedValue.Create("GUIResolutionScale");
		guiResolutionScale.SignalChanged.Connect( loadScale, this );

		// listen for pref changes and route to appropriate behaviour
		App.prefs.SignalValueChanged.Connect( prefChangeHandler, this );
		
		// gui edit mode listener
		GlobalSignal.SignalSetGUIEditMode.Connect( manageGuiEditMode, this );

		visible = true;
	}
	
	/**
	 * load position, or move to default if not defined
	 */
	private function loadPosition() : Void {
		
		var pos:Point = App.prefs.getVal( "hud.position" );
		
		// move to a reasonable default location on screen
		if ( pos == undefined ) {
			pos = new Point( Stage.visibleRect.width / 2, Stage.visibleRect.height - 250 );
		}
		
		position = pos;
	}

	/**
	 * loads scale
	 */
	private function loadScale() : Void {
		scale = App.prefs.getVal( "hud.scale" );
	}
	
	/**
	 * manages the GUI Edit Mode state
	 * 
	 * @param	edit
	 */
	public function manageGuiEditMode( edit:Boolean ) : Void {
	
		if ( edit ) {
			if ( !gemController ) {
				gemController = GemController.create( "m_GuiEditModeController", _parent, _parent.getNextHighestDepth(), this );
				gemController.addEventListener( "scrollWheel", this, "gemScrollWheelHandler" );
				gemController.addEventListener( "endDrag", this, "gemEndDragHandler" );
			}
		}
		
		else {
			gemController.removeMovieClip();
			gemController = null;
		}
		
	}

	private function gemScrollWheelHandler( event:Object ) : Void {
		
		App.prefs.setVal( "hud.scale", App.prefs.getVal( "hud.scale" ) + event.delta * 5 );
	}
	
	private function gemEndDragHandler( event:Object ) : Void {
		
		App.prefs.setVal( "hud.position", new Point( _x, _y ) );
	}
	
	/**
	 * handles updates based on pref changes
	 * 
	 * @param	pref
	 * @param	newValue
	 * @param	oldValue
	 */
	private function prefChangeHandler( pref:String, newValue, oldValue ) : Void {
		
		switch ( pref ) {
			
			case "hud.position":
				loadPosition();
			break;
			
			case "hud.scale":
				loadScale();
			break;
			
		}
		
	}

	/**
	 * internal variables
	 */

	public var m_Ultimate:UltimateAbilityButton;
	public var gemController:GemController;
	
    private var guiResolutionScale:DistributedValue;

	/**
	 * properties
	 */
	
	public var SignalGeometryChanged:Signal;
	 
	// the position of the hud
	public function get position() : Point { return new Point( this._x, this._y ); }
	public function set position( value:Point ) : Void {
		this._x = value.x;
		this._y = value.y;
		
		SignalGeometryChanged.Emit();
	}

	// the scale of the hud
	public function get scale() : Number { return App.prefs.getVal( "hud.scale" ); }
	public function set scale( value:Number ) : Void {
				
		// the default game GUI scale, based on screen resolution
		var resolutionScale:Number = guiResolutionScale.GetValue();
		if ( resolutionScale == undefined ) resolutionScale = 1;
		
		this._xscale = this._yscale = resolutionScale * value;

		SignalGeometryChanged.Emit();
	}
	
}