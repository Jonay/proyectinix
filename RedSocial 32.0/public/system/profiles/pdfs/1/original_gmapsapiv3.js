

function initializemaps(map) {
	var latlng = new google.maps.LatLng(27.977424, -15.588226);
	
	//Creatin a MapOptions object with tthe required properties
	var myOptions = {
		zoom: 8,
		//center: latlng,
		/*mapTypeControl: false,*/
		mapTypeId: google.maps.MapTypeId.ROADMAP,
   		
		navigationControlOptions: {
			style: google.maps.NavigationControlStyle.ZOOM_PAN,
			position: google.maps.ControlPosition.TOP_RIGHT
		},

		mapTypeControlOptions: {
			style: google.maps.MapTypeControlStyle.DROPDOWN_MENU,
			position: google.maps.ControlPosition.TOP_LEFT
		},
	};

	//Creating the map
	//var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
	var map = new google.maps.Map(document.getElementById(map), myOptions);
// Adjusting the map to new bounding box 
	addallmarker(map);
}
	

function initializemaps2(map,lat,lng,draggable) {
	var latlng = new google.maps.LatLng(parseFloat(lat),parseFloat(lng));
	
	//Creatin a MapOptions object with tthe required properties
	var myOptions = {
		zoom: 8,
		center: latlng,
		//mapTypeControl: false,
		mapTypeId: google.maps.MapTypeId.ROADMAP,
   		
		navigationControlOptions: {
			style: google.maps.NavigationControlStyle.ZOOM_PAN,
			position: google.maps.ControlPosition.TOP_RIGHT
		},

		mapTypeControlOptions: {
			style: google.maps.MapTypeControlStyle.DROPDOWN_MENU,
			position: google.maps.ControlPosition.TOP_LEFT
		},
	};
	//Creating the map
	//var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
	var map = new google.maps.Map(document.getElementById(map), myOptions);


// Adjusting the map to new bounding box 

// add the marker itself
      var marker = new google.maps.Marker({
        position: latlng,
        map: map,
		draggable: draggable
      });

	google.maps.event.addListener(marker, 'position_changed', function() {
		var darwin = new google.maps.LatLng(marker.getPosition());
  		
    	$('input:text[name=camera[lng]]').val(marker.getPosition().lng());
    	$('input:text[name=camera[lat]]').val(marker.getPosition().lat());
    	//document.getElementById("Longitud").innerHTML = marker.getPosition().lng();
    	//document.getElementById("Latitud").innerHTML = marker.getPosition().lat();
    	//document.getElementById("lng").value = marker.getPosition().lng();
    	//document.getElementById("lat").value = marker.getPosition().lat();
    	//map.setZoom(1);
    	map.setCenter(marker.getPosition());
  });
}


function addallmarker(map){

// Creating a LatLngBounds object 
	var bounds = new google.maps.LatLngBounds();

$.get('http://localhost:3000/cameras.xml', function(xml){
    $(xml).find("camera").each(function(){
      // create a new LatLng point for the marker
      var lat = $(this).find('lat').text();
      var lng = $(this).find('lng').text();
      var point = new google.maps.LatLng(parseFloat(lat),parseFloat(lng));
      
      // extend the bounds to include the new point
      var marker = new google.maps.Marker({
        position: point,
        map: map,
		//draggable: true
      });
    	bounds.extend(point);
      });
		
		map.fitBounds(bounds)
    });

}

/*
google.maps.event.addListener(map, 'rightclick', function(event) {
	map.setCenter(event.latLng);
	//map.setZoom(10);      

	var marker = new google.maps.Marker({
		position: event.latLng, 
		map: map,
		draggable: true,
		title:"Nueva Cámara!"
	});
)}

function moveToDarwin() {
	var darwin = new google.maps.LatLng(27.977424, -15.588226);
	map.setCenter(darwin);
}
*/

function add_marker(map, lat, lng) {
	var point = new google.maps.LatLng(parseFloat(lat),parseFloat(lng));
	var myOptions = {
		zoom: 10,
		center: point,
		//mapTypeControl: false,
		mapTypeId: google.maps.MapTypeId.ROADMAP,
   		
		navigationControlOptions: {
			style: google.maps.NavigationControlStyle.ZOOM_PAN,
			position: google.maps.ControlPosition.TOP_RIGHT
		},

		mapTypeControlOptions: {
			style: google.maps.MapTypeControlStyle.DROPDOWN_MENU,
			position: google.maps.ControlPosition.TOP_LEFT
		},
	};
	var map = new google.maps.Map(document.getElementById(map), myOptions);
     
      // add the marker itself
      var marker = new google.maps.Marker({
        position: point,
        map: map,
		draggable: true
      });
}


