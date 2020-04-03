/*
	Copyright (c) 2020, vbrasseur at gmail dot com
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:
	    * Redistributions of source code must retain the above copyright
	      notice, this list of conditions and the following disclaimer.
	    * Redistributions in binary form must reproduce the above copyright
	      notice, this list of conditions and the following disclaimer in the
	      documentation and/or other materials provided with the distribution.
	    * Neither the name of the <organization> nor the
	      names of its contributors may be used to endorse or promote products
	      derived from this software without specific prior written permission.
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Graphics as Gfx; 

//TODO: as function
using Toybox.Time;
using Toybox.Time.Gregorian;

/* 
 * this view display hourly weather data
 */
class WeatherAppView extends WatchUi.View {
    private var mWidth;
    private var mHeight;

    private var _model;

    function initialize(model) {
        System.println("view app initialize");
        View.initialize();
        _model = model;
    }

    // Load your resources here
    function onLayout(dc) {
        //setLayout(Rez.Layouts.MainLayout(dc));
        System.println("view app onLayout");
        mWidth=dc.getWidth();
        mHeight=dc.getHeight();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        System.println("view app onShow");
    }

    // Update the view
    function onUpdate(dc) {
        System.println("view app onUpdate");
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
          
        dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_BLACK);
		dc.clear();
		dc.setColor(Gfx.COLOR_WHITE,/*Gfx.COLOR_RED*/ Gfx.COLOR_TRANSPARENT);

        var _todo = "this is hourly view";
        dc.drawText(mWidth * 0.1, mHeight * 0.5,Gfx.FONT_XTINY,_todo,Gfx.TEXT_JUSTIFY_CENTER);

        if (_model.hourly != null) {
                // TODO : get current hour
                //var now = System.getTimer();
                //var _now = System.getClockTime(); // ClockTime object
                //var _hour = _now.hour;
                //System.println("now is : " + _hour);
                //var now = Time.now();
                for(var h = 0; h < 8; h++) {
                    drawHourly(dc,mWidth * 0.1 , h * 64 ,_model.hourly[h]);
                }
        }
            
        System.println("view app onUpdate - out");
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
        System.println("view app onHide");
    }

    function drawHourly(dc,x,y,hour) {
        System.println("in drawHourly " + x + "," + y);
        //TODO: as function 
        var _time=new Time.Moment(hour["time"]);
        var _current = Gregorian.info(_time, Time.FORMAT_MEDIUM);
        System.println("["+_current.day + " - "+_current.hour+":"+_current.min+"]");
        System.println("icon: " + hour["icon"] + " T: " +hour["temperature"]+ " Pre : "+(hour["precipProbability"] * 100).format("%.0f"));
        System.println("Wind: " + hour["windSpeed"] + "m/s P: " +hour["pressure"].format("%.0f")+ " hPa");
        System.println("summary: " + hour["summary"]);
        drawIcon(dc,x - 64,y - 64 ,hour["icon"]);// 64 pix
        var _tempstr = hour["temperature"].format("%.0f") + "°";
        dc.drawText(x, y,
                Gfx.FONT_NUMBER_MEDIUM,
                _tempstr,
                Gfx.TEXT_JUSTIFY_LEFT);
        //_tempstr = "Feels " + _model.apparentTemperature.format("%.0f") + "°";
        y = y + Graphics.getFontHeight(Gfx.FONT_NUMBER_MEDIUM);
        return y;
 }
}


class WeatherAppViewDelegate extends WatchUi.BehaviorDelegate {
	private var _model;
	
    function initialize(model) {
        System.println("WeatherAppViewDelegate - view delegate init");
        BehaviorDelegate.initialize();
        _model = model;
    }

    function onMenu() {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new WeatherAppMenuDelegate(), WatchUi.SLIDE_UP);        
        return true;
    }

}
