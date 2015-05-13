import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import com.GameInterface.Inventory;
import com.GameInterface.UtilsBase;
import flash.geom.Point;
import gfx.core.UIComponent;
import com.GameInterface.Lore;
import com.GameInterface.Input;
import com.GameInterface.InventoryItem;
import com.Utils.ID32;
import com.Utils.LDBFormat;
import com.GameInterface.Tooltip.*;
import mx.utils.Delegate;
import flash.filters.GlowFilter;
import gfx.motion.Tween;
import mx.transitions.easing.Strong;

import com.GameInterface.Game.Shortcut;

import com.ElTorqiro.UltimateAbility.AddonInfo;
import com.ElTorqiro.UltimateAbility.AddonUtils.AddonUtils;
import com.ElTorqiro.UltimateAbility.HUD.SettingsPacks;

/**
 * 
 * 
 */
class com.ElTorqiro.UltimateAbility.HUD.HUD extends UIComponent {

	public static var e_UltimateVisibilitySettingNever:Number = 0;
	public static var e_UltimateVisibilitySettingCharged:Number = 1;
	public static var e_UltimateVisibilitySettingAlways:Number = 2;

	public static var e_UltimateAbilityUnlockID:Number = 7783;
	
	public static var e_AnimaEnergyStat:Number = _global.Enums.Stat.e_AnimaEnergy;
	public static var e_UltimateShortcutSlot:Number = _global.Enums.UltimateAbilityShortcutSlots.e_UltimateShortcutBarFirstSlot;
	
	private var _configured:Boolean;
	
	// utility objects
	private var _character:Character;
	private var _iconLoader:MovieClipLoader;
	
	private var _findElementTimers:Object = { };

	// internal movieclips
	private var m_Ultimate:MovieClip;
	private var m_Overlay:MovieClip;

	// internal states
	private var _mouseDown:Number = -1;
	
	// config mode listener
	private var _configMode:DistributedValue;

	// game scaling mechanism settings
    private var _guiResolutionScale:DistributedValue;

	// game settings
	private var _ultimateVisibilityMonitor:DistributedValue;
	private var _showHotkeysOnAbilities:DistributedValue;
	
	// broadcast for enabled/disabled value for HUD
	private var _ultimateAbilityHUDState:DistributedValue;
	
	// parameters passed in through initObj of attachMovie( ..., initObj)
	private var settings:Object;


	/**
	 * constructor
	 */
	public function HUD() {
		
		// start up invisible
		visible = false;
		
		// initialise distributed values
		_ultimateAbilityHUDState = DistributedValue.Create( AddonInfo.ID + "_HUD_State" );
		_guiResolutionScale = DistributedValue.Create("GUIResolutionScale");
		_configMode = DistributedValue.Create( AddonInfo.ID + "_ShowConfig" );
	}

	private function configUI() : Void {
		
		super.configUI();

		m_Ultimate.onPress = Delegate.create( this, function() {
			
			if ( animaEnergyFull ) {
				Shortcut.UseShortcut( e_UltimateShortcutSlot );
			}
		});
		
		_character = Character.GetClientCharacter();

		// other objects that need creating
		_iconLoader = new MovieClipLoader();
		_iconLoader.addListener(this);
		
		// apply initial settings based on defaults
		var initSettings:Object = SettingsPacks.defaultSettings;

		// mix in passed in settings with default settings
		// but only apply if settings are compatible with the current settings version
		// otherwise everything should be left as defaults to force a settings reset
		if ( settings.settingsVersion >= initSettings.settingsVersion ) {
			for ( var s:String in settings ) {
				initSettings[s] = settings[s];
			}
		}
		
		ApplySettingsPack( initSettings );
		delete settings;

		// HUD is configured and can now run freely
		_configured = true;
		
		// listen for resolution changes
		_guiResolutionScale.SignalChanged.Connect( Layout, this );
		
		// config mode listener
		_configMode.SignalChanged.Connect( stateTriggerHandler, this );
		
		// game settings
		_ultimateVisibilityMonitor = DistributedValue.Create( "ultimate_ability_visibility" );
		_ultimateVisibilityMonitor.SignalChanged.Connect( invalidate, this );

		_showHotkeysOnAbilities = DistributedValue.Create( "ShortcutbarHotkeysVisible" );
		_showHotkeysOnAbilities.SignalChanged.Connect( invalidate, this);

		// setup tween finishing handler
		m_Overlay.onTweenComplete = Delegate.create( this, finaliseTween );
		
		// setup mouse handlers for config mode overlay
		m_Overlay.onPress = Delegate.create(this, handleMousePress);
		m_Overlay.onRelease = Delegate.create(this, handleMouseRelease);
		m_Overlay.onReleaseOutside = Delegate.create(this, handleReleaseOutside);
		m_Overlay["onPressAux"] = m_Overlay.onPress;
		m_Overlay["onReleaseAux"] = m_Overlay.onRelease;
		m_Overlay["onReleaseOutsideAux"] = m_Overlay.onReleaseOutside;
	}
	
	public function onUnload():Void {
		super.onUnload();

		// unwire signal listeners
		_configMode.SignalChanged.Connect( stateTriggerHandler, this );
		_guiResolutionScale.SignalChanged.Disconnect( Layout, this );

		// deafen game setting listeners
		_ultimateVisibilityMonitor.SignalChanged.Disconnect( invalidate, this );
		_showHotkeysOnAbilities.SignalChanged.Disconnect( invalidate, this);
		
		// restore default UI
		hideDefaultInCombatIndicator( false );
	}
	
	// hide or show default buttons
	public function hideDefaultInCombatIndicator( hide:Boolean ) : Void {
/*
		var pi:MovieClip = _root.combatbackground.i_CombatBackground;
		
		// wait for the panel to be loaded, as it actually gets unloaded during teleports etc, not just deactivated
		if ( pi == undefined ) {
			
			// only retry if we're trying to hide, otherwise assume the thing should have been on the stage already
			if( hide ) {
				// if the thrash count is exceeded, reset count and do nothing
				if (_findDefaultCombatIndicatorThrashCount++ == 10)  _findDefaultCombatIndicatorThrashCount = 0;
				// otherwise try again only if we aren't trying to restore
				else {
					_global.setTimeout( Delegate.create(this, hideDefaultInCombatIndicator), 300, hide );
				}
			}
			
			return;
		}
		// if we reached this far, reset thrash count
		_findDefaultCombatIndicatorThrashCount = 0;

		// hide/show
		pi._visible = !hide;
*/
	}
	
	
	/**
	 * layout in default position on screen
	 */
	public function MoveToDefaultPosition():Void {

		// position near bottom middle of screen
		var visibleRect = Stage["visibleRect"];
		
		var pos:Point = new Point();
		
		pos.x = visibleRect.width / 2;
		pos.y = visibleRect.height - 170;

		// update saved position
		position = pos;
	}

	// sets the position of elements, including scale, integrating with the game's resolution
	private function Layout():Void {

		// this is based on the trio: GUI resolution, GUI hud scale, this hud scale
		var guiResolutionScale:Number = _guiResolutionScale.GetValue();
		
		// some sanity checks in case somehow the game isn't providing these
		if ( guiResolutionScale == undefined ) guiResolutionScale = 1;

		// apply the real final scale
		var realScale:Number = guiResolutionScale * hudScale;
		
		//m_Ultimate._xscale = m_Ultimate._yscale = realScale;
		
		// overlay wrapper
		var rect:Object = m_Ultimate.getBounds(m_Ultimate);
		
		m_Overlay._x = rect.xMin;
		m_Overlay._y = rect.yMin;
		m_Overlay._width = Math.abs(rect.xMin) + Math.abs(rect.xMax);
		m_Overlay._height = Math.abs(rect.yMin) + Math.abs(rect.yMax);
		
		// bar elements
		/*
		for ( var s:String in _bars ) {
			var bar:MovieClip = _bars[s];
			
			// bar scale
			bar.m_Bar._xscale = barScaleX;
			bar.m_Bar._yscale = barScaleY;
			
			bar.m_Bar._x = 0 - (bar.m_Bar._width / 2);
			bar.m_Bar._y = 0 - (bar.m_Bar._height / 2);
			
			// icon scale
			bar.m_Icon._xscale = bar.m_Icon._yscale = iconScale;
			
			// icon position
			bar.m_Icon._x = 0 - (bar.m_Icon._width / 2);
			bar.m_Icon._y = 0 - (bar.m_Icon._height / 2);
		}
		*/
		
		this._xscale = this._yscale = realScale;
		
		invalidate();
	}
	

	// restore default tints
	public function ApplyDefaultTints():Void {
		
		var defaults:Object = SettingsPacks.defaultSettings;
		
		visualUpdatesSuspended = true;
		
		tintThreatened = defaults.tintThreatened;
		tintCombat = defaults.tintCombat;
		
		visualUpdatesSuspended = false;
	}
	
	// restore all settings to default
	public function ApplyDefaultSettings() : Void {
		ApplySettingsPack( SettingsPacks.defaultSettings );
		
		MoveToDefaultPosition();
	}

	
	public function LoadIcons() : Void {
		/*
		if ( useCustomIcons ) {
			_iconLoader.loadClip( AddonInfo.ID + "\\" + combatIconFilename, m_Combat.m_Icon );
			_iconLoader.loadClip( AddonInfo.ID + "\\" + threatenedIconFilename, m_Threatened.m_Icon );
		}
		
		else {
			m_Combat.attachMovie( "com.ElTorqiro.UltimateAbility.HUD.Icon.Default", "m_Icon", m_Combat.m_Icon.getDepth() );
			m_Threatened.attachMovie( "com.ElTorqiro.UltimateAbility.HUD.Icon.Default", "m_Icon", m_Threatened.m_Icon.getDepth() );
			Layout();
		}
		*/
	}
	
	// handlers for MovieClipLoader.loadClip
	private function onLoadInit(target:MovieClip) : Void {
		// set proper scale of target element
		Layout();
	}
	
	private function onLoadError(target:MovieClip) : Void {
		target._parent.attachMovie( "com.ElTorqiro.UltimateAbility.HUD.Icon.Error", "m_Icon", target.getDepth() );
		Layout();
	}
	
	
	private function finaliseTween() : Void {
		
		// hide the overlay to prevent clicks
		m_Overlay._visible = m_Overlay._alpha != 0;
	}
	

	private function stateTriggerHandler() : Void {

		// bar fade in/out
		var overlayOn:Boolean;
		var combatOn:Boolean;
		var threatenedOn:Boolean;
		var threatenedPos:Number = 0;
		
		var fadeIn:Number = fadeInTime / 1000;
		var fadeOut:Number = fadeOutTime / 1000;
		
		// if in config mode, always show everything
		if ( isInConfigMode ) {

			visible = true;
			
			combatOn = true;
			threatenedOn = true;
			overlayOn = true;
			
			threatenedPos = -100;
		}
		
		else {
			// in combat
			if ( hudEnabled && combatState == "combat" ) {
				visible = true;
				combatOn = true;
			}

			// if threatened
			else if ( hudEnabled && combatState == "threatened" ) {
				visible = true;
				threatenedOn = true;
			}
		}
		
		m_Overlay._visible = overlayOn;
		m_Overlay.tweenTo( overlayOn ? fadeIn : fadeOut, { _alpha: overlayOn ? 100 : 0 }, Strong.easeOut );

		//m_Combat.tweenTo( combatOn ? fadeIn : fadeOut, { _alpha: combatOn ? hudAlpha : 0 }, Strong.easeOut );
		//m_Threatened.tweenTo( threatenedOn ? fadeIn : fadeOut, { _alpha: threatenedOn ? hudAlpha : 0, _y: threatenedPos }, Strong.easeOut );
	}

	
	// highlight active aegis slot
	private function draw() : Void {
		
		if ( visualUpdatesSuspended || !_configured ) return;


		// progress fill
		m_Ultimate.m_Fill.m_Mask._yscale = animaEnergy;
		
		// apply glow
		m_Ultimate.filters = glowBar && animaEnergyFull ? [ new GlowFilter(0xfff733, 0.8, 16, 16, 0.5, 3, false, false) ] : [];
		
		
		
		// bar elements
		/*
		for ( var s:String in _bars ) {
			var bar:MovieClip = _bars[s];

			// bar style
			bar.m_Bar.gotoAndStop( "type_" + barStyle );
			
			// bar visibility
			bar.m_Bar._visible = showBar;
			bar.m_Bar._alpha = barAlpha;
			
			// icon visibility
			bar.m_Icon._visible = showIcons;
			bar.m_Icon._alpha = iconAlpha;
			
			AddonUtils.Colorize( bar.m_Bar, _tints[s] );
			
			bar.m_Bar.filters = glowBar ? [ new GlowFilter( _tints[s], 0.8, 8, 8, 2, 3, false, false ) ] : [];
		}
		*/

		/*
		stateTriggerHandler();
		*/
	}
	

	private function handleMousePress(controllerIdx:Number, keyboardOrMouse:Number, button:Number):Void {

		// only allow one mouse button to be pressed at once
		if ( _mouseDown != -1 ) return;
		_mouseDown = button;

		this.startDrag();
	}
	
	private function handleMouseRelease(controllerIdx:Number, keyboardOrMouse:Number, button:Number):Void {
		// only propogate if the release is associated with the originally held down button
		if ( _mouseDown != button ) return;
		_mouseDown = -1;

		this.stopDrag();
		
		// update saved position at the end of the drag
		position = new Point( this._x, this._y );
	}
	
	private function handleReleaseOutside(controllerIdx:Number, button:Number):Void {
		handleMouseRelease(controllerIdx, 0, button);
	}

	
	// apply a bundle of settings all at once
	public function ApplySettingsPack(pack:Object) {
		
		visualUpdatesSuspended = true;
		
		for ( var s:String in pack ) {
			// TODO : implement something equivalent to AS3's .hasOwnProperty(name)
			this[s] = pack[s];
		}
		
		visualUpdatesSuspended = false;
	}

	/**
	 * validators
	 */

	 function validateAlpha( value:Number ) : Number {
		var alpha:Number;
		if ( value < 0 ) alpha = 0;
		else if ( value > 100 ) alpha = 100;
		else if ( value == Number.NaN ) alpha = 100;
		else alpha = value;
		
		return alpha;
	}
	
	function validateScale( value:Number ) : Number {
		var scale:Number;
		
		if ( value < minHUDScale ) scale = minHUDScale;
		else if ( value > maxHUDScale ) scale = maxHUDScale;
		else if ( value == Number.NaN ) scale = 100;
		else scale = value;
		
		return scale;
	}

	/**
	 * validates a tint number to ensure it is RGB
	 * 
	 * @param	tint		the tint number to validate
	 * @param	ifInvalid	the value to return if the tint is invalid
	 * 
	 * @return	either the tint value, or the value of tintIfInvalid
	 */
	private function validateTint( tint:Number, ifInvalid:Number ) : Number {
		return AddonUtils.isRGB( tint ) ? tint : ifInvalid;
	}
	
	
	/**
	 * properties
	 */
	
	// hide default UI toggle
	private var _hideDefaultUI:Boolean;
	public function get hideDefaultUI():Boolean { return _hideDefaultUI; }
	public function set hideDefaultUI(value:Boolean):Void {
		_hideDefaultUI = value;

		hideDefaultInCombatIndicator(_hideDefaultUI);
	}

	
	// scale boundaries
	public  var maxHUDScale:Number;
	public  var minHUDScale:Number;

	
	// hud position
	private var _position:Point;
	public function get position():Point {
		return _position;
	}
	public function set position(value:Point) {
		_position = value;

		if ( value == undefined ) {
			MoveToDefaultPosition();
		}
		
		else {
			this._x = _position.x;
			this._y = _position.y;
		}
	}


	private var _showIcons:Boolean;
	public function get showIcons():Boolean { return _showIcons; }
	public function set showIcons(value:Boolean):Void {
		_showIcons = value;
		invalidate();
	}	

	private var _useCustomIcons:Boolean;
	public function get useCustomIcons():Boolean { return _useCustomIcons; }
	public function set useCustomIcons(value:Boolean):Void {
		_useCustomIcons = value;
		
		LoadIcons();
	}	
	
	// icon alpha
	private var _iconAlpha:Number;
	public function get iconAlpha():Number { return _iconAlpha; }
	public function set iconAlpha(value:Number) {
		_iconAlpha = validateAlpha( value );
		invalidate();
	}
	
	// icon scale
	private var _iconScale:Number;
	public function get iconScale():Number { return _iconScale; }
	public function set iconScale(value:Number) {
		_iconScale = validateScale( value );
		Layout();
	}

	
	// bar
	private var _showBar:Boolean;
	public function get showBar():Boolean { return _showBar; }
	public function set showBar(value:Boolean):Void {
		_showBar = value;
		invalidate();
	}	

	private var _barStyle:Boolean;
	public function get barStyle():Boolean { return _barStyle; }
	public function set barStyle(value:Boolean):Void {
		_barStyle = value;
		invalidate();
	}	
	
	private var _glowBar:Boolean;
	public function get glowBar():Boolean { return _glowBar; }
	public function set glowBar(value:Boolean):Void {
		_glowBar = value;
		invalidate();
	}	
	
	// bar alpha
	private var _barAlpha:Number;
	public function get barAlpha():Number { return _barAlpha; }
	public function set barAlpha(value:Number) {
		_barAlpha = validateAlpha( value );
		invalidate();
	}
	
	// bar scale X
	private var _barScaleX:Number;
	public function get barScaleX():Number { return _barScaleX; }
	public function set barScaleX(value:Number) {
		_barScaleX = validateScale( value );
		Layout();
	}
	
	// bar scale Y
	private var _barScaleY:Number;
	public function get barScaleY():Number { return _barScaleY; }
	public function set barScaleY(value:Number) {
		_barScaleY = validateScale( value );
		Layout();
	}


	// overall hud alpha
	private var _hudAlpha:Number;
	public function get hudAlpha():Number { return _hudAlpha; }
	public function set hudAlpha(value:Number) {
		_hudAlpha = validateAlpha( value );
		invalidate();
	}
	
	// overall hud scale
	private var _hudScale:Number;
	public function get hudScale():Number { return _hudScale; }
	public function set hudScale(value:Number) {
		_hudScale = validateScale( value );
		Layout();
	}

	
	// hud enabled/disabled toggle
	private var _hudEnabled:Boolean;
	public function get hudEnabled():Boolean { return _hudEnabled; }
	public function set hudEnabled(value:Boolean):Void {
		_hudEnabled = value;
		
		_ultimateAbilityHUDState.SetValue( _hudEnabled ? "enabled" : "disabled" );
		
		invalidate();
	}

	
	// animation timings
	
	private var _animationTime:Number;
	public function get animationTime():Number { return _animationTime; }
	public function set animationTime(value:Number):Void {
		_animationTime = value;
		invalidate();
	}	
	
	private var _fadeInTime:Number;
	public function get fadeInTime():Number { return _fadeInTime; }
	public function set fadeInTime(value:Number):Void {
		_fadeInTime = value;
		invalidate();
	}	

	private var _fadeOutTime:Number;
	public function get fadeOutTime():Number { return _fadeOutTime; }
	public function set fadeOutTime(value:Number):Void {
		_fadeOutTime = value;
		invalidate();
	}	
	
	
	// tints
	private var _tints:Object = { none: 0xffffff };
	
	public function get tintThreatened():Number { return _tints.threatened };
	public function set tintThreatened(value:Number):Void {
		_tints.threatened = validateTint( value );
		invalidate();
	}
	
	public function get tintCombat():Number { return _tints.combat };
	public function set tintCombat(value:Number):Void {
		_tints.combat = validateTint( value );
		invalidate();
	}


	private var _visualUpdatesSuspended:Boolean;
	public function get visualUpdatesSuspended() : Boolean { return _visualUpdatesSuspended; }
	public function set visualUpdatesSuspended(value:Boolean) : Void {
		_visualUpdatesSuspended = value;
		
		// redraw if coming out of a suspended period
		if ( !value && _configured ) {
			invalidate();
		}
	}

	public function get isInConfigMode() : Boolean { return Boolean(_configMode.GetValue()); }
	
	public function get combatState() : String {
		if ( _character.IsInCombat() ) return "combat";
		if ( _character.IsThreatened() ) return "threatened";
		
		return "none";
	}
	
	
	// filenames for custom icons
	public function get combatIconFilename() : String { return "combat.png"; }
	public function get threatenedIconFilename() : String { return "threatened.png"; }
	
	public function get animaEnergy() : Number {
		return _character.GetStat( e_AnimaEnergyStat, 2 );
	}
	
	public function get animaEnergyFull() : Boolean {
		return animaEnergy >= 100;
	}
	
	public function get animaAbilityUnlocked() : Boolean {
		return !Lore.IsLocked( e_UltimateAbilityUnlockID );
	}
}