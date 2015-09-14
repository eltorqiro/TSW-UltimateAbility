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
	private var _tooltip:TooltipInterface;
	
	private var _findElementTimers:Object = { };

	// internal movieclips
	private var m_Ultimate:MovieClip;
	private var m_Overlay:MovieClip;

	// internal states
	private var _mouseDown:Number = -1;
	
	// config mode listener
	private var _configMode:DistributedValue;
	private var _gameGUIEditMode:Boolean;

	// game scaling mechanism settings
    private var _guiResolutionScale:DistributedValue;

	// game settings
	private var _ultimateVisibilitySetting:DistributedValue;
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
	}

	private function configUI() : Void {
		
		super.configUI();

		// button press for the HUD
		m_Ultimate.onPress = Delegate.create( this, function(controllerIdx:Number, keyboardOrMouse:Number, button:Number) {
			
			// left clicks only, and only if anima energy is full
			if ( button == 0 /*&& animaEnergyFull */ ) {
				Shortcut.UseShortcut( e_UltimateShortcutSlot );
			}
		});
		
		m_Ultimate.t_Hotkey.textAutoSize = "shrink";
		
		// tooltip show/hide
		m_Ultimate.onRollOver = Delegate.create( this, OpenTooltip );
		m_Ultimate.onRollOut = Delegate.create( this, CloseTooltip );
		
		// setup mouse handlers for config mode overlay
		m_Overlay.onPress = Delegate.create(this, handleMousePress);
		m_Overlay.onRelease = Delegate.create(this, handleMouseRelease);
		m_Overlay.onReleaseOutside = Delegate.create(this, handleReleaseOutside);
		m_Overlay["onPressAux"] = m_Overlay.onPress;
		m_Overlay["onReleaseAux"] = m_Overlay.onRelease;
		m_Overlay["onReleaseOutsideAux"] = m_Overlay.onReleaseOutside;

		// setup tween finishing handler for overlay fade in/out
		m_Overlay.onTweenComplete = Delegate.create( this, finaliseTween );
		m_Ultimate.onTweenComplete = Delegate.create( this, finaliseTween );
		
		// reference for player character
		_character = Character.GetClientCharacter();

		// listen for resolution changes
		_guiResolutionScale = DistributedValue.Create("GUIResolutionScale");
		_guiResolutionScale.SignalChanged.Connect( Layout, this );

		// hud enabled/disabled toggle
		_ultimateAbilityHUDState = DistributedValue.Create( AddonInfo.ID + "_HUD_State" );

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

		// mod config mode listener
		_configMode = DistributedValue.Create( AddonInfo.ID + "_ShowConfig" );
		_configMode.SignalChanged.Connect( stateTriggerHandler, this );

		com.Utils.GlobalSignal.SignalSetGUIEditMode.Connect( gameGUIEditModeHandler, this );

		// game settings
		_ultimateVisibilitySetting = DistributedValue.Create( "ultimate_ability_visibility" );
		_ultimateVisibilitySetting.SignalChanged.Connect( stateTriggerHandler, this );

		_showHotkeysOnAbilities = DistributedValue.Create( "ShortcutbarHotkeysVisible" );
		_showHotkeysOnAbilities.SignalChanged.Connect( refreshHotkey, this );

		// hotkey text listener
		Shortcut.SignalHotkeyChanged.Connect( refreshHotkey, this );
		refreshHotkey();
		
		// stat listener, for anima energy change events
		_character.SignalStatChanged.Connect( statChangeHandler, this );
		
		// initial state
		stateTriggerHandler();
	}
	
	public function onUnload():Void {
		super.onUnload();

		// unwire signal listeners
		_configMode.SignalChanged.Disconnect( stateTriggerHandler, this );
		_guiResolutionScale.SignalChanged.Disconnect( Layout, this );

		// deafen game setting listeners
		_ultimateVisibilitySetting.SignalChanged.Disconnect( stateTriggerHandler, this );
		_showHotkeysOnAbilities.SignalChanged.Disconnect( refreshHotkey, this );
		com.Utils.GlobalSignal.SignalSetGUIEditMode.Disconnect( gameGUIEditModeHandler, this );

		Shortcut.SignalHotkeyChanged.Disconnect( refreshHotkey, this );

		_character.SignalStatChanged.Disconnect( statChangeHandler, this );
		
		// restore default progress bar UI
		hideDefaultAnimaProgressBar( false );
	}
	
	// hide or show default buttons
	public function hideDefaultAnimaProgressBar( hide:Boolean ) : Void {

		var pi:MovieClip = _root.passivebar.m_UltimateProgress;
		
		// wait for the panel to be loaded, as it actually gets unloaded during teleports etc, not just deactivated
		if ( pi == undefined ) {
			
			// only retry if we're trying to hide, otherwise assume the thing should have been on the stage already
			if ( hide ) {

				if ( _findElementTimers["defaultProgress"] == undefined ) {
					_findElementTimers["defaultProgress"] = { startedAt: new Date() };
				}
				
				// if the find period has ended, stop trying to find
				if ( (new Date()) - _findElementTimers["defaultProgress"].startedAt > 3000 )  {
					_global.clearTimeout( _findElementTimers["defaultProgress"].timeoutID );
					_findElementTimers["defaultProgress"] = undefined;
				}
				// otherwise try again
				else {
					_findElementTimers["defaultProgress"].timeoutID = _global.setTimeout( Delegate.create(this, hideDefaultAnimaProgressBar), 300, hide );
				}
			}
			
			return;
		}

		DistributedValue.Create( "ShowAnimaEnergyBar" );
		DistributedValue.SetDValue( "ShowAnimaEnergyBar", !hide );
		
		// if we reached this far, reset thrash
		_global.clearTimeout( _findElementTimers["defaultProgress"].timeoutID );
		_findElementTimers["defaultProgress"] = undefined;

		// hide/show
		pi._visible = !hide;
	}
	
	
	/**
	 * layout in default position on screen
	 */
	public function MoveToDefaultPosition():Void {

		// position near bottom middle of screen
		var visibleRect = Stage["visibleRect"];
		
		var pos:Point = new Point();
		
		pos.x = visibleRect.width / 2;
		pos.y = visibleRect.height - 150;	//-220 is default position on 1920x1080 resolution

		// update saved position
		position = pos;
	}

	// sets the position of elements, including scale, integrating with the game's resolution
	private function Layout():Void {

		// this is based on the GUI resolution and this hud scale
		var guiResolutionScale:Number = _guiResolutionScale.GetValue();
		
		// some sanity checks in case somehow the game isn't providing these
		if ( guiResolutionScale == undefined ) guiResolutionScale = 1;

		// apply the real final scale
		var realScale:Number = guiResolutionScale * hudScale;
		
		// overlay wrapper
		var rect:Object = m_Ultimate.getBounds(m_Ultimate);
		
		m_Overlay._x = rect.xMin;
		m_Overlay._y = rect.yMin;
		m_Overlay._width = Math.abs(rect.xMin) + Math.abs(rect.xMax);
		m_Overlay._height = Math.abs(rect.yMin) + Math.abs(rect.yMax);
		
		this._xscale = this._yscale = realScale;
	}
	

    private function OpenTooltip() : Void {
		// close any existing tooltip
		CloseTooltip();
		
		var tooltipData:TooltipData = TooltipDataProvider.GetShortcutbarTooltip( e_UltimateShortcutSlot );
		
		// add raw xp value
		//tooltipData.AddAttributeSplitter();
		tooltipData.AddAttribute('',  'Animus: <font color="#ffff00"><b>' + animaEnergy + '%</b></font>' );
		tooltipData.AddAttribute('',  '' );
		
		_tooltip = TooltipManager.GetInstance().ShowTooltip( m_Ultimate, TooltipInterface.e_OrientationVertical, -1, tooltipData );
    }
    
    private function CloseTooltip():Void {
		_tooltip.Close();
		_tooltip = undefined;
    }
	
	
	private function finaliseTween() : Void {
		
		// hide the elements to prevent clicks
		m_Overlay._visible = m_Overlay._alpha > 0;
		m_Ultimate._visible = m_Ultimate._alpha > 0;
	}
	
	private function gameGUIEditModeHandler( edit:Boolean ) : Void {
		_gameGUIEditMode = edit;
		stateTriggerHandler();
	}
	
	private function refreshHotkey() : Void {
		
		m_Ultimate.t_Hotkey._visible = showHotkeys;
		
		m_Ultimate.t_Hotkey.text = ""; // needed to make flash understand the text is actually changed now - re-fetch the translation
		m_Ultimate.t_Hotkey.text = "<variable name='hotkey:Shortcutbar_Ultimate'/ >";
	}
	
	private function stateTriggerHandler() : Void {
		// config mode overlay
		var overlayOn:Boolean;
		var ultimateOn:Boolean;
		
		var fadeIn:Number = fadeInTime / 1000;
		var fadeOut:Number = fadeOutTime / 1000;
		
		// if in config mode, always show everything
		if ( isInConfigMode ) {
			visible = true;
			overlayOn = true;
			ultimateOn = true;
			
			m_Overlay._visible = true;
			m_Ultimate._visible = true;
		}
		
		else {
			var visibilitySetting:Number = _ultimateVisibilitySetting.GetValue();
			
			if ( hudEnabled && ultimateAbilityUnlocked ) {
				/*
				if ( useUltimateVisibilitySetting ) {
					if ( visibilitySetting == e_UltimateVisibilitySettingAlways || (visibilitySetting == e_UltimateVisibilitySettingCharged && animaEnergyFull) ) {
						ultimateOn = true;
					}
				}
				
				else {
					ultimateOn = true;
				}
				*/
				ultimateOn = true;
			}
			
			if ( ultimateOn ) {
				m_Ultimate._visible = true;
				visible = true;
			}
		}
		
		m_Overlay.tweenTo( overlayOn ? fadeIn : fadeOut, { _alpha: overlayOn ? 100 : 0 }, Strong.easeOut );
		m_Ultimate.tweenTo( ultimateOn ? fadeIn : fadeOut, { _alpha: ultimateOn ? hudAlpha : 0 }, Strong.easeOut );
	}
	
	private function statChangeHandler( stat:Number ) : Void {
		
		if ( stat == e_AnimaEnergyStat ) {
			invalidate();
		}
	}
	
	// highlight active aegis slot
	private function draw() : Void {
		
		if ( visualUpdatesSuspended || !_configured ) return;

		// progress fill
		m_Ultimate.m_Fill.m_Mask._yscale = animaEnergy;
		
		if ( animaEnergyFull ) {
			m_Ultimate.m_Icon.gotoAndStop( "full" );
			m_Ultimate.filters = glowWhenFull ? [ new GlowFilter(tintFullGlow, 0.8, 16, 16, 0.5, 3, false, false) ] : [];
		}
		
		else {
			m_Ultimate.m_Icon.gotoAndStop( "progress" );
			m_Ultimate.filters = [];
		}
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

	// restore default tints
	public function ApplyDefaultTints():Void {
		
		var defaults:Object = SettingsPacks.defaultSettings;
		
		visualUpdatesSuspended = true;
		
		tintFullGlow = defaults.tintFullGlow;
		
		visualUpdatesSuspended = false;
	}
	
	// restore all settings to default
	public function ApplyDefaultSettings() : Void {
		ApplySettingsPack( SettingsPacks.defaultSettings );
		
		MoveToDefaultPosition();
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

		hideDefaultAnimaProgressBar(_hideDefaultUI);
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

	
	public function get showHotkeys() : Boolean {
		return _showHotkeysOnAbilities.GetValue();
	}

	
	private var _glowWhenFull:Boolean;
	public function get glowWhenFull():Boolean { return _glowWhenFull; }
	public function set glowWhenFull(value:Boolean):Void {
		_glowWhenFull = value;
		invalidate();
	}	
	

	// overall hud alpha
	private var _hudAlpha:Number;
	public function get hudAlpha():Number { return _hudAlpha; }
	public function set hudAlpha(value:Number) {
		_hudAlpha = validateAlpha( value );
		stateTriggerHandler();
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
		
		stateTriggerHandler();
	}

	
	// animation timings
	
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
	
	public function get tintFullGlow():Number { return _tints.fullGlow };
	public function set tintFullGlow(value:Number):Void {
		_tints.fullGlow = validateTint( value );
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

	public function get isInConfigMode() : Boolean { 
		return _configMode.GetValue() || _gameGUIEditMode;
	}
	

	public function get animaEnergy() : Number {
		var raw:Number = _character.GetStat( e_AnimaEnergyStat, 2 );
		
		if ( raw <= 0 ) return 0;
		else if ( raw >= 100 ) return 100;
		else return Math.floor( raw * 100) / 100;
	}
	
	public function get animaEnergyFull() : Boolean {
		return animaEnergy >= 100;
	}
	
	public function get ultimateAbilityUnlocked() : Boolean {
		return !Lore.IsLocked( e_UltimateAbilityUnlockID );
	}
}