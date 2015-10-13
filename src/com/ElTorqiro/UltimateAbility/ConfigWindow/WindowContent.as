import flash.geom.Point;
import mx.utils.Delegate;
import com.GameInterface.UtilsBase;
import com.GameInterface.DistributedValue;

import com.ElTorqiro.UltimateAbility.AddonUtils.UI.PanelBuilder;
import com.ElTorqiro.UltimateAbility.Const;
import com.ElTorqiro.UltimateAbility.App;

import com.ElTorqiro.UltimateAbility.AddonUtils.MovieClipHelper;

/**
 * 
 * 
 */
class com.ElTorqiro.UltimateAbility.ConfigWindow.WindowContent extends com.Components.WindowComponentContent {

	public function WindowContent() {
		
	}

	private function configUI() : Void {
		
		super.configUI();

		// define the config panel to be built
		var def:Object = {
			
			// panel default load/save handlers
			load: componentLoadHandler,
			save: componentSaveHandler,
			
			layout: [
				
				{	id: "defaultUI.animaEnergyBar.hide",
					type: "checkbox",
					label: "Hide default Animus charge bar",
					tooltip: "Hides the default UI Animus charge bar.",
					data: { pref: "defaultUI.animaEnergyBar.hide" }
				},
				
				{	type: "group"
				},

				{	id: "hud.tooltips.enabled",
					type: "checkbox",
					label: "Show tooltip",
					tooltip: "Enables tooltips when hovering the mouse over the button.",
					data: { pref: "hud.tooltips.enabled" }
				},
				
				{	id: "hud.hotkey.enable",
					type: "checkbox",
					label: "Show hotkey (if Ability Bar hotkeys visible)",
					tooltip: "Shows the Ultimate Ability hotkey label on the button, which will be visible in conjunction with the in-game setting for Ability Bar hotkeys.",
					data: { pref: "hud.hotkey.enable" }
				},

				{	id: "hud.chargeNumber.enable",
					type: "checkbox",
					label: "Show Animus charge percent",
					tooltip: "Shows the Animus charge percent as a number inside the button.",
					data: { pref: "hud.chargeNumber.enable" }
				},
				
				{	type: "section",
					label: "Charging Animus"
				},

				{	id: "hud.chargingAnimaEnergy.meter.transparency",
					type: "slider",
					min: 0,
					max: 100,
					valueFormat: "%i%%",
					label: "Animus charge meter transparency",
					tooltip: "The transparency of the Animus charge meter while it is charging.",
					data: { pref: "hud.chargingAnimaEnergy.meter.transparency" }
				},
				
				{	id: "hud.chargingAnimaEnergy.meter.tint",
					type: "checkbox",
					label: "Tint Animus charge meter per Ultimate Ability",
					tooltip: "Tints the Animus charge meter when Animus charge is not full.",
					data: { pref: "hud.chargingAnimaEnergy.meter.tint" }
				},

				{	type: "section",
					label: "Full Animus"
				},
				
				{	id: "hud.fullAnimaEnergy.meter.transparency",
					type: "slider",
					min: 0,
					max: 100,
					valueFormat: "%i%%",
					label: "Animus charge meter transparency",
					tooltip: "The transparency of the Animus charge meter while it is full.",
					data: { pref: "hud.fullAnimaEnergy.meter.transparency" }
				},
				
				{	id: "hud.fullAnimaEnergy.meter.tint",
					type: "checkbox",
					label: "Tint Animus charge meter per Ultimate Ability",
					tooltip: "Tints the Animus charge meter when Animus charge is full.",
					data: { pref: "hud.fullAnimaEnergy.meter.tint" }
				},

				{	type: "group"
				},
				
				{	id: "hud.fullAnimaEnergy.wings.transparency",
					type: "slider",
					min: 0,
					max: 100,
					valueFormat: "%i%%",
					label: "Wings symbol transparency",
					tooltip: "The transparency of the wings symbol while the Animus charge meter is full.",
					data: { pref: "hud.fullAnimaEnergy.wings.transparency" }
				},
				
				{	id: "hud.fullAnimaEnergy.wings.tint",
					type: "checkbox",
					label: "Tint Wings per Ultimate Ability",
					tooltip: "Tints the wings portion of the icon when Animus charge is full.",
					data: { pref: "hud.fullAnimaEnergy.wings.tint" }
				},
				
				{	type: "group"
				},
				
				{	id: "hud.fullAnimaEnergy.glow.enable",
					type: "checkbox",
					label: "Apply glow effect",
					tooltip: "Enables a glow effect around the button when Animus is at 100%.",
					data: { pref: "hud.fullAnimaEnergy.glow.enable" }
				},
				
				{	type: "indent-in"
				},

				{	id: "hud.fullAnimaEnergy.glow.intensity",
					type: "slider",
					min: Const.MinGlowIntensity,
					max: Const.MaxGlowIntensity,
					valueLabelFormat: "%i%%",
					label: "Glow Intensity",
					tooltip: "The intensity of the 100% Animus glow effect surrounding the button.",
					data: { pref: "hud.fullAnimaEnergy.glow.intensity" }
				},

				{	type: "column"
				},
				
				{	type: "section",
					label: "Tints"
				},
				
				{	id: "hud.tints.ophanim.default",
					type: "colorInput",
					label: "Untinted Fill",
					data: { pref: "hud.tints.ophanim.default" }
				},

				{	id: "hud.tints.ophanim.default.wings",
					type: "colorInput",
					label: "Untinted Wings (full charge)",
					data: { pref: "hud.tints.ophanim.default.wings" }
				},

				{	type: "group"
				},
				
				{	id: "hud.tints.ophanim.gold",
					type: "colorInput",
					label: "Gold Fill",
					data: { pref: "hud.tints.ophanim.gold" }
				},

				{	id: "hud.tints.ophanim.gold.wings",
					type: "colorInput",
					label: "Gold Wings (full charge)",
					data: { pref: "hud.tints.ophanim.gold.wings" }
				},

				{	id: "hud.tints.ophanim.blue",
					type: "colorInput",
					label: "Blue Fill",
					data: { pref: "hud.tints.ophanim.blue" }
				},

				{	id: "hud.tints.ophanim.blue.wings",
					type: "colorInput",
					label: "Blue Wings (full charge)",
					data: { pref: "hud.tints.ophanim.blue.wings" }
				},

				{	id: "hud.tints.ophanim.purple",
					type: "colorInput",
					label: "Purple Fill",
					data: { pref: "hud.tints.ophanim.purple" }
				},

				{	id: "hud.tints.ophanim.purple.wings",
					type: "colorInput",
					label: "Purple Wings (full charge)",
					data: { pref: "hud.tints.ophanim.purple.wings" }
				},

				{	type: "group"
				},

				{	id: "hud.tints.ophanim.empty",
					type: "colorInput",
					label: "'No Ability' Fill",
					data: { pref: "hud.tints.ophanim.empty" }
				},

				{	id: "hud.tints.ophanim.empty.wings",
					type: "colorInput",
					label: "'No Ability' Wings (full charge)",
					data: { pref: "hud.tints.ophanim.empty.wings" }
				},

				{	type: "group"
				},
				
				{	type: "button",
					text: "Reset Tints",
					onClick: Delegate.create( this, resetTintDefaults )
				},
				
				{	type: "section",
					label: "Size & Position"
				},
				
				{	type: "text",
					text: "Use GUI edit mode to manipulate the button.  Left-button drags it, and mouse wheel adjusts scale."
				},
				
				{	type: "group"
				},
				
				{	id: "hud.scale",
					type: "slider",
					min: Const.MinHudScale,
					max: Const.MaxHudScale,
					step: 5,
					valueFormat: "%i%%",
					label: "Button Scale",
					tooltip: "The scale of the button.  You can also change this in GUI Edit Mode by scrolling the mouse wheel while hovering over the button.",
					data: { pref: "hud.scale" }
				},

				{	type: "button",
					text: "Reset Position",
					tooltip: "Reset position of the button to default.",
					onClick: function() {
						App.prefs.setVal( "hud.position", undefined );
					}
				}
				
			]
		};
		
		// only add icon related settings if not using VTIO
		if ( !App.isRegisteredWithVtio ) {
			
			def.layout = def.layout.concat( [
				
				{	type: "group"
				},

				{	id: "icon.scale",
					type: "slider",
					min: Const.MinIconScale,
					max: Const.MaxIconScale,
					step: 5,
					valueFormat: "%i%%",
					label: "Icon Scale",
					tooltip: "The scale of the addon icon.  You can also change this in GUI Edit Mode by scrolling the mouse wheel while hovering over the icon.",
					data: { pref: "icon.scale" }
				},

				{	type: "button",
					text: "Reset icon position",
					tooltip: "Reset icon to its default position.",
					onClick: function() {
						App.prefs.setVal( "icon.position", undefined );
					}
				}
			] );
			
		}
		
		def.layout = def.layout.concat( [
			{	type: "section",
				label: "Global Reset"
			},

			{	type: "button",
				text: "Reset All",
				onClick: Delegate.create( this, resetAllDefaults )
			}
		] );
		
		// build the panel based on definition
		var panel:PanelBuilder = PanelBuilder( MovieClipHelper.createMovieWithClass( PanelBuilder, "m_Panel", this, this.getNextHighestDepth() ) );
		panel.build( def );
		
		// set up listener for pref changes
		App.prefs.SignalValueChanged.Connect( prefListener, this );
		
		def = {
			layout: [
				{	type: "button",
					text: "Visit forum thread",
					tooltip: "Click to open the in-game browser and visit the forum thread for the addon.",
					onClick: function() {
						DistributedValue.SetDValue("web_browser", false);
						DistributedValue.SetDValue("WebBrowserStartURL", "https://forums.thesecretworld.com/showthread.php?86011-MOD-ElTorqiro_UltimateAbility");
						DistributedValue.SetDValue("web_browser", true);
					}
				}
			]
		};
		
		var panel:PanelBuilder = PanelBuilder( MovieClipHelper.createMovieWithClass( PanelBuilder, "m_TitleBarPanel", this, this.getNextHighestDepth() ) );
		panel.build( def );
		
		panel._x = Math.round( _parent.m_Title.textWidth + 10 );
		panel._y -= Math.round( _y - _parent.m_Title._y + 1);
		
		SignalSizeChanged.Emit();
	}

	private function componentLoadHandler() : Void {
		this.setValue( App.prefs.getVal( this.data.pref ) );
	}

	private function componentSaveHandler() : Void {
		App.prefs.setVal( this.data.pref, this.getValue() );
	}

	/**
	 * listener for pref value changes, to update the config ui
	 * 
	 * @param	name
	 * @param	newValue
	 * @param	oldValue
	 */
	private function prefListener( name:String, newValue, oldValue ) : Void {
		
		// only update controls that are using the pref shortcuts
		if ( m_Panel.components[ name ].api.data.pref ) {
			m_Panel.components[ name ].api.load();
		}
		
	}

	/**
	 * resets most settings to defaults, with a few exceptions
	 */
	private function resetAllDefaults() : Void {

		var prefs:Array = [
		
			"icon.position",
			"icon.scale",
			
			"defaultUI.animaEnergyBar.hide",
			
			"hud.tooltips.enabled",

			"hud.scale",
			"hud.position",

			"hud.hotkey.enable",
			"hud.chargeNumber.enable",

			"hud.chargingAnimaEnergy.meter.tint",
			"hud.chargingAnimaEnergy.meter.transparency",

			"hud.fullAnimaEnergy.glow.enable",
			"hud.fullAnimaEnergy.glow.intensity",
		
			"hud.fullAnimaEnergy.wings.tint",
			"hud.fullAnimaEnergy.wings.transparency",

			"hud.fullAnimaEnergy.meter.tint",
			"hud.fullAnimaEnergy.meter.transparency"
			
		];
		
		for ( var s:String in prefs ) {
			App.prefs.reset( prefs[s] );
		}
		
		resetTintDefaults();
	}
	
	/**
	 * resets all tings to default values
	 */
	private function resetTintDefaults() : Void {
		
		for ( var s:String in App.prefs.list ) {
			
			if ( s.substr( 0, 10 ) == "hud.tints." ) {
				App.prefs.reset( s );
			}
			
		}
		
	}
	
	/**
	 * set the size of the content
	 * 
	 * @param	width
	 * @param	height
	 */
    public function SetSize(width:Number, height:Number) : Void {
		SignalSizeChanged.Emit();
    }

	/**
	 * return the dimensions of the content
	 * 
	 * @return dimensions of content size
	 */
    public function GetSize() : Point {
		return new Point( m_Panel.width, m_Panel.height );
    }
	
	/*
	 * internal variables
	 */
	
	public var m_Panel:MovieClip;
	public var m_TitleBarPanel:MovieClip;
	
	/*
	 * properties
	 */
	
}