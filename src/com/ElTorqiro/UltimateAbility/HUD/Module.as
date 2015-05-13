import com.GameInterface.DistributedValue;
import com.Utils.Archive;
import com.GameInterface.Game.Character;

import com.ElTorqiro.UltimateAbility.HUD.HUD;
import com.ElTorqiro.UltimateAbility.AddonInfo;
import com.ElTorqiro.UltimateAbility.HUD.SettingsPacks;

import com.GameInterface.UtilsBase;

// the HUD instance
var g_HUD:HUD;

// settings persistence objects
var g_playfieldMemoryBlacklist:Object;
var g_playfieldMemoryAutoSwap:Object;

var g_data:DistributedValue;
var g_playfieldMemory:DistributedValue;

//Init
function onLoad() : Void {
	g_data = DistributedValue.Create( AddonInfo.ID + "_HUD_Data" );
}

// module activated (i.e. its distributed value set to 1)
function OnModuleActivated() : Void {
	
	// load settings
	var settings:Object = { };
	var settingsTemplate:Object = SettingsPacks.defaultSettings;
	var data:Archive = g_data.GetValue();

	// get any available HUD settings
	for ( var s:String in settingsTemplate ) {
		var setting = data.FindEntry( 'setting.' + s );
		if ( setting != undefined ) {
			settings[s] = setting;
		}
	}
	
	// load playfield memory lists
	var data:Archive = DistributedValue.GetDValue(AddonInfo.ID + "_HUD_PlayfieldMemory");

	// instantiate hud
	g_HUD = HUD(attachMovie( "com.ElTorqiro.UltimateAbility.HUD.HUD", "m_HUD", getNextHighestDepth(), { settings: settings } ));
}


// module deactivated (i.e. its distributed value set to 0)
function OnModuleDeactivated() : Void {

	// push data into DVs ready for game to save them
	
	// HUD settings
	var settingsTemplate:Object = SettingsPacks.defaultSettings;
	var data:Archive = new Archive();
	
	for ( var s:String in settingsTemplate ) {
		var setting = g_HUD[s];
		if ( setting != undefined ) {
			data.AddEntry( 'setting.' + s, setting );
		}
	}
	
	g_data.SetValue( data );

	// remove HUD
	g_HUD.removeMovieClip();
}
