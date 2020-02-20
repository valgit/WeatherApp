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
using Toybox.Application;

class WeatherAppApp extends Application.AppBase {
  
    function initialize() {
        AppBase.initialize();

        /*
            // get last know info
        var positionInfo = null;
        var quality = null;
        
        var activityInfo = Activity.getActivityInfo();
        if (activityInfo != null) {
            positionInfo = activityInfo.currentLocation;
            quality = activityInfo.currentLocationAccuracy;
        }

        if (positionInfo != null && quality > Position.QUALITY_NOT_AVAILABLE) {
          lattitude = positionInfo.toDegrees()[0];
          longitude = positionInfo.toDegrees()[1];
          System.println("Refresh location " + lattitude + ", " + longitude + " quality : " + quality);
        } else {
            System.println("no know position ?");
        }
        */
    }

    // onStart() is called on application start up
    function onStart(state) {
        
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        //return [ new WeatherWidView() ];
        //return [ new WeatherAppView() ];
        return [ new WeatherWidView(), new WeatherAppDelegate() ];
    }

    function phoneConnected() {
        return System.getDeviceSettings().phoneConnected;
    }

    function canDoBackground() {
        return (Toybox.System has :ServiceDelegate);
    }

    /*
    function onPosition(info) {
        var myLocation = info.position.toDegrees();
        lattitude = myLocation[0];
        longitude = myLocation[1];        
        //locationString = lat + "," + long;
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }

    function getLocation() {
        var _locationString = lattitude + "," + longitude;
        return _locationString;
    }
    */
}