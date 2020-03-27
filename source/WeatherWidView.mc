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
using Toybox.Communications;
using Toybox.Application as App;
using Toybox.Graphics as Gfx; 
using Toybox.Math; 

using Toybox.Time;
using Toybox.Time.Gregorian;

class WeatherWidView extends WatchUi.View {
    var units = null;
    private var _model; // weather info
    private var latitude = null;
	private var longitude = null;

	private var width = null;
	private var height = null;	

	//private var mTimer = null;
    private var _status = null;

	//private var lastData;
    //private var lastFetchTime = null;

	private var summary = null;
	private var pressure = null;
    private var temperature = null;
    private var windspeed = null;
    private var windbearing = null;
    private var weathericon = null;
	private var apparentTemperature = null;
    private var proba = null;
    private var writer = null;

    private var hourly = null;

    //private var fontA = null;

    function initialize(model) {
    	System.println("initialize");
        View.initialize();
    
        units =(System.getDeviceSettings().temperatureUnits==System.UNIT_STATUTE) ? "us" : "si";
        //System.println("units in " + units);
        //System.println("lang : " + System.getDeviceSettings().systemLanguage);

        _model = model;

        /* last known position */
        var positionInfo = Position.getInfo();
        var myLocation = positionInfo.position.toDegrees();
        latitude = myLocation[0];
        longitude = myLocation[1];
    	System.println(latitude + "," +longitude  );
    	//System.println(); // longitude (e.g -94.800953)
        
        if (positionInfo.accuracy == Position.QUALITY_NOT_AVAILABLE) {
        	System.println("no position : "+positionInfo.accuracy);
            latitude = 50.4747;
            longitude = 3.061;
        }
        _model.setPosition(latitude,longitude);
                
        var freshen = _model.freshness();
        
        // more than 1 hour ?
        _status = 0;
        if (freshen >= 1) { // TODO: check value
                System.println("(too old) Fetching weather data on startup " + freshen);                
                _model.makeHourlyWeatherRequest();               
        } else {                
                System.println("using current weather data");
                var data = getLastData();
                //parseCurrentWeather(data);
                _model.parseHourlyWeather(data);                
        }              

 
     
    }

    // Load your resources here
    function onLayout(dc) {
        //setLayout(Rez.Layouts.MainLayout(dc));
        width=dc.getWidth();
        height=dc.getHeight();

        writer = new WrapText();

        // load custom font
        //fontA = WatchUi.loadResource(Rez.Fonts.id_font_watch); 
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    	// Allocate a 1Hz timer               
        //mTimer = new Timer.Timer();     
        //mTimer.start(method(:onTimer), 1000, true);
    }

	// Handler for the timer callback
    function onTimer() {
    	//System.println("onTimer");
    	// for testing
    	//mModel.generateTest();
    	
    	//mModel.updateTimer();
        //WatchUi.requestUpdate();
    }
    
    // Update the view
    function onUpdate(dc) {
    	System.println("onUpdate");

        //TODO get info from model
        //_model.get

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_BLACK);
		dc.clear();
		dc.setColor(Gfx.COLOR_WHITE,/*Gfx.COLOR_RED*/ Gfx.COLOR_TRANSPARENT);

        // Get and show the current time
        //var clockTime = System.getClockTime();
        //var timeString = Lang.format("$1$:$2$:$3$", [clockTime.hour, clockTime.min.format("%02d"), clockTime.sec.format("%02d")]);		
		
		//dc.drawText(width * 0.5, height * 0.12,Gfx.FONT_SMALL,timeString,Gfx.TEXT_JUSTIFY_CENTER);
        var freshen = _model.freshness();
        
        var _timeString = "last update "+freshen.format("%.0f") + " m";
        dc.drawText(width * 0.5, height * 0.12,Gfx.FONT_XTINY,_timeString,Gfx.TEXT_JUSTIFY_CENTER);         		
 		
        if (_status != 0) {
            dc.drawText(width * 0.5, height * 0.5,Gfx.FONT_XTINY,"waiting data...",Gfx.TEXT_JUSTIFY_CENTER);
        }
		if (summary != null) {
            drawIcon(dc,width * 0.5 - 64,height * 0.5 - 64 ,weathericon);// 64 pix

            var y = height * 0.25;
            var _tempstr = temperature.format("%.0f") + "°";
            dc.drawText(width * 0.5, y,
                Gfx.FONT_NUMBER_MEDIUM,
                _tempstr,
                Gfx.TEXT_JUSTIFY_LEFT);
            _tempstr = "Feels " + apparentTemperature.format("%.0f") + "°";
            y = y + Graphics.getFontHeight(Gfx.FONT_NUMBER_MEDIUM);

            dc.drawText(width * 0.5,y,
                Gfx.FONT_XTINY,
                _tempstr,
                Gfx.TEXT_JUSTIFY_LEFT);

            //dc.drawText(width * 0.25,height * 0.75 ,Gfx.FONT_TINY,summary,Gfx.TEXT_JUSTIFY_LEFT);
            var posY = height * 0.75;
            posY = writer.writeLines(dc, summary, Gfx.FONT_XTINY, posY);

            //y = height * 0.5;
            y = y + Graphics.getFontHeight(Gfx.FONT_XTINY);
            _tempstr = "Wind:" + formatWindSpeed(windspeed) + " nd @ " + formatHeading(windbearing) + "("+windbearing.format("%.0f")+")";
            // + " @ " +  / " + formatBeaufort(windspeed);
            dc.drawText(width * 0.25,y,
                Gfx.FONT_XTINY,
                _tempstr,
                Gfx.TEXT_JUSTIFY_LEFT);
                
            y = y + Graphics.getFontHeight(Gfx.FONT_XTINY);
            var _proba = proba * 100;
            _tempstr = pressure.format("%.0f") + " hPa Hum: " + _proba.format("%.0f")+ " %";
            dc.drawText(width * 0.25,y,
                Gfx.FONT_XTINY,
                _tempstr,
                Gfx.TEXT_JUSTIFY_LEFT);

            //writer.testFit(posY);  // start scrolling ?
            /*          
            //var _bfs = formatBeaufort(windspeed);
            //System.println("speed : "+ _bfs );
            */
            if (hourly != null) {
                // TODO : get current hour
                drawHourly(dc,0 , height * 0.75,hourly[10]);                
            }
            

        }
    
        //gridOverlay(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    	//mTimer.stop();
        //mTimer = null;
    }


    function gridOverlay(dc) {
        dc.setPenWidth(1);		
        dc.setColor(0xFFFFFF, 0xFFFFFF);
        //var grid = 32;		
        /*
        for (var i=1; i< grid; i+=1){ 
            dc.drawLine (0, width*i/grid, width, height*i/grid); 					
            dc.drawLine (width*i/grid, 0, width*i/grid, height); 
        } 
        */
        dc.drawLine (0, height*0.25, width, height*0.25); 
        dc.drawLine (0, height*0.5, width, height*0.5); 
        dc.drawLine (0, height*0.75, width, height*0.75); 

		dc.setColor(0xFFFF00, 0xFFFF00);
        dc.drawLine (width * 0.25, 0, width * 0.25, height); 
        dc.drawLine (width * 0.5, 0, width * 0.5, height); 
        dc.drawLine (width * 0.75, 0, width * 0.75, height); 
        //System.println("wh : "+ width * 0.25 + " px , hh : " + height*0.25 + " px");
    }


 function drawHourly(dc,x,y,hour) {
        System.println("in drawHourly");
        var _time=new Time.Moment(hour["time"]);
        var _current = Gregorian.info(_time, Time.FORMAT_MEDIUM);
        System.println("["+_current.day + " - "+_current.hour+":"+_current.min+"]");
        System.println("icon: " + hour["icon"] + " T: " +hour["temperature"]+ " Pre : "+(hour["precipProbability"] * 100).format("%.0f"));
        System.println("Wind: " + hour["windSpeed"] + "m/s P: " +hour["pressure"].format("%.0f")+ " hPa");
        System.println("summary: " + hour["summary"]);
 }

    // map icon name to png
    var iconIds = { 
        "clear-day" => :clear_day,
        "clear-night" => :clear_night,
        "cloudy" => :cloudy,
        "fog" => :fog,
        "partly-cloudy-day" => :partly_cloudy_day,
        "partly-cloudy-night" => :partly_cloudy_night,
        "rain" => :rain,
        "sleet" => :sleet,
        "snow" => :snow,
        "wind" => :wind
    };

  function getIcon(name) {
    return new WatchUi.Bitmap({:rezId=>Rez.Drawables[iconIds[name]]});
  }

  function drawIcon(dc, x, y, symbol) {
    var icon = getIcon(symbol);
    icon.setLocation(x, y);
    icon.draw(dc);
    //var dim = icon.getDimensions();
    //System.println("WxH : "+dim[0] + ","+dim[1]);
    //dc.drawText(x,y,Gfx.FONT_SMALL,iconIds[symbol],Gfx.TEXT_JUSTIFY_CENTER);    
  }
 

/* samples
       // debug
        /*
        summary = "Ciel Couvert";
        pressure = 1021.3;
        temperature = 5.12;
        windspeed = 7.7;
        windbearing = 294;
        weathericon = "cloudy";
        apparentTemperature = 8;
        */
        /*
        summary = "Ciel Dégagé";
        pressure = 1036.3;
        temperature = 3.22;
        windspeed = 0.83;
        windbearing = 331;
        weathericon = "clear-day";
        apparentTemperature = 3.22;
    */
    /*
     	summary = "Vent moyen commençant dans la matinée, se prolongeant jusqu’à ce soir.";
        pressure = 1008.9;
        temperature = 5.02;
        windspeed = 8.85;
        windbearing = 261;
        weathericon = "clear-day";
        apparentTemperature = -0.06;
        proba = 0.06;
		_status = 0;
	*/

 
}