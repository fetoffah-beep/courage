// ------------------- Zoom and pan the image ------------------------------
var scale = 1,
panning = false,
pointX = 0,
pointY = 0,
start = { x: 0, y: 0 },
zoommap = document.getElementById("immagine");

const touch_array = [];


// Mouse down || touchstart
((zoommap, event_names, zoom_start) => {
	event_names.forEach( (event_name) => {
		zoommap.addEventListener(event_name, zoom_start)
	})
})(zoommap, ['mousedown', 'touchstart'], (e) => {
	e.preventDefault();
	panning = true;
	if (e.type == 'mousedown'){
		start = { x: e.clientX - pointX, y: e.clientY - pointY };
	} else if (e.type == 'touchstart'){
		if (e.touches.length === 1){
			start = { x: e.touches[0].clientX , y: e.touches[0].clientY};			
		} else if (e.touches.length >= 1){
			start = { x: (e.touches[0].clientX + e.touches[1].clientX) / 2, 
					  y: (e.touches[0].clientY + e.touches[1].clientY) / 2,
					  dist: Math.hypot(event.touches[0].pageX - event.touches[1].pageX, event.touches[0].pageY - event.touches[1].pageY)
					};
		}
	}
});

// Mouse up || touchend
((zoommap, event_names, zoom_end) => {
	event_names.forEach( (event_name) => {
		zoommap.addEventListener(event_name, zoom_end)
	})
})(zoommap, ['mouseup', 'touchend', 'touchcancel'], (e) => {
	panning = false;
});

// Mouse move || touchmove || Panning the image
((zoommap, event_names, zoom_end) => {
	event_names.forEach( (event_name) => {
		zoommap.addEventListener(event_name, zoom_end)
	})
})(zoommap, ['mousemove', 'touchmove'], (e) => {
	e.preventDefault();
	if (!panning) {
		return;
	}
	
	// var mapimg_div = document.getElementById("mapimg");
	// var mapimg_div_dim = mapimg_div.getBoundingClientRect();
	// var img_dim = zoommap.getBoundingClientRect();
	// mapimg_div_dim.right = img_dim.right
	
	if (e.type == 'mousemove'){
		pointX = (e.clientX - start.x);
		pointY = (e.clientY - start.y);
		zoommap.style.transform = "translate(" + pointX + "px, " + pointY + "px) scale(" + scale + ")";
	} else if (e.type == 'touchmove'){
		pointX = (e.touches[0].clientX - start.x);
		pointY = (e.touches[0].clientY - start.y);
		zoommap.style.transform = "translate(" + pointX + "px, " + pointY + "px) scale(" + scale + ")";
	}

});


//Zooming functioncality
((zoommap, event_names, zoom_move) => {
	event_names.forEach( (event_name) => {
		zoommap.addEventListener(event_name, zoom_move)
	})
})(zoommap, ['mousewheel', 'touchmove'], (e) => {
	e.preventDefault();

    if (e.type == 'mousedown'){
    	zoommap.style.transform = "none";

		var img_dim = zoommap.getBoundingClientRect();
	    var x = ((img_dim.width - (img_dim.right- e.clientX ))/img_dim.width) * 100; //x position within the img element
	    var y = ((img_dim.height - (img_dim.bottom- e.clientY))/img_dim.height) * 100; //y position within the img element
	    zoommap.style.transformOrigin = x + "% " + y + "%";

	    var delta = (e.wheelDelta ? e.wheelDelta : -e.deltaY);

	    (delta > 0) ? (scale *= 1.2) : (scale /= 1.2);

	} else if (e.type == 'touchstart'){
		if (e.touches.length === 2){

			if (event.scale) {
		        scale = event.scale;
		    } else {
				const move_dist = Math.hypot(event.touches[0].pageX - event.touches[1].pageX, event.touches[0].pageY - event.touches[1].pageY);
		        scale = move_dist / start.distance;
		      }
		      // Calculate how much the fingers have moved on the X and Y axis
		      pointX = (((event.touches[0].pageX + event.touches[1].pageX) / 2) - start.x);
		      pointY = (((event.touches[0].pageY + event.touches[1].pageY) / 2) - start.y);
		}
	}
	scale = Math.min(Math.max(1, scale), 20);
	zoommap.style.transform = "scale(" + scale + ") translate(" + pointX + "px, " + pointY + "px)";
});
