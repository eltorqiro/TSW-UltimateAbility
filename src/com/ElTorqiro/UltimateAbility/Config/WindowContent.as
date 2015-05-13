import com.Components.FCSlider;
import com.Components.WindowComponentContent;
import flash.geom.Point;
import gfx.controls.CheckBox;
import gfx.controls.DropdownMenu;
import gfx.controls.Button;
import gfx.controls.Slider;
import gfx.controls.TextInput;
import mx.utils.Delegate;
import com.GameInterface.UtilsBase;
import com.GameInterface.DistributedValue;

import com.GameInterface.Tooltip.TooltipManager;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipInterface;

import com.ElTorqiro.UltimateAbility.AddonUtils.AddonUtils;
import com.ElTorqiro.UltimateAbility.AddonInfo;


class com.ElTorqiro.UltimateAbility.Config.WindowContent extends com.Components.WindowComponentContent
{
	private var _uiControls:Object = {};
	private var _uiInitialised:Boolean = false;
	
	private var m_ContentSize:MovieClip;
	private var m_Content:MovieClip;
	
	private var _layoutCursor:Point;
	
	private var _hud:MovieClip;
	
	private var _tooltip:TooltipInterface;
	
	public function WindowContent() {
		
		// get a handle on the hud instance
		_hud = _root["eltorqiro_ultimateability\\hud"].g_HUD;
	}

	private function configUI() : Void {
		super.configUI();

		_layoutCursor = new Point(0, 0);
		
		m_Content = createEmptyMovieClip("m_Content", getNextHighestDepth() );

		_uiControls.VisitForums = {
			ui:	AddButton("VisitForums", "Visit the InCombat forum thread"),
			tooltip: "Clicking this button will open the in-game browser and visit the InCombat forum thread.",
			event:		"click",
			context:	this,
			fn: 		function(e:Object) {
				DistributedValue.SetDValue("web_browser", false);
				DistributedValue.SetDValue("WebBrowserStartURL", "https://forums.thesecretworld.com/showthread.php?86001-MOD-ElTorqiro_InCombat");
				DistributedValue.SetDValue("web_browser", true);
			}
		};
		

		// options section
		AddHeading("Options");
		_uiControls.hudEnabled = {
			ui:	AddCheckbox( "hudEnabled", "HUD enabled" ),
			tooltip: "Enables the InCombat HUD.  If enabled, the HUD will be visible on the screen when you are in combat.",
			event:		"click",
			context:	this,
			fn: 		function(e:Object) {
				_hud.hudEnabled = e.target.selected;
			},
			init:		function(e:Object) {
				e.control.ui.selected = _hud.hudEnabled;
			}
		};
		_uiControls.hideDefaultUI = {
			ui:	AddCheckbox( "hideDefaultUI", "Hide default in-combat UI" ),
			tooltip: "Hides the default in-combat indicator (i.e. the blurry yellow glow at the bottom of the screen).",
			event:		"click",
			context:	this,
			fn: 		function(e:Object) {
				_hud.hideDefaultUI = e.target.selected;
			},
			init:		function(e:Object) {
				e.control.ui.selected = _hud.hideDefaultUI;
			}
		};

		AddHeading("Bar");
		_uiControls.showBar = {
			ui:	AddCheckbox( "showBar", "Show bar" ),
			tooltip: "Toggles the visibility of the HUD background bar.",
			event:		"click",
			context:	this,
			fn: 		function(e:Object) {
				_hud.showBar = e.target.selected;
			},
			init:		function(e:Object) {
				e.control.ui.selected = _hud.showBar;
			}
		};
		_uiControls.glowBar = {
			ui:	AddCheckbox( "glowBar", "Glow bar" ),
			tooltip: "Toggles the visibility of the glow on the background bar.",
			event:		"click",
			context:	this,
			fn: 		function(e:Object) {
				_hud.glowBar = e.target.selected;
			},
			init:		function(e:Object) {
				e.control.ui.selected = _hud.glowBar;
			}
		};
		_uiControls.barStyle = {
			ui:	AddDropdown( "barStyle", "Bar Style", [ "Lights", "Stripe", "Dawn", "Hazard" ] ),
			/* tooltip: "The style of bar used in the background of the HUD.", */
			event:		"change",
			context:	this,
			fn: 		function(e:Object) {
				_hud.barStyle = e.target.selectedIndex;
			},
			init:		function(e:Object) {
				e.control.ui.selectedIndex = _hud.barStyle;
			}
		};
		AddVerticalSpace(10);
		_uiControls.barAlpha = {
			ui:	AddSlider( "barAlpha", "Bar Transparency", 0, 100, 1, "%" ),
			tooltip: "Adjusts transparency of the bar.",
			event:		"change",
			context:	this,
			fn: 		function(e:Object) {
				_hud.barAlpha = e.target.value;
			},
			init:		function(e:Object) {
				e.control.ui.setValue( _hud.barAlpha );
			}
		};
		_uiControls.barScaleX = {
			ui:	AddSlider( "barScaleX", "Horizontal Scale", _hud.minHUDScale, _hud.maxHUDScale, 1, "%" ),
			tooltip: "Adjusts the horizontal scale of the bar.",
			event:		"change",
			context:	this,
			fn: 		function(e:Object) {
				_hud.barScaleX = e.target.value;
			},
			init:		function(e:Object) {
				e.control.ui.setValue( _hud.barScaleX );
			}
		};
		_uiControls.barScaleY = {
			ui:	AddSlider( "barScaleY", "Vertical Scale", _hud.minHUDScale, _hud.maxHUDScale, 1, "%" ),
			tooltip: "Adjusts the vertical scale of the bar.",
			event:		"change",
			context:	this,
			fn: 		function(e:Object) {
				_hud.barScaleY = e.target.value;
			},
			init:		function(e:Object) {
				e.control.ui.setValue( _hud.barScaleY );
			}
		};
		
		
		// icons section
		AddHeading("Icons");
		_uiControls.showIcons = {
			ui:	AddCheckbox( "showIcons", "Show icon" ),
			tooltip: "Toggles the visibility of the HUD icon images.",
			event:		"click",
			context:	this,
			fn: 		function(e:Object) {
				_hud.showIcons = e.target.selected;
			},
			init:		function(e:Object) {
				e.control.ui.selected = _hud.showIcons;
			}
		};
		
		AddVerticalSpace(10);
		_uiControls.iconAlpha = {
			ui:	AddSlider( "iconAlpha", "Icon Transparency", 0, 100, 1, "%" ),
			tooltip: "Adjusts transparency of the icons.",
			event:		"change",
			context:	this,
			fn: 		function(e:Object) {
				_hud.iconAlpha = e.target.value;
			},
			init:		function(e:Object) {
				e.control.ui.setValue( _hud.iconAlpha );
			}
		};
		_uiControls.iconScale = {
			ui:	AddSlider( "iconScale", "Icon Scale", _hud.minHUDScale, _hud.maxHUDScale, 1, "%" ),
			tooltip: "Adjusts the size of the icons.",
			event:		"change",
			context:	this,
			fn: 		function(e:Object) {
				_hud.iconScale = e.target.value;
			},
			init:		function(e:Object) {
				e.control.ui.setValue( _hud.iconScale );
			}
		};


		AddHeading("Overall HUD");
		_uiControls.MoveToDefaultPosition = {
			ui:	AddButton("MoveToDefaultPosition", "Reset to default position"),
			tooltip: "Resets the HUD to its default position.",
			event:		"click",
			context:	this,
			fn: 		function(e:Object) {
				_hud.MoveToDefaultPosition();
			}
		};
		AddVerticalSpace(10);
		_uiControls.hudScale = {
			ui:	AddSlider( "hudScale", "HUD Scale", _hud.minHUDScale, _hud.maxHUDScale, 1, "%" ),
			tooltip: "Adjusts the size of the HUD.",
			event:		"change",
			context:	this,
			fn: 		function(e:Object) {
				_hud.hudScale = e.target.value;
			},
			init:		function(e:Object) {
				e.control.ui.setValue( _hud.hudScale );
			}
		};
		_uiControls.hudAlpha = {
			ui:	AddSlider( "hudAlpha", "HUD Transparency", 10, 100, 1, "%" ),
			tooltip: "Adjusts transparency of the HUD.",
			event:		"change",
			context:	this,
			fn: 		function(e:Object) {
				_hud.hudAlpha = e.target.value;
			},
			init:		function(e:Object) {
				e.control.ui.setValue( _hud.hudAlpha );
			}
		};
		
		
		AddColumn();

		// fx section
		AddHeading( "Animations" );
/*
		_uiControls.animationTime = {
			ui:	AddSlider( "animationTime", "Animation time", 0, 2000, 10, "ms" ),
			tooltip: "The time taken to animate the HUD into position when activating/deactivating.",
			event:		"change",
			context:	this,
			fn: 		function(e:Object) {
				_hud.animationTime = e.target.value;
			},
			init:		function(e:Object) {
				e.control.ui.setValue( _hud.animationTime );
			}
		};
*/
		_uiControls.fadeInTime = {
			ui:	AddSlider( "fadeInTime", "Fade in time", 0, 2000, 10, "ms" ),
			tooltip: "The fade in time for HUD transitions.",
			event:		"change",
			context:	this,
			fn: 		function(e:Object) {
				_hud.fadeInTime = e.target.value;
			},
			init:		function(e:Object) {
				e.control.ui.setValue( _hud.fadeInTime );
			}
		};
		_uiControls.fadeOutTime = {
			ui:	AddSlider( "fadeOutTime", "Fade out time", 0, 2000, 10, "ms" ),
			tooltip: "The fade out time for HUD transitions.",
			event:		"change",
			context:	this,
			fn: 		function(e:Object) {
				_hud.fadeOutTime = e.target.value;
			},
			init:		function(e:Object) {
				e.control.ui.setValue( _hud.fadeOutTime );
			}
		};
		

		// tints section
		AddHeading( "Tints" );
		_uiControls.ApplyDefaultTints = {
			ui:	AddButton("ApplyDefaultTints", "Reset to default tints"),
			tooltip: "Clicking this button will reset all tint colours to their default values.",
			event:		"click",
			context:	this,
			fn: 		function(e:Object) {
				_hud.ApplyDefaultTints();
				LoadValues();
			}
		};
		_uiControls.tintThreatened = {
			ui:	AddTextInput( "tintThreatened", "Threatened", "", 6, true, undefined, true ),
			event:		"textChange",
			context:	this,
			fn: 		function(e:Object) {
				var eventValue:Number = parseInt( '0x' + e.target.text );
				if ( AddonUtils.isRGB(eventValue) ) _hud.tintThreatened = eventValue;
			},
			init:		function(e:Object) {
				var displayString:String = decColor2hex(_hud.tintThreatened);
				if ( e.control.ui.text != displayString ) e.control.ui.text = displayString;
			}
		};
		_uiControls.tintCombat = {
			ui:	AddTextInput( "tintCombat", "Combat", "", 6, true, undefined, true ),
			event:		"textChange",
			context:	this,
			fn: 		function(e:Object) {
				var eventValue:Number = parseInt( '0x' + e.target.text );
				if ( AddonUtils.isRGB(eventValue) ) _hud.tintCombat = eventValue;
			},
			init:		function(e:Object) {
				var displayString:String = decColor2hex(_hud.tintCombat);
				if ( e.control.ui.text != displayString ) e.control.ui.text = displayString;
			}
		};
		
		AddHeading("Custom Icons");
		_uiControls.useCustomIcons = {
			ui:	AddCheckbox( "useCustomIcons", "Use custom icons (read below)" ),
			tooltip: "Enables the use of your own custom icons.  If an icon cannot be loaded, an <i>error</i> icon will be shown instead.",
			event:		"click",
			context:	this,
			fn: 		function(e:Object) {
				_hud.useCustomIcons = e.target.selected;
			},
			init:		function(e:Object) {
				e.control.ui.selected = _hud.useCustomIcons;
			}
		};
		AddIndent(20);
		_uiControls.ReloadCustomIcons = {
			ui:	AddButton("ReloadCustomIcons", "Reload custom icons"),
			tooltip: "Reloads the custom icons from disk, allowing you to make quick changes to them without having to restart the game.",
			event:		"click",
			context:	this,
			fn: 		function(e:Object) {
				_hud.LoadIcons();
			}
		};
		AddIndent(-20);

		AddVerticalSpace(10);
		AddTextArea( "customIconDescription", 
			"You can use your own custom icons for the <b>Threatened</b> and <b>Combat</b> states.  They must be in PNG format and must be placed in the <b>" + AddonInfo.ID + "</b> directory.<br><br>The filenames are case sensitive:<br><br><b>threatened.png</b> - mobs are hunting you<br><b>combat.png</b> - you are engaged in combat"
		);
		
		AddVerticalSpace(10);
		
		// global reset section
		AddHeading("Global Reset");
		_uiControls.ApplyDefaultSettings = {
			ui:	AddButton("ApplyDefaultSettings", "Reset all settings to default"),
			tooltip: "Clicking this button will reset every setting to default.",
			event:		"click",
			context:	this,
			fn: 		function(e:Object) {
				_hud.ApplyDefaultSettings();
				LoadValues();
			}
		};
		
		
		SetSize( Math.round(Math.max(m_Content._width, 200)), Math.round(Math.max(m_Content._height, 200)) );
		
		// wire up event handlers for ui controls
		for (var s:String in _uiControls) {
			_uiControls[s].ui.addEventListener( _uiControls[s].event, this, "ControlHandler" );
			
			_uiControls[s].ui.addEventListener( "rollOver", this, "OpenTooltip" );
			_uiControls[s].ui.addEventListener( "rollOut", this, "CloseTooltip" );
			
		}

		// load initial values
		LoadValues();
	}

	private function OpenTooltip(e:Object) : Void {
		
		CloseTooltip();

		var control = _uiControls[e.target.controlName];
		
		if ( control.tooltip == undefined ) return;
		
		var tooltipData:TooltipData = new TooltipData();
		tooltipData.AddAttribute("","<font face=\'_StandardFont\' size=\'12\' color=\'#3ad9ff\'>" + e.target.tooltipTitle + "</font>");
		tooltipData.AddAttribute( "", "<font face=\'_StandardFont\' size=\'11\' color=\'#f0f0f0\'>" + control.tooltip + "</font>" );
		tooltipData.m_Padding = 8;
		tooltipData.m_MaxWidth = 350;
		
		_tooltip = TooltipManager.GetInstance().ShowTooltip( undefined /*e.target*/, TooltipInterface.e_OrientationVertical, -1, tooltipData );
	}

	private function CloseTooltip(e:Object) : Void {
		_tooltip.Close();
		_tooltip = undefined;
	}
	
	// universal control interaction handler
	private function ControlHandler( e:Object ) {
		if ( !_uiInitialised ) return;

		// handle textinput hex color fields
		if ( e.target instanceof TextInput && e.target["isHexColor"] ) {
			eventValue = parseInt( '0x' + eventValue );
			if ( !AddonUtils.isRGB(eventValue) ) return;
		}
		
		var control:Object = _uiControls[e.target.controlName];
		
		// execute the control event handler
		Delegate.create(control.context, control.fn)(e);
	}
	

	// populate the states of the config ui controls based on the hud module's published data
	private function LoadValues() : Void {
		_uiInitialised = false;
		
		var data:Object = _hud.g_data;
		
		for ( var s:String in _uiControls ) {
			var control = _uiControls[s];
			Delegate.create(control.context, control.init)( { control: control } );
		}
		
		_uiInitialised = true;
	}

	private function decColor2hex(color:Number) {
		// input:   (Number) decimal color (i.e. 16711680)
		// returns: (String) hex color (i.e. 0xFF0000)
		colArr = color.toString(16).toUpperCase().split('');
		numChars = colArr.length;
		for(a=0;a<(6-numChars);a++){colArr.unshift("0");}
		return('' + colArr.join(''));
	}
	

	// add and return a new checkbox, layed out vertically
	private function AddCheckbox(name:String, text:String):CheckBox
	{	
		var y:Number = m_Content._height;
		
		var o:CheckBox = CheckBox(m_Content.attachMovie( "Checkbox", "m_" + name, m_Content.getNextHighestDepth() ));
		o["tooltipTitle"] = text;
		o["controlName"] = name;
		o["eventValue"] = "e.target.selected";
		with ( o )
		{
			disableFocus = true;
			textField.autoSize = true;
			textField.text = text;
			//_y = y;
		}

		o._y = _layoutCursor.y;
		o._x = _layoutCursor.x;
		
		_layoutCursor.y += o._height;
		
		return o;
	}

	// add and return a new button, layed out vertically
	private function AddButton(name:String, text:String):Button
	{
		var y:Number = m_Content._height;
		
		var o:Button = Button(m_Content.attachMovie( "Button", "m_" + name, m_Content.getNextHighestDepth() ));
		o["tooltipTitle"] = text;
		o["controlName"] = name;
		o["eventValue"] = "e.target.selected";
		o.label = text;
		o.autoSize = "left";
		o.disableFocus = true;

		var marginTop:Number = ( _layoutCursor.y > 0 ? 3 : 0 );

		o._y = _layoutCursor.y + marginTop;
		o._x = _layoutCursor.x; // + 6;

		_layoutCursor.y += marginTop + o._height + 3;
		
		return o;
	}
	
	
	// add and return a dropdown
	private function AddDropdown(name:String, label:String, values:Array) : DropdownMenu {
		
		var leftOffset:Number = 3;
		
		var l = m_Content.attachMovie( "ConfigLabel", "m_" + name + "_Label", m_Content.getNextHighestDepth() );
		l.textField.autoSize = "left";
		l.textField.text = label;
		l._x = leftOffset;
		l._y = _layoutCursor.y;
		
		var o:DropdownMenu = DropdownMenu(m_Content.attachMovie( "Dropdown", "m_" + name, m_Content.getNextHighestDepth() ));

		o["tooltipTitle"] = label;
		o["controlName"] = name;
		o["eventValue"] = "e.index";
		//o["labelField"].autoSize = "left";
		//o["labelField"].text = label;

		o.disableFocus = true;
		o.dropdown = "ScrollingList";
		o.itemRenderer = "ListItemRenderer";
		o.dataProvider = values;
		o.dropdown.addEventListener("focusIn", this, "RemoveFocus");

		o._y = _layoutCursor.y;
		o._x = l._x + 10 + 3 + l._width;

		_layoutCursor.y += o._height;
		
		return o;
	}
	
	// add a group heading, layed out vertically
	private function AddHeading(text:String):Void
	{
		var y:Number = m_Content._height;
		if ( y != 0) y += 10;
		
		var o:MovieClip = m_Content.attachMovie( "ConfigGroupHeading", "m_Heading", m_Content.getNextHighestDepth() );

		o["tooltipTitle"] = text;
		o.textField.autoSize = "left";
		o.textField.text = text;

		if ( _layoutCursor.y > 0 )  _layoutCursor.y += 15;

		o._y = _layoutCursor.y;
		o._x = _layoutCursor.x;
		
		_layoutCursor.y += o._height;
	}
	
	private function clearFocus(e:Object) : Void {
		e.target.focused = false;
	}
	
	
	private function AddSlider(name:String, label:String, minValue:Number, maxValue:Number, snap:Number, suffix:String):Slider {

		var leftOffset:Number = 3;
		
		// add label for the name of the control
		var l = m_Content.attachMovie( "ConfigLabel", "m_" + name + "_Label", m_Content.getNextHighestDepth() );
		l.textField.autoSize = "left";
		l.textField.text = label;
		l._y = _layoutCursor.y;
		l._x = _layoutCursor.x + leftOffset;

		_layoutCursor.y += l.textField._height;// textHeight;
		
		var o:Slider = Slider(m_Content.attachMovie( "Slider", "m_" + name, m_Content.getNextHighestDepth() ));
		o["tooltipTitle"] = text;
		o["controlName"] = name;
		o["eventValue"] = "e.value";
		o["suffix"] = suffix != undefined ? suffix : "";
		o.width = 200;

		o.addEventListener( "focusIn", this, "clearFocus" );
		
		// since we're building a composite control, this is essentially a glorified setter
		// to make sure the label text can be updated
		// -- use this instead of "value = x;" in property setting
		o["setValue"] = Delegate.create( o, function(value:Number) {
			this.value = value;
			this["updateValueLabel"]();
		});
		
		o["updateValueLabel"] = Delegate.create( o, function() {
			this["valueLabel"].textField.text = this.value + this["suffix"];
		});

		o.addEventListener( "change", o, "updateValueLabel" );
		
		o.minimum = minValue;
		o.maximum = maxValue;
		o.snapInterval = snap == undefined ? 1 : snap;
		o.snapping = true;
		o.liveDragging = true;
		o.value = minValue;

		o._y = _layoutCursor.y;
		o._x = _layoutCursor.x + leftOffset;

		// add label for the value
		var l = m_Content.attachMovie( "ConfigLabel", "m_" + name + "_Value", m_Content.getNextHighestDepth() );
		l.textField.autoSize = "left";
		l.textField.text = o.value + o["suffix"];
		l._y = o._y - 5;
		l._x = o._x + o._width + 6;
		
		o["valueLabel"] = l;

		_layoutCursor.y += o._height;
		
		return o;
	}
	
	private function AddTextInput(name:String, label:String, defaultValue:String, maxChars:Number, isHexColor:Boolean, width:Number, alignRight:Boolean):TextInput {
		
			var l = m_Content.attachMovie( "ConfigLabel", "m_" + name + "_Label", m_Content.getNextHighestDepth() );
			o["tooltipTitle"] = text;
			l.textField.autoSize = "left";
			l.textField.text = label;
			l._y = _layoutCursor.y;
			l._x = _layoutCursor.x;
			
			var o:TextInput = TextInput(m_Content.attachMovie( "TextInput", "m_" + name, m_Content.getNextHighestDepth() ));

			o.maxChars = maxChars == undefined ? 0 : maxChars;
			
			o["controlName"] = name;
			o["eventValue"] = "e.target.text";
			if( isHexColor ) {
				o["isHexColor"] = isHexColor;
				o.maxChars = 6;
			}
			
			if ( width != undefined ) o._width = width;
			
//			o.disableFocus = true;
			
			o._y = _layoutCursor.y;
			o._x = _layoutCursor.x + 3;	// hardcoded because textinput is currently only used for one thing -- clean up in future

			if ( alignRight ) o._x += 130;
			else o._x += l._width;
			
			_layoutCursor.y += o._height + 3;
			
			return o;
	}
	
	private function AddTextArea( name:String, text:String ) : MovieClip {
		var l = m_Content.attachMovie( "ConfigTextArea", "m_" + name, m_Content.getNextHighestDepth() );
		
		l.textField.htmlText = text;
		l.textField.autoSize = "left";
		l.textField.wordWrap = true;
		l.textField._width = 280;
		
		l._y = _layoutCursor.y;
		l._x = _layoutCursor.x;
		
		_layoutCursor.y += l._height;
		
		return l;
	}
	
	private function AddLabel(name:String, text:String):MovieClip {

		var l = m_Content.attachMovie( "ConfigLabel", "m_" + name + "_Label", m_Content.getNextHighestDepth() );
		o["tooltipTitle"] = text;
		l.textField.autoSize = "left";
		l.textField.text = text;
		l._y = _layoutCursor.y;
		l._x = _layoutCursor.x;
		
		_layoutCursor.y += l._height;
		
		return l;
	}
	
	private function AddColumn():Void
	{
		_layoutCursor.x = this._width + 30;
		_layoutCursor.y = 0;
	}
	
	private function AddIndent(indentX:Number):Void
	{
		if ( indentX != undefined ) _layoutCursor.x += indentX;
	}
	
	private function AddVerticalSpace(size:Number):Void {
		if ( size != undefined ) _layoutCursor.y += size;
	}
	
    //Remove Focus
    private function RemoveFocus():Void
    {
        Selection.setFocus(null);
    }
	
	public function Close():Void
	{
		super.Close();
	}

	
	/**
	 * this is the all-important override that makes window resizing work properly
	 * the SignalSizeChanged signal is monitored by the host window, which resizes accordingly
	 */
    public function SetSize(width:Number, height:Number)
    {	
        m_ContentSize._width = width;
        m_ContentSize._height = height;
        
		SignalSizeChanged.Emit();	// must fire this signal, else the parent WinComp container never gets resized
    }	

    public function GetSize():Point {
        return new Point( m_ContentSize._width, m_ContentSize._height );
    }	
}