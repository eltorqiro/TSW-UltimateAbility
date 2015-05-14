/**
 * settings packs, including the default settings
 * 
 * this has been moved out of the HUD class to avoid the 32k class/function branch limit
 */

class com.ElTorqiro.UltimateAbility.HUD.SettingsPacks {

	/**
	 * default settings package
	 * ( must use function to ensure a fresh copy of the object is returned, rather than a reference to an existing object )
	 * 
	 * readonly
	 */
	public static function get defaultSettings():Object {
		
		return new Object( {
		
			settingsVersion: 1000,
			
			hudEnabled: true,
			
			hideDefaultUI: true,

			fadeInTime: 1000,
			fadeOutTime: 1000,
			
			glowWhenFull: true,
			useCustomIcons: false,

			hudScale: 100,
			hudAlpha: 100,
			
			minHUDScale: 10,
			maxHUDScale: 200,
			
			position: undefined,
			
			tintFullGlow: 0xfff733
		});
	}
	
}
