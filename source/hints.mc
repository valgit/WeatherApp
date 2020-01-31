var locationString;

function onStart(state) {
  Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
}

function onStop(state) {    
  Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));	
}

function onPosition(info) {
    var myLocation = info.position.toDegrees();
    var lat = myLocation[0];
    var long = myLocation[1];        
    locationString = lat + "," + long;
}