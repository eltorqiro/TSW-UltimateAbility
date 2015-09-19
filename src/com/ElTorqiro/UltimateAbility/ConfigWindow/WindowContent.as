import flash.geom.Point;
import mx.utils.Delegate;
import com.GameInterface.UtilsBase;
import com.GameInterface.DistributedValue;

import com.ElTorqiro.UltimateAbility.AddonUtils.UI.PanelBuilder;
import com.ElTorqiro.UltimateAbility.Const;
import com.ElTorqiro.UltimateAbility.App;

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
			
			columnWidth: 280,
			columnPadding: 40,
			
			blockSpacing: 10,
			indentSpacing: 15,
			groupSpacing: 20,
			
			layout: [
				
				{	type: "heading",
					text: "General"
				},
				
				{	id: "defaultUI.animaEnergyBar.hide",
					type: "checkbox",
					label: "Hide default Animus progress bar",
					tooltip: "Hides the default UI Animus progress bar.",
					data: { pref: "defaultUI.animaEnergyBar.hide" },
					loader: componentLoadHandler,
					saver: componentSaveHandler
				},
				
				{	type: "heading",
					text: "Button FX"
				},

				{	id: "hud.fullAnimaEnergy.glow.enable",
					type: "checkbox",
					label: "Glow when Animus is full",
					tooltip: "Enables a glow effect around the button when Animus is at 100%.",
					data: { pref: "hud.fullAnimaEnergy.glow.enable" },
					loader: componentLoadHandler,
					saver: componentSaveHandler
				},
				
				{	type: "indent"
				},

				{	id: "hud.fullAnimaEnergy.glow.intensity",
					type: "slider",
					min: Const.MinGlowIntensity,
					max: Const.MaxGlowIntensity,
					valueLabelFormat: "%i%%",
					label: "Intensity",
					tooltip: "The intensity of the 100% Animus glow effect surrounding the button.",
					data: { pref: "hud.fullAnimaEnergy.glow.intensity" },
					loader: componentLoadHandler,
					saver: componentSaveHandler
				},

				{	type: "indent", size: "reset"
				},
				
				{	type: "heading",
					text: "Tints"
				},
				
				{	id: "hud.tints.ophanim.gold",
					type: "colourRGB",
					label: "Gold Wings",
					data: { pref: "hud.tints.ophanim.gold" },
					loader: componentLoadHandler,
					saver: componentSaveHandler
				},
				
				{	id: "hud.tints.ophanim.blue",
					type: "colourRGB",
					label: "Blue Wings",
					data: { pref: "hud.tints.ophanim.blue" },
					loader: componentLoadHandler,
					saver: componentSaveHandler
				},

				{	id: "hud.tints.ophanim.purple",
					type: "colourRGB",
					label: "Purple Wings",
					data: { pref: "hud.tints.ophanim.purple" },
					loader: componentLoadHandler,
					saver: componentSaveHandler
				},

				{	type: "block"
				},
				
				{	type: "button",
					text: "Reset tints to defaults",
					onClick: Delegate.create( this, resetTintDefaults )
				},
				
				{	type: "heading",
					text: "Size & Position"
				},
				
				{	id: "hud.scale",
					type: "slider",
					min: Const.MinHudScale,
					max: Const.MaxHudScale,
					step: 5,
					valueLabelFormat: "%i%%",
					label: "Button Scale",
					tooltip: "The scale of the button.  You can also change this in GUI Edit Mode by scrolling the mouse wheel while hovering over the button.",
					data: { pref: "hud.scale" },
					loader: componentLoadHandler,
					saver: componentSaveHandler
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
				
				{	type: "block"
				},

				{	id: "icon.scale",
					type: "slider",
					min: Const.MinWidgetScale,
					max: Const.MaxWidgetScale,
					step: 5,
					valueLabelFormat: "%i%%",
					label: "Icon Scale",
					tooltip: "The scale of the addon icon.  You can also change this in GUI Edit Mode by scrolling the mouse wheel while hovering over the icon.",
					data: { pref: "icon.scale" },
					loader: componentLoadHandler,
					saver: componentSaveHandler
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
			{	type: "heading",
				text: "Global Reset"
			},

			{	type: "button",
				text: "Reset all to defaults",
				onClick: Delegate.create( this, resetAllDefaults )
			}
		] );
		
		// build the panel based on definition
		PanelBuilder.build( def, createEmptyMovieClip( "m_Panel", getNextHighestDepth() ) );
		
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
		
		PanelBuilder.build( def, createEmptyMovieClip( "m_TitleBarPanel", getNextHighestDepth() ) );
		//m_TitleBarPanel._x = 170;
		m_TitleBarPanel._x = _parent.m_Title.textWidth + 20;
		m_TitleBarPanel._y -= m_TitleBarPanel._height + 11;
		
		//SetSize( Math.round(Math.max(m_Content._width, 200)), Math.round(Math.max(m_Content._height, 200)) );
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
		
		var componentName:String = "component_" + name;
		
		// only update controls that are using the pref shortcuts
		if ( m_Panel[ componentName ].data.pref ) {
			m_Panel[ componentName ].loader();
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

			"hud.scale",
			"hud.position",
			
			"hud.fullAnimaEnergy.glow.enable",
			"hud.fullAnimaEnergy.glow.intensity"
			
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
        //return new Point( m_Panel._width + 10, m_Panel._height );
		
		return new Point( m_Panel.panelWidth, m_Panel.panelHeight );
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