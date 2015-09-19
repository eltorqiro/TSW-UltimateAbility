import com.Utils.GlobalSignal;

import com.Utils.Signal;
import GUIFramework.ClipNode;
import GUIFramework.SFClipLoader;
import com.GameInterface.LoreBase;
import com.GameInterface.DistributedValue;

import com.GameInterface.UtilsBase;
import com.GameInterface.LogBase;

import com.ElTorqiro.UltimateAbility.Const;
import com.ElTorqiro.UltimateAbility.AddonUtils.Preferences;
import com.ElTorqiro.UltimateAbility.AddonUtils.VTIOConnector;
import com.ElTorqiro.UltimateAbility.AddonUtils.CommonUtils;


/**
 * 
 * 
 */
class com.ElTorqiro.UltimateAbility.App {
	
	// static class only
	private function App() { }
	
	// starts the app running
	public static function start( host:MovieClip ) {

		if ( running ) return;
		_running = true;
		
		debug( "App: start" );

		hostMovie = host;
		hostMovie._visible = false;
		
		// load preferences
		prefs = new Preferences( Const.PrefsName );
		createPrefs();
		prefs.load();

		// perform initial installation tasks
		install();
		
		// attach widget
		widgetClip = SFClipLoader.LoadClip( Const.WidgetClipPath, Const.AppID + "_Widget", false, Const.WidgetClipDepthLayer, Const.WidgetClipSubDepth, [] );
		widgetClip.SignalLoaded.Connect( widgetLoaded );
	
		// attach hud
		hudMovie = hostMovie.attachMovie( "HUD", "m_HUD", hostMovie.getNextHighestDepth() );
		LoreBase.SignalTagAdded.Disconnect( loreTagAddedHandler );
		
		// listen for GUI edit mode signal, to retain state so the HUD can use it even if the HUD is not enabled when the signal is emitted
		GlobalSignal.SignalSetGUIEditMode.Connect( guiEditModeChangeHandler );
		
		// listen for pref changes and route to appropriate behaviour
		prefs.SignalValueChanged.Connect( prefChangeHandler );
		
	}

	/**
	 * stop app running and clean up resources
	 */
	public static function stop() : Void {
		
		debug( "App: stop" );
		
		// stop listening for pref value changes
		prefs.SignalValueChanged.Disconnect( prefChangeHandler );

		// stop listening for gui edit mode signal
		GlobalSignal.SignalSetGUIEditMode.Disconnect( guiEditModeChangeHandler );
		
		// unload widget
		SFClipLoader.UnloadClip( Const.AppID + "_Widget" );
		widgetClip = null;

		// unload hud
		LoreBase.SignalTagAdded.Disconnect( loreTagAddedHandler );
		hudMovie.removeMovieClip();
		hudMovie = null;
		
		// remove prefs
		prefs.dispose();
		prefs = null;
		
		_running = false;
	}
	
	/**
	 * make the app active
	 * - typically called by OnModuleActivated in the module
	 */
	public static function activate() : Void {
		
		debug( "App: activate" );
		
		_active = true;
		
		// component clip visibility
		widgetClip.m_Movie._visible = true;
		manageVisibility();
		
		// manipulate default ui elements
		manageDefaultUiAnimaEnergyBar();
		
		// manage config window
		showConfigWindowMonitor = DistributedValue.Create( Const.ShowConfigWindowDV );
		showConfigWindowMonitor.SetValue( false );
		showConfigWindowMonitor.SignalChanged.Connect( manageConfigWindow );

	}
	
	/**
	 * make the app inactive
	 * - typically called by OnModuleDeactivated in the module
	 */
	public static function deactivate() : Void {
		
		debug( "App: deactivate" );
		
		_active = false;

		// destroy config window
		showConfigWindowMonitor.SetValue ( false );
		showConfigWindowMonitor.SignalChanged.Disconnect( manageConfigWindow );
		showConfigWindowMonitor = null;

		// restore default ui elements
		manageDefaultUiAnimaEnergyBar();
		
		// component clip visibility
		widgetClip.m_Movie._visible = false;
		manageVisibility();
		
		// save settings
		prefs.save();
	}

	/**
	 * populate pref object with app entries
	 */
	private static function createPrefs() : Void  {
		
		prefs.add( "prefs.version", Const.PrefsVersion );
		
		prefs.add( "app.installed", false );
		
		prefs.add( "configWindow.position", undefined );
		prefs.add( "icon.position", undefined );
		prefs.add( "icon.scale", 100,
			function( newValue, oldValue ) {
				var value:Number = Math.min( newValue, Const.MaxWidgetScale );
				value = Math.max( value, Const.MinWidgetScale );
				
				return value;
			}
		);
		
		prefs.add( "hud.position", undefined );
		prefs.add( "hud.scale", 100,
			function( newValue, oldValue ) {
				var value:Number = Math.min( newValue, Const.MaxHudScale );
				value = Math.max( value, Const.MinHudScale );
				
				return value;
			}
		);

		prefs.add( "defaultUI.animaEnergyBar.hide", true );
		
		prefs.add( "hud.fullAnimaEnergy.glow.enable", true );
		prefs.add( "hud.fullAnimaEnergy.glow.intensity", 80,
			function( newValue, oldValue ) {
				var value:Number = Math.min( newValue, Const.MaxGlowIntensity );
				value = Math.max( value, Const.MinGlowIntensity );
				
				return value;
			}
		);
		
		prefs.add( "hud.tints.ophanim.blue", 			0x0088ff );
		prefs.add( "hud.tints.ophanim.gold", 			0xffd700 );
		prefs.add( "hud.tints.ophanim.purple", 			0x8800ff );
			
	}

	/**
	 * handle pref value changes and route to appropriate behaviour
	 * 
	 * @param	name
	 * @param	newValue
	 * @param	oldValue
	 */
	private static function prefChangeHandler( name:String, newValue, oldValue ) : Void {
		
		switch ( name ) {
			
			case "defaultUI.animaEnergyBar.hide":
				manageDefaultUiAnimaEnergyBar();
			break;
		
		}
		
	}
	
	/**
	 * triggers updates that need to occur after the widget clip has been loaded
	 * 
	 * @param	clipNode
	 * @param	success
	 */
	private static function widgetLoaded( clipNode:ClipNode, success:Boolean ) : Void {
		debug("App: widget loaded: " + success);
		
		vtio = new VTIOConnector( Const.AppID, Const.AppAuthor, Const.AppVersion, Const.ShowConfigWindowDV, widgetClip.m_Movie.m_Icon, registeredWithVTIO );
	}

	/**
	 * triggers updates that need to occur after the app has been registered with VTIO
	 * e.g. updating the state of the widget icon copy that VTIO creates
	 */
	private static function registeredWithVTIO() : Void {

		debug( "App: registered with VTIO" );
		
		// move clip to the depth required by VTIO icons
		SFClipLoader.SetClipLayer( SFClipLoader.GetClipIndex( widgetClip.m_Movie ), VTIOConnector.e_VtioDepthLayer, VTIOConnector.e_VtioSubDepth );
		
		_isRegisteredWithVtio = true;
		vtio = null;
	}
	
	/**
	 * shows or hides the config window
	 * 
	 * @param	show
	 */
	public static function manageConfigWindow() : Void {
		debug( "App: manageConfigWindow" );

		var clipName:String = Const.AppID + "_ConfigWindow";
		
		if ( active && showConfigWindowMonitor.GetValue() ) {
			
			if ( !configWindowClip ) {
				debug("App: loading config window");
				configWindowClip = SFClipLoader.LoadClip( Const.ConfigWindowClipPath, clipName, false, Const.ConfigWindowClipDepthLayer, Const.ConfigWindowClipSubDepth, [] );
			}
		}
		
		else if ( configWindowClip ) {
			SFClipLoader.UnloadClip( clipName );
			configWindowClip = null;
			
			debug("App: config window clip unloaded");

		}
	}

	/**
	 * control the visibility of the HUD
	 */
	private static function manageVisibility() : Void {
		hostMovie._visible = active && ( Boolean(isUltimateAbilityUnlocked) || guiEditMode );
	}

	/**
	 * manage the default anima energy bar ui visibility
	 */
	private static function manageDefaultUiAnimaEnergyBar( findThingId:String, thing, found:Boolean ) : Void {

		var animaEnergyBar:MovieClip = _root.passivebar.m_UltimateProgress;
		
		var hide:Boolean = active && prefs.getVal( "defaultUI.animaEnergyBar.hide" );
		
		// unhide attempts immediately, no need to wait as it should only be invisible if we made it so earlier
		if ( !hide ) {
			CommonUtils.cancelFindThing( "animaEnergyBar" );
			animaEnergyBar._visible = true;
			
			DistributedValue.Create( "ShowAnimaEnergyBar" );
			DistributedValue.SetDValue( "ShowAnimaEnergyBar", true );
		}
		
		// trying to hide and finder isn't performing a callback, start finder
		else if ( !findThingId ) {
			CommonUtils.findThing( "animaEnergyBar", "_root.passivebar.m_UltimateProgress", 20, 2000, manageDefaultUiAnimaEnergyBar, manageDefaultUiAnimaEnergyBar );
		}
		
		// trying to hide, and finder has found it
		else if ( found ) {
			animaEnergyBar._visible = false;
			
			DistributedValue.Create( "ShowAnimaEnergyBar" );
			DistributedValue.SetDValue( "ShowAnimaEnergyBar", false );
		}
		
	}

	/**
	 * handler for ultimate ability becoming unlocked
	 * 
	 * @param	tag
	 */
	private static function loreTagAddedHandler( tag:Number ) {
		if ( tag == Const.e_UltimateAbilityUnlockAchievement ) {
			manageVisibility();
		}
	}
	
	/**
	 * performs initial installation tasks
	 */
	private static function install() : Void {
		
		// only "install" once ever
		if ( !prefs.setVal( "app.installed" ) ) {;
		
			// hide default button
			var ultimateVisibilitySetting:DistributedValue = DistributedValue.Create( "ultimate_ability_visibility" );
			ultimateVisibilitySetting.SetValue( Const.e_UltimateVisibilitySettingNever );

			prefs.setVal( "app.installed", true );
		}
		
		// handle upgrades from one version to the next
		var prefsVersion:Number = prefs.getVal( "prefs.version" );
		
		// set prefs version to current version
		prefs.reset( "prefs.version" );
	}

	/**
	 * handles gui edit mode signal, to keep a constant track of edit mode state
	 * 
	 * @param	value
	 */
	private static function guiEditModeChangeHandler( edit:Boolean ) : Void {
		
		if ( guiEditMode != edit ) {
		
			var hudClipIndex:Number = SFClipLoader.GetClipIndex( hostMovie );
			var subDepth:Number = edit ? Const.HudClipSubDepthGuiEditMode : Const.HudClipSubDepth;
			
			SFClipLoader.SetClipLayer( hudClipIndex, Const.HudClipDepthLayer, subDepth );

			_guiEditMode = edit;
		
			manageVisibility();
		}
	}
	
	/**
	 * prints a message to the chat window if debug is enabled
	 * 
	 * @param	msg
	 */
	public static function debug( msg:String ) : Void {
		if ( !debugEnabled ) return;
		
		var message:String = Const.AppID + ": " + msg;
		
		UtilsBase.PrintChatText( message );
		LogBase.Print( 3, Const.AppID, message );
	}
	
	/*
	 * internal variables
	 */
	
	private static var hostMovie:MovieClip;
	private static var hudMovie:MovieClip;
	private static var widgetClip:ClipNode;
	private static var configWindowClip:ClipNode;
	
	private static var showConfigWindowMonitor:DistributedValue;
	
	private static var vtio:VTIOConnector;
	
	/*
	 * properties
	 */
	
	public static function get debugEnabled() : Boolean {
		return Boolean(DistributedValue.GetDValue( Const.DebugModeDV ));
	};
	 
	public static var prefs:Preferences;

	private static var _active:Boolean;
	public static function get active() : Boolean { return _active; }

	private static var _running:Boolean;
	public static function get running() : Boolean { return Boolean(_running); }
	
	private static var _guiEditMode:Boolean;
	public static function get guiEditMode() : Boolean { return _guiEditMode; }
	
	private static var _isRegisteredWithVtio:Boolean;
	public static function get isRegisteredWithVtio() : Boolean { return _isRegisteredWithVtio; }
	
	public static function get isUltimateAbilityUnlocked() : Boolean {
		return !LoreBase.IsLocked( Const.e_UltimateAbilityUnlockAchievement );
	}

}