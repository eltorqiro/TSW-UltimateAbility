import com.Components.WinComp;

import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Tooltip.TooltipManager;

import mx.transitions.easing.Strong;
import mx.transitions.Fade;

import flash.geom.Point;
import mx.utils.Delegate;

import com.GameInterface.DistributedValue;
import com.Utils.Archive;

import com.ElTorqiro.UltimateAbility.AddonInfo;
import com.ElTorqiro.UltimateAbility.AddonUtils.AddonUtils;

// config window
//var g_configWindow:WinComp;
var g_configWindow;

// internal distributed value listeners
var g_showConfig:DistributedValue;

// hud visible DV
var g_HUDState:DistributedValue;

// Viper's Top Bar Information Overload (VTIO) integration
var g_VTIOIsLoadedMonitor:DistributedValue;
var g_isRegisteredWithVTIO:Boolean = false;

// icon objects
var g_icon:MovieClip;
var g_tooltip:TooltipInterface;

// config settings
var g_settings:Object;


/**
 * OnLoad
 * 
 * This has GMF_DONT_UNLOAD in Modules.xml so TSW module manager will not unload it during teleports etc.
 * Thus, all the global variables will persist, like settings and icon etc, only needing to be refreshed during onLoad() and saved during onUnload().
 */
function onLoad()
{
	// default config module settings
	g_settings = {
		configWindowPosition: new Point( 200, 200 ),
		iconPosition: new Point( (Stage.visibleRect.width - g_icon._width) / 2, (Stage.visibleRect.height - g_icon._width) / 4 ),
		iconScale: 100
	};

	// load module settings
	var loadData = DistributedValue.GetDValue(AddonInfo.ID + "_Config_Data");
	for ( var i:String in g_settings ) {
		g_settings[i] = loadData.FindEntry( i, g_settings[i] );
	}

	CreateIcon();
	
	// VTIO integration, but don't try to reregister
	if ( !g_isRegisteredWithVTIO )
	{
		g_VTIOIsLoadedMonitor = DistributedValue.Create("VTIO_IsLoaded");
		g_VTIOIsLoadedMonitor.SignalChanged.Connect(CheckVTIOIsLoaded, this);

		// handle race condition for DV already having been set before our listener was connected
		CheckVTIOIsLoaded();
	}

	// hud enabled connector
	g_HUDState = DistributedValue.Create(AddonInfo.ID + "_HUD_State");
	g_HUDState.SignalChanged.Connect(StateHandler, this);
	StateHandler();
	
	// config window toggle listener
	g_showConfig = DistributedValue.Create(AddonInfo.ID + "_ShowConfig");
	g_showConfig.SignalChanged.Connect(ToggleConfigWindow, this);
}


function OnModuleActivated() : Void {
	
}

function OnModuleDeactivated( ): Void {
	// destroy config window
	g_showConfig.SetValue(false);
}

function OnUnload() : Void {
	
	g_VTIOIsLoadedMonitor.SignalChanged.Disconnect(CheckVTIOIsLoaded, this);
	g_HUDState.SignalChanged.Disconnect(StateHandler, this);
	g_showConfig.SignalChanged.Disconnect(ToggleConfigWindow, this);
	
	// save module settings
	var data:Archive = new Archive();
	for(var i:String in g_settings)	{
		data.AddEntry( i, g_settings[i] );
	}
	
	// becaues LoginPrefs.xml has a reference to this DValue, the contents will be saved whenever the game thinks it is necessary (e.g. closing the game, reloadui etc)
	DistributedValue.SetDValue(AddonInfo.ID + "_Config_Data", data);
}

function CheckVTIOIsLoaded() : Void  {
	
	// don't re-register with VTIO
	if ( !g_isRegisteredWithVTIO && g_VTIOIsLoadedMonitor.GetValue() )
	{
		// register with VTIO
		DistributedValue.SetDValue("VTIO_RegisterAddon", 
			AddonInfo.ID + "|" + AddonInfo.Author + "|" + AddonInfo.Version + "|" + AddonInfo.ID + "_ShowConfig|" + g_icon
		);
		
		g_isRegisteredWithVTIO = true;
		
		// recreate icon tooltip info to remove the icon handling instructions
		CreateTooltipData();
	}
}

function CreateIcon() : Void {
	
	// don't recreate if already there
	if ( g_icon != undefined )  return;
	
	// load config icon & tooltip
	g_icon = this.attachMovie("com.ElTorqiro.UltimateAbility.Config.Icon", "m_Icon", this.getNextHighestDepth() );

	// restore location
	g_icon._x = g_settings.iconPosition.x;
	g_icon._y = g_settings.iconPosition.y;
	g_icon._xscale = g_icon._yscale = g_settings.iconScale;
	// check for position sanity -- visible rect may have changed between sessions, don't want the icon to be positioned off screen
	PositionIcon();
	
	// add icon mouse event handlers
	g_icon.onMousePress = function(buttonID) {
		
		// dragging icon with CTRL held down, only if VTIO not present
		if ( !g_isRegisteredWithVTIO && buttonID == 1 && Key.isDown(Key.CONTROL) ) {
			CloseTooltip();
			g_icon.startDrag();
		}
		
		// left mouse click, toggle config window
		else if ( buttonID == 1 ) {
			CloseTooltip();
			DistributedValue.SetDValue(AddonInfo.ID + "_ShowConfig",	!DistributedValue.GetDValue(AddonInfo.ID + "_ShowConfig"));
		}
		
		// right click, toggle hud enabled/disabled
		else if ( buttonID == 2 ) {
			
			_root["eltorqiro_ultimateability\\hud"].g_HUD.hudEnabled = !_root["eltorqiro_ultimateability\\hud"].g_HUD.hudEnabled;
		}
		
		// reset icon scale, only if VTIO not present
		else if (!g_isRegisteredWithVTIO && buttonID == 2 && Key.isDown(Key.CONTROL)) {
			ScaleIcon(100);
		}
	};
	
	// stop dragging icon
	g_icon.onRelease = g_icon.onReleaseOutside = function() {
		if ( !g_isRegisteredWithVTIO )  g_icon.stopDrag();
		PositionIcon();
	};
	
	// resize icon with CTRL mousewheel
	g_icon.onMouseWheel = function(delta) {
		if ( !g_isRegisteredWithVTIO && Key.isDown(Key.CONTROL))
		{
			CloseTooltip();
			
			// determine scale
			var scaleTo:Number = g_icon._xscale + (delta * 5);
			scaleTo = Math.max(scaleTo, 35);
			scaleTo = Math.min(scaleTo, 100);
			ScaleIcon(scaleTo);
		}
	};
	
	// mouse hover, show tooltip
	g_icon.onRollOver = function() {
		OpenTooltip();
	};

	// mouse out, hide tooltip
	g_icon.onRollOut = function()
	{
		CloseTooltip();
	};
}

function OpenTooltip() : Void {
	CloseTooltip();
	g_tooltip = TooltipManager.GetInstance().ShowTooltip( undefined, TooltipInterface.e_OrientationVertical, 0, CreateTooltipData() );
}

function CreateTooltipData() : TooltipData {
	
	var state:String = g_HUDState.GetValue();
	
	// create icon tooltip data
	var td:TooltipData = new TooltipData();
	td.AddAttribute("","<font face=\'_StandardFont\' size=\'14\' color=\'#00ccff\'><b>" + AddonInfo.Name + " v" + AddonInfo.Version + "</b></font>");
	td.AddAttributeSplitter();
	
	td.AddAttribute("","");
	td.AddAttribute("", "<font face=\'_StandardFont\' size=\'11\' color=\'#BFBFBF\'><b>Left Click</b> Open/Close configuration window.\n<b>Right Click</b> Enable/Disable HUD.</font>");
	
	// show icon handling control instructions if VTIO has not hijacked the icon
	if ( !g_isRegisteredWithVTIO )
	{
		td.AddAttributeSplitter();
		td.AddAttribute("","");		
		td.AddAttribute("", "<font face=\'_StandardFont\' size=\'12\' color=\'#FFFFFF\'><b>Icon</b>\n</font><font face=\'_StandardFont\' size=\'11\' color=\'#BFBFBF\'><b>CTRL + Left Drag</b> Move icon.\n<b>CTRL + Roll Mousewheel</b> Resize icon.\n<b>CTRL + Right Click</b> Reset icon size to 100%.</font>");
	}

	td.AddAttributeSplitter();
	td.AddAttribute("","");	
	td.AddAttribute("", "<font face=\'_StandardFont\' size=\'12\' color=\'#FFFFFF\'>Open the config window to enable the HUD movement controls.</font>");
	td.m_Padding = 8;
	td.m_MaxWidth = 256;
	
	return td;
}

function CloseTooltip() : Void {
	if( g_tooltip != undefined )  g_tooltip.Close();
}

function ScaleIcon( scale:Number ) : Void {
	
	if ( g_icon != undefined && !g_isRegisteredWithVTIO )
	{
		var oldWidth:Number = g_icon._width;
		var oldHeight:Number = g_icon._height;

		g_icon._xscale = g_icon._yscale = scale;
		
		// scale around centre of icon
		PositionIcon( g_icon._x - (g_icon._width - oldWidth) / 2, g_icon._y - (g_icon._height - oldHeight) / 2 );

		g_settings.iconScale = scale;
	}
}

function PositionIcon( x:Number, y:Number ) : Void { 
	
	if ( g_icon != undefined && !g_isRegisteredWithVTIO )
	{
		if ( x != undefined )  g_icon._x = x;
		if ( y != undefined )  g_icon._y = y;
		
		var onScreenPos:Point = AddonUtils.OnScreen( g_icon );
		
		g_icon._x = onScreenPos.x;
		g_icon._y = onScreenPos.y;
		
		g_settings.iconPosition = new Point(g_icon._x, g_icon._y);
	}
}


function ToggleConfigWindow() : Void {
	g_showConfig.GetValue() ? CreateConfigWindow() : DestroyConfigWindow();
}

function CreateConfigWindow() : Void {
	
	// do nothing if window already open

	if ( g_configWindow )  return;
	
	g_configWindow = WinComp(attachMovie( "com.ElTorqiro.UltimateAbility.Config.WindowComponent", "m_ConfigWindow", getNextHighestDepth() ));
	g_configWindow.SetTitle(AddonInfo.Name + " v" + AddonInfo.Version);
	g_configWindow.ShowStroke(false);
	g_configWindow.ShowFooter(false);
	g_configWindow.ShowResizeButton(false);

	// load the content panel
	g_configWindow.SetContent( "com.ElTorqiro.UltimateAbility.Config.WindowContent" );
	
	// set position -- rounding of the values is critical here, else it will not reposition reliably
	g_configWindow._x = Math.round(g_settings.configWindowPosition.x);

	var windowY:Number = Math.round(g_settings.configWindowPosition.y);
	g_configWindow._y = windowY + 10;
	g_configWindow._alpha = 0;
	g_configWindow.tweenTo( 0.3, { _y: windowY, _alpha: 100 }, Strong.easeInOut );
	
	// wire up close button
	g_configWindow.SignalClose.Connect( function() {
		g_showConfig.SetValue(false);
	}, this);
}

function DestroyConfigWindow() : Void {

	if ( g_configWindow ) {
		
		g_configWindow.onTweenComplete = function() {
			this.removeMovieClip();
		};
		
		g_configWindow.tweenTo( 0.3, { _alpha: 0 }, Strong.easeOut );
		
		g_configWindow.GetContent().Destroy();
		
		g_settings.configWindowPosition.x = g_configWindow._x;
		g_settings.configWindowPosition.y = g_configWindow._y;
	}
}

function StateHandler( retry:Boolean ) : Void {
	
	var state:String = g_HUDState.GetValue();
	if ( state == undefined ) state = "locked";
	
	g_icon.gotoAndStop( state );
	this["Icon"].gotoAndStop( state );
	
	// in case state has been toggled, trigger a refresh of the config window
	g_configWindow.GetContent().LoadValues();
	
	
	/* VTIO doesn't use your original icon, it creates a dupe, so a different approach is needed if integrated with VTIO
	 * proof: g_icon._alpha = 100; g_icon._visible = true; g_icon._y = 150; UtilsBase.PrintChatText("f:" + g_icon._currentframe);
	*/
	
	// hack to wait for VTIO to have created the dupe icon after a full reload
	// VTIO creates its dupe icon forcibly in your movieclip (so it can use your SWFs assets) as "Icon"
	if ( !retry && this["Icon"] == undefined ) {
		_global.setTimeout( Delegate.create( this, StateHandler), 500 );
	}
}
