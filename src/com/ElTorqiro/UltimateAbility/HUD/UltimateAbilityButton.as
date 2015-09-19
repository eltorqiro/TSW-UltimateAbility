import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import flash.geom.Point;
import gfx.core.UIComponent;
import com.GameInterface.Tooltip.*;
import mx.utils.Delegate;
import flash.filters.GlowFilter;
import mx.transitions.easing.Strong;

import com.GameInterface.Game.Shortcut;
import com.GameInterface.Game.ShortcutData;

import com.Utils.GlobalSignal;
import com.Utils.Signal;

import com.ElTorqiro.UltimateAbility.App;
import com.ElTorqiro.UltimateAbility.AddonUtils.CommonUtils;
import com.ElTorqiro.UltimateAbility.Const;


/**
 * 
 * 
 */
class com.ElTorqiro.UltimateAbility.HUD.UltimateAbilityButton extends UIComponent {

	/**
	 * constructor
	 */
	public function UltimateAbilityButton() {
		
		// start up invisible
		visible = false;
		
		// hack to provide more appropriate size of the button under 100% hud scale
		_width *= 0.55;
		_height *= 0.55;
		
		animaEnergy = 0;
		
		abilityColourMap = { };
		abilityColourMap[ Const.e_OphanimBlue ] = "blue";
		abilityColourMap[ Const.e_OphanimPurple ] = "purple";
		abilityColourMap[ Const.e_OphanimGold ] = "gold";

	}

	private function configUI() : Void {
		
		onReleaseOutside = this["onReleaseOutsideAux"] = onRollOut;
		
		// reference for player character
		character = Character.GetClientCharacter();

		// listen for ability being added to slot, so correct colour can be used
		Shortcut.SignalShortcutAdded.Connect( shortcutAddedHandler, this );
		
		// hotkey text
		t_Hotkey.textAutoSize = "shrink";
		
		showHotkeysOnAbilities = DistributedValue.Create( "ShortcutbarHotkeysVisible" );
		showHotkeysOnAbilities.SignalChanged.Connect( refreshHotkey, this );
		Shortcut.SignalHotkeyChanged.Connect( refreshHotkey, this );

		refreshHotkey();
		
		// listen for anima energy change events
		character.SignalStatChanged.Connect( updateAnimaEnergy, this );
		updateAnimaEnergy();
		
		// listen for pref changes and route to appropriate behaviour
		App.prefs.SignalValueChanged.Connect( prefChangeHandler, this );
		
		visible = true;
	}

	private function draw() : Void {

		var tint:Number = App.prefs.getVal( "hud.tints.ophanim." + abilityColourMap[ Shortcut.m_ShortcutList[Const.e_UltimateShortcutSlot].m_SpellId ] );
		if ( tint == undefined ) {
			tint = Const.TintNone;
		}
		
		CommonUtils.Colorize( m_Fill, tint );
		
		if ( isAnimaEnergyFull ) {
			m_Icon.gotoAndStop( "full" );
			filters = App.prefs.getVal( "hud.fullAnimaEnergy.glow.enable" ) ?
				[ new GlowFilter(tint, 0.8, 16, 16, App.prefs.getVal( "hud.fullAnimaEnergy.glow.intensity" ) / 100, 3, false, false) ] : [];
			CommonUtils.Colorize( m_Icon, tint );
		}
		
		else {
			m_Icon.gotoAndStop( "progress" );
			filters = [];
			CommonUtils.Colorize( m_Icon, Const.TintNone );
		}
	}
	
	private function onPress( controllerIdx:Number, keyboardOrMouse:Number, button:Number ) {
		
		// left clicks only
		if ( button == 0 /*&& animaEnergyFull */ ) {
			Shortcut.UseShortcut( Const.e_UltimateShortcutSlot );
		}
		
	}

	private function onRollOver() : Void {
		openTooltip();
	}
	
	private function onRollOut(): Void {
		closeTooltip();
	}

	
    private function openTooltip() : Void {
		// close any existing tooltip
		closeTooltip();
		
		var tooltipData:TooltipData = TooltipDataProvider.GetShortcutbarTooltip( Const.e_UltimateShortcutSlot );
		
		// add raw xp value
		//tooltipData.AddAttributeSplitter();
		tooltipData.AddAttribute('',  'Animus: <font color="#ffff00"><b>' + animaEnergy + '%</b></font>' );
		tooltipData.AddAttribute('',  '' );
		
		tooltip = TooltipManager.GetInstance().ShowTooltip( this, TooltipInterface.e_OrientationVertical, -1, tooltipData );
    }
    
    private function closeTooltip():Void {
		tooltip.Close();
		tooltip = undefined;
    }
	
	private function refreshHotkey() : Void {
		
		t_Hotkey._visible = showHotkeysOnAbilities.GetValue();
		
		t_Hotkey.text = ""; // needed to make flash understand the text is actually changed now - re-fetch the translation
		t_Hotkey.text = "<variable name='hotkey:Shortcutbar_Ultimate'/ >";
	}
	
	private function updateAnimaEnergy( stat:Number ) : Void {
		
		if ( stat != Const.e_AnimaEnergyStat && stat != undefined ) return;
		
		var oldAnimaEnergy:Number = animaEnergy;
		animaEnergy = Math.floor( character.GetStat( Const.e_AnimaEnergyStat, 2 ) * 100) / 100;

		if ( animaEnergy < 0 || animaEnergy == undefined ) {
			animaEnergy = 0;
		}
		
		else if ( animaEnergy > 100 ) {
			animaEnergy = 100;
		}
		
		if ( animaEnergy < oldAnimaEnergy || ( animaEnergy > oldAnimaEnergy && isAnimaEnergyFull ) ) {
			invalidate();
		}

		// progress fill
		m_Fill.m_Mask._yscale = animaEnergy;

	}
	
	private function shortcutAddedHandler( position:Number ) : Void {
		
		if ( position == Const.e_UltimateShortcutSlot ) {
			invalidate();
		}
		
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
			
			case "hud.fullAnimaEnergy.glow.enable":
			case "hud.fullAnimaEnergy.glow.intensity":
			case "hud.tints.ophanim.gold":
			case "hud.tints.ophanim.blue":
			case "hud.tints.ophanim.purple":
				invalidate();
			break;
			
		}
		
	}
	
	/**
	 * internal variables
	 */

	public var m_Icon:MovieClip;
	public var t_Hotkey:TextField;
	public var m_Fill:MovieClip;
	 
	private var character:Character;
	private var tooltip:TooltipInterface;
	
	private var showHotkeysOnAbilities:DistributedValue;

	private var abilityColourMap:Object;
	
	private var animaEnergy:Number;
	
	/**
	 * properties
	 */
	 
	public function get isAnimaEnergyFull() : Boolean {
		return animaEnergy >= 100;
	}
	
}