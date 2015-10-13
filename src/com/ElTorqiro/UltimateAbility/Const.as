
/**
 * shared constants used throughout the app
 * 
 */
class com.ElTorqiro.UltimateAbility.Const {
	
	// static class only, cannot be instantiated
	private function Const() { }

	// app information
	public static var AppID:String = "ElTorqiro_UltimateAbility";
	public static var AppName:String = "UltimateAbility";
	public static var AppAuthor:String = "ElTorqiro";
	public static var AppVersion:String = "1.2.0+develop";

	public static var DebugModeDV:String = "ElTorqiro_UltimateAbility_Debug";
	
	public static var PrefsName:String = "ElTorqiro_UltimateAbility_Preferences";
	public static var PrefsVersion:Number = 10030;
	
	public static var HudClipDepthLayer:Number = _global.Enums.ViewLayer.e_ViewLayerMiddle;
	public static var HudClipSubDepth:Number = 2;
	public static var HudClipSubDepthGuiEditMode:Number = 50;
	
	public static var IconClipPath:String = "ElTorqiro_UltimateAbility\\Icon.swf";
	public static var IconClipDepthLayer:Number = _global.Enums.ViewLayer.e_ViewLayerMiddle;
	public static var IconClipSubDepth:Number = 0;
	
	public static var ConfigWindowClipPath:String = "ElTorqiro_UltimateAbility\\ConfigWindow.swf";
	public static var ConfigWindowClipDepthLayer:Number = _global.Enums.ViewLayer.e_ViewLayerTop;
	public static var ConfigWindowClipSubDepth:Number = 0;

	public static var ShowConfigWindowDV:String = "ElTorqiro_UltimateAbility_ShowConfigWindow";
	
	public static var MinHudScale:Number = 50;
	public static var MaxHudScale:Number = 200;
	
	public static var MinIconScale:Number = 30;
	public static var MaxIconScale:Number = 200;
	
	public static var MinGlowIntensity:Number = 0;
	public static var MaxGlowIntensity:Number = 300;
	
	// empty tint colour
	public static var TintNone:Number = 0xffffff;
	
	// wings spell ids
	public static var e_OphanimBlue:Number = 8974266;
	public static var e_OphanimGold:Number = 8972602;
	public static var e_OphanimPurple:Number = 8973441;
	
	// unlock achievement id
	public static var e_UltimateAbilityUnlockAchievement:Number = 7783;		// the Lore number that unlocks the Ultimate Ability

	// anima energy stat
	public static var e_AnimaEnergyStat:Number = _global.Enums.Stat.e_AnimaEnergy;
	
	// ultimate ability shortcut slot
	public static var e_UltimateShortcutSlot:Number = _global.Enums.UltimateAbilityShortcutSlots.e_UltimateShortcutBarFirstSlot;
	public static var e_UltimateShortcutSlotCount:Number = _global.Enums.UltimateAbilityShortcutSlots.e_UltimateShortcutBarSlotCount;

	// ultimate ability spell type
	public static var e_UltimateAbilitySpellType:Number = _global.Enums.SpellItemType.eUltimateAbility;
	
	// game setting values for when to show the button
	public static var e_UltimateVisibilitySettingNever:Number = 0;
	public static var e_UltimateVisibilitySettingCharged:Number = 1;
	public static var e_UltimateVisibilitySettingAlways:Number = 2;

	// anima energy meter tint options
	public static var e_AnimaEnergyMeterTintTypeNever:Number = 0;
	public static var e_AnimaEnergyMeterTintTypeWhenFull:Number = 1;
	public static var e_AnimaEnergyMeterTintTypeAlways:Number = 2;
	
}