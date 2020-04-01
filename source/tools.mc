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

/*
 * toolbox of common functions
 */
using Toybox.Application as App;
using Toybox.Math; 

/* handle last refresh date with SDK version */
function getLastRefresh() {
    var myapp = App.getApp();
    var lastFetchTime = null;
    if (Toybox.Application has :Storage && Toybox.Application.Storage has :setValue) {
            lastFetchTime = myapp.Storage.getValue("lastfetchtime");
    } else {
            lastFetchTime = myapp.getProperty("lastfetchtime");
    }

    return lastFetchTime;
}

function setLastRefresh(lastFetchTime) {
    var myapp = App.getApp();

    if (Toybox.Application has :Storage && Toybox.Application.Storage has :setValue) {            
            myapp.Storage.setValue("lastfetchtime",lastFetchTime);
    } else {
            myapp.setProperty("lastfetchtime",lastFetchTime);
    }
}

/* handle last data date with SDK version */
function getLastData() {
    var myapp = App.getApp();
    var data = null;
    if (Toybox.Application has :Storage && Toybox.Application.Storage has :setValue) {
            data = myapp.Storage.getValue("lastdata");
    } else {
            data = myapp.getProperty("lastdata");
    }

    return data;
}

function setLastData(data) {
    var myapp = App.getApp();

    if (Toybox.Application has :Storage && Toybox.Application.Storage has :setValue) {            
            myapp.Storage.setValue("lastdata",data);
    } else {
            myapp.setProperty("lastdata",data);
    }
}

 // speed is in m/s
function formatWindSpeed(speed) {
        if (speed == null) {
            return "-";
        }
/* bug here ?
        switch (App.getApp().getProperty("WindSpeedUnits")) {
        case 1: //kmh
          return (value * 3.6).format("%0.f");
        case 2: //mph
          return (value * 2.237).format("%0.f");
        case 3: // nds
            return (value * 0.5144).format("%0.f");
        default: //ms
          return value.format("%.1f");
        }
*/
        // in nd
		return (speed * 1.943844).format("%0.f");
        return "-";
}

// calc Beaufort from speed in m/s
function formatBeaufort(speed) {
        // bf = sq3 (v^2 / 9) en kmh            
        //var _bfs = pow((windspeed*windspeed/9),(1/3)); e, kmh
        var _bfs = (speed * 1.943844 /5); //  si < 8, sinon +0
        if (_bfs < 8) {
        	_bfs = _bfs +1;
        }
        return Math.floor(_bfs).toNumber();
}

    // TODO: check value
function formatHeading(heading){        
        var index = Math.floor(heading/22.5).toNumber();
        //System.println("test en deg : "+ index);
        var _rosefr = ["N","NNE","NE","ENE","E",
                "ESE","SE","SSE","S","SSO","SO",
                "OSO","O","ONO","NO","NNO"];

        var _roseen = ["N","NNE","NE","ENE","E",
                "ESE","SE","SSE","S","SSW","SW",
                "WSW","W","WNW","NW","NNW"];

        // TODO : add switch
        return _rosefr[index];
}    

function getHour(date) {
      /*
    var _time=new Time.Moment(date);
    var _current = Gregorian.info(_time, Time.FORMAT_MEDIUM);
    var hour = _current.hour;
    */
    var hour = Math.floor(date/3600);
    return hour;
}

function drawIcon(dc, x, y, symbol) {
    var icon = getIcon(symbol);
    icon.setLocation(x, y);
    icon.draw(dc);
    //var dim = icon.getDimensions();
    //System.println("WxH : "+dim[0] + ","+dim[1]);
    //dc.drawText(x,y,Gfx.FONT_SMALL,iconIds[symbol],Gfx.TEXT_JUSTIFY_CENTER);    
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
