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

import com.GameInterface.FeatInterface;
import com.GameInterface.FeatData;


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
		
		// populate list of available ultimate abilities
		buildAbilityList();
		
	}

	private function configUI() : Void {
		
		onReleaseOutside = this["onReleaseOutsideAux"] = onRollOut;
		this["onPressAux"] = onPress;
		
		// reference for player character
		character = Character.GetClientCharacter();

		// listen for ability being added to slot, so correct colour can be used
		Shortcut.SignalShortcutAdded.Connect( shortcutSignalHandler, this );
		Shortcut.SignalShortcutRemoved.Connect( shortcutSignalHandler, this );

		// listen for ability bar being opened and refresh
		Shortcut.SignalSwapBar.Connect( refreshUltimateShortcuts, this );
		Shortcut.SignalRestoreSwapBar.Connect( refreshUltimateShortcuts, this );
		
		// listen for the available abilities being refreshed
		FeatInterface.SignalFeatListRebuilt.Connect( buildAbilityList, this );
		FeatInterface.SignalFeatTrained.Connect( featTrainedHandler, this );
		
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

		t_Charge._visible = App.prefs.getVal( "hud.chargeNumber.enable" );
		
		var slottedAbility:Number = Shortcut.m_ShortcutList[Const.e_UltimateShortcutSlot].m_SpellId;
		var tintName:String;
		
		if ( slottedAbility == undefined ) {
			tintName = "empty";
		}
		
		else {
			tintName = abilityColourMap[ slottedAbility ];
			if ( tintName == undefined ) {
				tintName = "default";
			}
		}
		
		var tint:Number = App.prefs.getVal( "hud.tints.ophanim." + tintName );;
		var tintWings:Number = App.prefs.getVal( "hud.tints.ophanim." + tintName + ".wings" );
		var tintDefault:Number = App.prefs.getVal( "hud.tints.ophanim.default" );
		var tintWingsDefault:Number = App.prefs.getVal( "hud.tints.ophanim.default" );
		
		if ( isAnimaEnergyFull ) {

			// entire button glow
			filters = App.prefs.getVal( "hud.fullAnimaEnergy.glow.enable" ) ?
				[ new GlowFilter( App.prefs.getVal( "hud.fullAnimaEnergy.wings.tint" ) ? tint : tintDefault, 0.8, 16, 16, App.prefs.getVal( "hud.fullAnimaEnergy.glow.intensity" ) / 100, 3, false, false ) ] : [];
			
			// meter fill
			CommonUtils.colorize( m_Fill, App.prefs.getVal( "hud.fullAnimaEnergy.meter.tint" ) ? tint : tintDefault );
			m_Fill._alpha = App.prefs.getVal( "hud.fullAnimaEnergy.meter.transparency" );

			// wings
			m_Icon.gotoAndStop( "full" );
			CommonUtils.colorize( m_Icon, App.prefs.getVal( "hud.fullAnimaEnergy.wings.tint" ) ? tintWings : tintWingsDefault );
			m_Icon._alpha = App.prefs.getVal( "hud.fullAnimaEnergy.wings.transparency" );
			
		}
		
		else {
			
			// entire button glow
			filters = [];
			
			// meter fill
			CommonUtils.colorize( m_Fill, App.prefs.getVal( "hud.chargingAnimaEnergy.meter.tint" ) ? tint : tintDefault );
			m_Fill._alpha = App.prefs.getVal( "hud.chargingAnimaEnergy.meter.transparency" );

			// wings
			m_Icon.gotoAndStop( "progress" );
			CommonUtils.colorize( m_Icon, Const.TintNone );
			m_Icon._alpha = 100;

		}
	}
	
	private function onPress( controllerIdx:Number, keyboardOrMouse:Number, button:Number ) {
		
		// left click uses ability
		if ( button == 0 /*&& animaEnergyFull */ ) {
			Shortcut.UseShortcut( Const.e_UltimateShortcutSlot );
		}
		
		// right click rotates through available abilities
		else if ( button == 1 ) {
			selectNextAbility();
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
		tooltipData.AddAttribute('',  'Animus: <font color="#ffff00"><b>' + animaEnergy + '%</b></font>' );
		tooltipData.AddAttribute('',  '' );
		
		tooltip = TooltipManager.GetInstance().ShowTooltip( this, TooltipInterface.e_OrientationVertical, -1, tooltipData );
    }
    
    private function closeTooltip():Void {
		tooltip.Close();
		tooltip = undefined;
    }
	
	private function refreshHotkey() : Void {
		
		t_Hotkey._visible = showHotkeysOnAbilities.GetValue() && App.prefs.getVal( "hud.hotkey.enable" );
		
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
		t_Charge.text = Math.floor( animaEnergy ).toString();

	}
	
	private function shortcutSignalHandler( position:Number ) : Void {
		
		if ( position >= Const.e_UltimateShortcutSlot && position <= Const.e_UltimateShortcutSlot + Const.e_UltimateShortcutSlotCount - 1 ) {
			
			updateSelectedAbility();
			invalidate();
		}
		
	}

	private function refreshUltimateShortcuts() : Void {
		Shortcut.RefreshShortcuts( Const.e_UltimateShortcutSlot, Const.e_UltimateShortcutSlotCount );
	}

	private function buildAbilityList() : Void {

		App.debug( "Button: building ability list" );
		
		abilities = new Array();
		for ( var s:String in FeatInterface.m_FeatList ) {
			
			var feat:FeatData = FeatInterface.m_FeatList[ s ];
			if ( feat.m_SpellType == Const.e_UltimateAbilitySpellType && feat.m_Trained ) {

				App.debug( "Button: found: " + feat.m_Name + ", spell: " + feat.m_Spell + ", index: " + feat.m_AbilityIndex );
				abilities.push( feat.m_Spell );
			}
		}

		updateSelectedAbility();
		
	}
	
	private function updateSelectedAbility() : Void {
		
		var selectedSpellId:Number = Shortcut.m_ShortcutList[Const.e_UltimateShortcutSlot].m_SpellId;
		
		selectedAbility = null;
		if ( selectedSpellId == undefined ) return;
		
		for ( var s:String in abilities ) {
			if ( abilities[s] == selectedSpellId ) {
				selectedAbility = Number(s);
				break;
			}
		}
		
		if ( tooltip ) {
			openTooltip();
		}
	}
	
	private function selectNextAbility() : Void {
		
		if ( abilities.length <= 1 ) return;
		
		var nextAbility:Number = selectedAbility + 1;
		
		if ( nextAbility >= abilities.length ) {
			nextAbility = 0;
		}
		
		App.debug("Button: selecting " + nextAbility );
		
		var spellId:Number = abilities[ nextAbility ];
		if ( spellId != undefined ) {
			Shortcut.AddSpell( Const.e_UltimateShortcutSlot, spellId );
		}
		
	}

	private function featTrainedHandler( position:Number ) : Void {
		
		if ( FeatData(FeatInterface.m_FeatList[ position ]).m_SpellType == Const.e_UltimateAbilitySpellType ) {
			buildAbilityList();
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
			
			case "hud.chargeNumber.enable":
			case "hud.chargingAnimaEnergy.meter.tint":
			case "hud.chargingAnimaEnergy.meter.transparency":
			case "hud.fullAnimaEnergy.wings.tint":
			case "hud.fullAnimaEnergy.wings.transparency":
			case "hud.fullAnimaEnergy.meter.tint":
			case "hud.fullAnimaEnergy.meter.transparency":
			case "hud.fullAnimaEnergy.glow.enable":
			case "hud.fullAnimaEnergy.glow.intensity":
			case "hud.tints.ophanim.empty":
			case "hud.tints.ophanim.empty.wings":
			case "hud.tints.ophanim.default":
			case "hud.tints.ophanim.default.wings":
			case "hud.tints.ophanim.gold":
			case "hud.tints.ophanim.gold.wings":
			case "hud.tints.ophanim.blue":
			case "hud.tints.ophanim.blue.wings":
			case "hud.tints.ophanim.purple":
			case "hud.tints.ophanim.purple.wings":
				invalidate();
			break;
			
			case "hud.hotkey.enable":
				refreshHotkey();
			break;
			
		}
		
	}
	
	/**
	 * internal variables
	 */

	public var m_Icon:MovieClip;
	public var t_Hotkey:TextField;
	public var t_Charge:TextField;
	public var m_Fill:MovieClip;
	public var m_Stroke:MovieClip;
	 
	private var character:Character;
	private var tooltip:TooltipInterface;
	
	private var showHotkeysOnAbilities:DistributedValue;

	private var abilityColourMap:Object;
	private var abilities:Array;
	private var selectedAbility:Number;
	
	private var animaEnergy:Number;
	
	/**
	 * properties
	 */
	 
	public function get isAnimaEnergyFull() : Boolean {
		return animaEnergy >= 100;
	}
	
}