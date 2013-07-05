google.load("earth", "1");

var ge = null;

function initMap() {
  google.earth.createInstance("map3d", initCallback, failureCallback);
}

function initCallback(object) {
  ge = object;
  ge.getWindow().setVisibility(true);
  //show controls
  ge.getNavigationControl().setVisibility(ge.VISIBILITY_SHOW);
  lookAtRosario();
}

function failureCallback(object) {
  console.error(object);
}

function lookAtRosario(){
  // Create a new LookAt.
  var lookAt = ge.createLookAt('');

  // Set the position values.
  lookAt.setLatitude(-32.976300530736246);
  lookAt.setLongitude(-60.66069727550966);
  lookAt.setRange(8403.939781190049); //default is 0.0
  lookAt.setTilt(73.37038549852515)

  // Update the view in Google Earth.
  ge.getView().setAbstractView(lookAt);

}

function loadKML(url){
  var features = ge.getFeatures();
  while (features.getLastChild() != null)
  {
    features.removeChild(features.getLastChild());
  }

  var link = ge.createLink('');
  var href = url;
  link.setHref(href);
  
  
  var networkLink = ge.createNetworkLink('');
  networkLink.set(link, true, false); // Sets the link, refreshVisibility, and flyToView

  ge.getFeatures().appendChild(networkLink);
}
$(document).ready(function(){
  google.setOnLoadCallback(initMap);
  $('#update_map').on('click', function(){
    partido = $('#partido_political_party_id').val();
    cargo = $('#cargo_public_office_id').val();
    kml = 'http://192.168.0.3:3000/kml/'+cargo+"/"+partido
    console.log(kml);
    loadKML(kml);
  })

});