// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>

  function initialize() {
    var latlng = new google.maps.LatLng(-34.397, 150.644);
    var myOptions = {
      zoom: 8,
      center: latlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
  }

