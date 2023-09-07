// ------------------- Zoom and pan the image ------------------------------
var scale = 1,
panning = false,
pointX = 0,
pointY = 0,
mid_x = 0,
mid_y = 0,
start = { x: 0, y: 0 },
zoommap = document.getElementById("immagine");

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
	} 
	else if (e.type == 'touchstart'){
		if (e.touches.length === 1){
			start = { x: e.touches[0].clientX - pointX, y: e.touches[0].clientY - pointY};			
		} else if (e.touches.length >= 2){
			start = { x: (e.touches[0].clientX + e.touches[1].clientX) / 2 - pointX, 
				y: (e.touches[0].clientY + e.touches[1].clientY) / 2 - pointY,
				dist: Math.hypot(e.touches[0].clientX - e.touches[1].clientX, e.touches[0].clientY - e.touches[1].clientY)
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
	// console.log(img_dim, mapimg_div_dim);

	

	// mapimg_div_dim.right = img_dim.right
	
	if (e.type == 'mousemove'){
		pointX = (e.clientX - start.x);
		pointY = (e.clientY - start.y);
	// 	if (img_dim.right<= (mapimg_div_dim.right + 10)){
	// 		zoommap.style.transform = "translateY(" + pointY + "px) scale(" + scale + ")";
	// 	} else {
		zoommap.style.transform = "translate(" + pointX + "px, " + pointY + "px) scale(" + scale + ")";
	} else if (e.type == 'touchmove'){
		if (e.touches.length === 1){
			pointX = (e.touches[0].clientX - start.x);
			pointY = (e.touches[0].clientY - start.y);
			zoommap.style.transform = "translate(" + pointX + "px, " + pointY + "px) scale(" + scale + ")";	
				
		} else if (e.touches.length === 2){
			  mid_x = (e.touches[0].clientX + e.touches[1].clientX) / 2
		      mid_y = (e.touches[0].clientY + e.touches[1].clientY) / 2
		      pointX = (mid_x - start.x);
		      pointY = (mid_y - start.y);
		}
		
	}

});

//Zooming functionality
((zoommap, event_names, zoom_move) => {
	event_names.forEach( (event_name) => {
		zoommap.addEventListener(event_name, zoom_move)
	})
})(zoommap, ['mousewheel', 'touchmove'], (e) => {
	e.preventDefault();
	zoommap.style.transform = "none";
	var img_dim = zoommap.getBoundingClientRect();


	if (e.type == 'mousewheel'){
    	var x = ((img_dim.width - (img_dim.right- e.clientX ))/img_dim.width) * 100; //x position within the img element
	    var y = ((img_dim.height - (img_dim.bottom- e.clientY))/img_dim.height) * 100; //y position within the img element
	    zoommap.style.transformOrigin = x + "% " + y + "%";
	    var delta = (e.wheelDelta ? e.wheelDelta : -e.deltaY);
	    (delta > 0) ? (scale *= 1.2) : (scale /= 1.2);
	} else if (e.type == 'touchmove'){
		if (e.touches.length == 2){

			if (e.scale) {
				scale = e.scale;
			} else {
				var move_dist = Math.hypot(e.touches[0].clientX - e.touches[1].clientX, e.touches[0].clientY - e.touches[1].clientY);
				(move_dist > start.dist) ? (scale *= (1 + start.dist/move_dist)) : (scale /= (1 + start.dist/move_dist));
			} 
			// Calculate how much the fingers have moved on the X and Y axis
		      var x = ((img_dim.width - (img_dim.right- mid_x ))/img_dim.width) * 100; //x position within the img element
	    	  var y = ((img_dim.height - (img_dim.bottom- mid_y))/img_dim.height) * 100; //y position within the img element
	    	  zoommap.style.transformOrigin = x + "% " + y + "%";
	    	  var button = document.getElementById("maptext");
	    	  
	    	}
	    }
	    	
	    scale = Math.min(Math.max(1, scale), 20);
	    button.innerText = scale;
	    zoommap.style.transform = "scale(" + scale + ") translate(" + pointX + "px, " + pointY + "px)";
	});
