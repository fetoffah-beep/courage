// Deactivate mouse (right) click
function blocco_mousedx(){
	return(false);
};
// document.oncontextmenu = blocco_mousedx;


// Set the default value of the date picker to today's date
var date = new Date();
var day = date.getDate();
var month = date.getMonth() + 1;
var year = date.getFullYear();
var currentHour = date.getHours();
if (month < 10) month = "0" + month;
if (day < 10) day = "0" + day;

var today = year + "-" + month + "-" + day;

function calc_date(img_date, inc_value, hr_value) {	
	var url_date = new Date(img_date);
	url_date.setUTCDate(url_date.getUTCDate() + inc_value);
	url_date.setUTCHours(url_date.getUTCHours() + hr_value);
	url_date = [url_date.getUTCFullYear()
	, ((url_date.getUTCMonth()+1 ) < 10 ? "0"+ (url_date.getUTCMonth()+1) : (url_date.getUTCMonth()+1))
	, (url_date.getUTCDate() < 10 ? "0"+ url_date.getUTCDate() : url_date.getUTCDate())
	, (url_date.getUTCHours() < 10 ? "0"+ url_date.getUTCHours() : url_date.getUTCHours())];
	
	return url_date.join('');
};

function img_available(file_url){
	var img = new Image();
	img.src = file_url;
	return img.height != 0;
};

var paramOptions = [];
var paramList = ['Wind speed (10 m)', 'Precipitation', 'Temperature (2 m)', 'Relative Humidity', 'Z+T+WSP at 200 hPa', 'Z+T+WSP at 500 hPa', 'Z+T+WSP at 750 hPa', 'Z+T+WSP at 850 hPa'];
var param_values = ['wsp10_', 'prec_diff_', 't2m_', 'rh_', 'press200_', 'press500_', 'press750_', 'press850_'];
var hourOptions = [];
var hourOptions3 = [];
var hours_prec = [];
var main_folder = null;
const num_days = 5;
var select =  null;

var param_map = new Map();
for (i=0; i<paramList.length; i++){
	param_map.set(paramList[i], param_values[i]);
};
param_map.set('Lightning stroke', 'flash_mccaul_');

window.onload = function() {
	document.getElementById("datePicker").defaultValue = today;
	document.getElementById("datePicker").max = today;

	// Define the values of the time intervals to be used in the hour forecast sections
	const el3 = document.getElementById('hourOption');
	if (el3 === null) {
		for (i=0; i<24; i++){
			
			if(i==currentHour){				
				hourOptions3.push("<option id=\"hourOption\" value = \'"+(i<10 ? "0"+ i : i)+"-"+((i+1)<10 ? "0"+ (i+1) : (i+1))+"\'selected> "+(i<10 ? "0"+ i : i)+"-"+((i+1)<10 ? "0"+ (i+1) : (i+1))+" </option>");
			} else{
				hourOptions3.push("<option id=\"hourOption\" value = \'"+(i<10 ? "0"+ i : i)+"-"+((i+1)<10 ? "0"+ (i+1) : (i+1))+"\'> "+(i<10 ? "0"+ i : i)+"-"+((i+1)<10 ? "0"+ (i+1) : (i+1))+" </option>");
			}
		}
	}

	document.getElementById("vtime_3km").innerHTML = hourOptions3.join();

	// When the page is loaded, display the image for the current day and time
	// If the image for the current timestamp is not available, display prova.png image
	var value = document.getElementById("vcampo_3km").value;
	var param = null;
	var timeTo = null;
	var timeFrom = null;
	
	if(document.getElementById('spatial_interval_3').checked) {
		param = param_map.get('Precipitation');
		main_folder = '../grafici_wrf/';
	}

	var image_element = document.getElementById('immagine');
	var image_url = ( main_folder+year+ '/' +month + '/' + param + calc_date(today, 0, currentHour) + '_' + calc_date(today, 0, (currentHour+1)) +'.png');

	if (img_available(image_url)){
		image_element.src = image_url;
		
	} else {
		image_url = (main_folder + 'prec_prova_orig.png');
		image_element.src = image_url;
		
	}
	
}


function checkRadio(){
	if(document.getElementById('spatial_interval_6').checked) {
		let vcampo_6km = document.getElementById("vcampo_6km");
		let vcampo_3km = document.getElementById("vcampo_3km");
		let vtime_3km = document.getElementById("vtime_3km");
		let vtime_6km = document.getElementById("vtime_6km");
		vcampo_6km.style.display = "inline-block";
		vcampo_3km.style.display = "none";
		vtime_6km.style.display = "inline-block";
		vtime_3km.style.display = "none";

		const el1 = document.getElementById('selectOption');
		if (el1 === null) {
			paramOptions.push("<optgroup label='Parameters'>");
			for (i=0; i<paramList.length; i++){
				paramOptions.push("<option id=\"selectOption\" value = \'"+paramList[i]+"\'> "+paramList[i]+" </option>");
			}
			paramOptions.push("</optgroup>");
			
		} 

		// Define the values of the time intervals to be used in the hour forecast sections
		const el2 = document.getElementById('hourOption6km');
		if (el2 === null) {
			// The time intervals for all other parameters
			for (j=0; j<num_days; j++){
				hourOptions.push("<optgroup label='Day "+j+"'>");
				for (i=0; i<24; i=i+3){
					// if (i==0 && j==0){
					// 	continue;
					// } else 
					if (i>0 && j==4) {
						continue;
					} else {

						hourOptions.push("<option id=\"hourOption6km\" value = \' "+j+"-"+(i<10 ? "0"+ i : i)+"\'>" + 'Day'+j+ ' ' +(i<10 ? "0"+ i : i)+" </option>");
					}
				}
				hourOptions.push("</optgroup>");
				
			}
			// The time intervals for the precipitation parameter
			for (j=0; j<num_days; j++){
				if (j==(num_days-1)){
					continue;
				}
				hours_prec.push("<optgroup label='Day "+j+"'>");
				for (i=0; i<24; i=i+3){
					// if (i==0 && j==0){
					// 	continue;
					// } else 
					// {
						hours_prec.push("<option id=\"hourOption6km\" value = \'"+j+"-"+(i<10 ? "0"+ i : i)+"-"+((i+3)<10 ? "0"+ (i+3) : (i+3))+"\' >" + 'Day'+j+ ' '+(i<10 ? "0"+ i : i)+"-"+((i+3)<10 ? "0"+ (i+3) : (i+3))+" </option>");
					// }
				}
				hours_prec.push("</optgroup>");
			}
		} 
		vcampo_6km.innerHTML = paramOptions.join();
		vtime_6km.innerHTML = hourOptions.join();

	}else if(document.getElementById('spatial_interval_3').checked) {
		let vcampo_6km = document.getElementById("vcampo_6km");
		let vcampo_3km = document.getElementById("vcampo_3km");
		let vtime_3km = document.getElementById("vtime_3km");
		let vtime_6km = document.getElementById("vtime_6km");
		vcampo_6km.style.display = "none";
		vcampo_3km.style.display = "inline-block";
		vtime_6km.style.display = "none";
		vtime_3km.style.display = "inline-block";
	}
	showimage();
};



function update_map(){
	let date_value = document.getElementById("datePicker");
	date_value = date_value.value.split('-');
	var image_url = null;

	if(document.getElementById('spatial_interval_6').checked) {
		let vcampo_6km = document.getElementById("vcampo_6km");
		
		var image_url = null;
		let vtime_6km = document.getElementById("vtime_6km");
		var sel_idx = vtime_6km.selectedIndex;

		if (vcampo_6km.value == 'Precipitation'){
			vtime_6km.innerHTML = hours_prec.join();
			vtime_6km.options.selectedIndex = sel_idx;
		} else{
			vtime_6km.innerHTML = hourOptions.join();
			vtime_6km.options.selectedIndex = sel_idx;
		}
		
		param = param_map.get(vcampo_6km.value);
		main_folder = '../grafici_wrf_6km/';

		if (vcampo_6km.value == 'Precipitation'){
			image_url = (main_folder + date_value[0]+ '/' + date_value[1] + '/' + param + calc_date(date_value.join('-'), 0, 0) + '_' + calc_date(date_value.join('-'), parseInt(vtime_6km.value.split('-')[0]), parseInt(vtime_6km.value.split('-')[1])) +'_' + calc_date(date_value.join('-'), parseInt(vtime_6km.value.split('-')[0]), parseInt(vtime_6km.value.split('-')[2]))+'.png');
		} else{
			image_url = (main_folder + date_value[0]+ '/' + date_value[1] + '/' + param + calc_date(date_value.join('-'), 0, 0) + '_' + calc_date(date_value.join('-'), parseInt(vtime_6km.value.split('-')[0]), parseInt(vtime_6km.value.split('-')[1])) +'.png');
		}

	} else if(document.getElementById('spatial_interval_3').checked) {
		let vcampo_3km = document.getElementById("vcampo_3km");
		let vtime_3km = document.getElementById("vtime_3km");
		
		param = param_map.get(vcampo_3km.value);
		main_folder = '../grafici_wrf/';
		image_url = (main_folder + date_value[0]+ '/' + date_value[1] + '/' + param + calc_date(date_value.join('-'), 0, parseInt(vtime_3km.value.split('-')[0])) + '_' + calc_date(date_value.join('-'), 0, parseInt(vtime_3km.value.split('-')[1])) +'.png'); 
	}
	return image_url;
};

function showimage(){
	let image_element = document.getElementById('immagine');
	let img_url = update_map();
	image_element.src = img_url;
	
	if (img_available(img_url)){
		image_element.src = img_url;
	}

	
};

function prevousImage(){
	if (document.getElementById('forwardnav').disabled){
		document.getElementById('forwardnav').disabled = false;
	}

	if(document.getElementById('spatial_interval_6').checked) {
		select = document.getElementById("vtime_6km");
	} else if(document.getElementById('spatial_interval_3').checked){
		select = document.getElementById("vtime_3km");
	}
	
	if (!document.getElementById('backnav').disabled){
		select.options.selectedIndex = select.options.selectedIndex-1;
		if (select.options.selectedIndex <= 0){
			document.getElementById('backnav').disabled = true;
		}
	}

	showimage();
};

function nextImage(){
	if (document.getElementById('backnav').disabled){
		document.getElementById('backnav').disabled = false;
	}

	if(document.getElementById('spatial_interval_6').checked) {
		select = document.getElementById("vtime_6km");
	} else if(document.getElementById('spatial_interval_3').checked){
		select = document.getElementById("vtime_3km");
	}
	
	if (!document.getElementById('forwardnav').disabled){
		select.options.selectedIndex = select.options.selectedIndex+1;
		if ( select.options.selectedIndex >= (select.options.length-1)){
			document.getElementById('forwardnav').disabled = true;
		}
		
	}
	showimage();
};



function find_available_imgs(){
	let available_imgs = new Map();
	let date_value = document.getElementById("datePicker");
	date_value = date_value.value.split('-');
	var image_url = null;	

	if(document.getElementById('spatial_interval_6').checked) {
		let vcampo_6km = document.getElementById("vcampo_6km");
		let dummy_vtime_6km = document.getElementById("dummy_vtime_6km");
		if (vcampo_6km.value == 'Precipitation'){
			dummy_vtime_6km.innerHTML = hours_prec.join();	
		} else{
			dummy_vtime_6km.innerHTML = hourOptions.join();
		}
		param = param_map.get(vcampo_6km.value);
		main_folder = '../grafici_wrf_6km/';
		
		for (i=0; i<dummy_vtime_6km.length; i++){
			if (vcampo_6km.value == 'Precipitation'){
				image_url = (main_folder + date_value[0]+ '/' + date_value[1] + '/' + param + calc_date(date_value.join('-'), 0, 0) + '_' + calc_date(date_value.join('-'), parseInt(dummy_vtime_6km.options[i].value.split('-')[0]), parseInt(dummy_vtime_6km.options[i].value.split('-')[1])) +'_' + calc_date(date_value.join('-'), parseInt(dummy_vtime_6km.options[i].value.split('-')[0]), parseInt(dummy_vtime_6km.options[i].value.split('-')[2]))+'.png');
			} else{
				image_url = (main_folder + date_value[0]+ '/' + date_value[1] + '/' + param + calc_date(date_value.join('-'), 0, 0) + '_' + calc_date(date_value.join('-'), parseInt(dummy_vtime_6km.options[i].value.split('-')[0]), parseInt(dummy_vtime_6km.options[i].value.split('-')[1])) +'.png');
			}
			
			if (img_available(image_url)){
				available_imgs.set(i, image_url);
			}
		}
	} else if(document.getElementById('spatial_interval_3').checked){
		dummy_vtime_3km = document.getElementById("dummy_vtime_3km");
		dummy_vtime_3km.innerHTML = hourOptions3.join();

		let vcampo_3km = document.getElementById("vcampo_3km");
		param = param_map.get(vcampo_3km.value);
		main_folder = '../grafici_wrf/';

		for (i=0; i<dummy_vtime_3km.length; i++){
			image_url = (main_folder + date_value[0]+ '/' + date_value[1] + '/' + param + calc_date(date_value.join('-'), 0, parseInt(dummy_vtime_3km.options[i].value.split('-')[0])) + '_' + calc_date(date_value.join('-'), 0, parseInt(dummy_vtime_3km.options[i].value.split('-')[1])) +'.png');
			if (img_available(image_url)){
				available_imgs.set(i, image_url);	
			}
		}
	}
	return available_imgs;
};

var currentidx = 0;

function animation_button(){
	var btn = document.getElementById("animButton");
	let images_available = find_available_imgs();
	let possible_elem = ['vcampo_3km', 'vcampo_6km', 'datePicker'];
	
	if (images_available.size > 0){
		if (btn.innerHTML == "Start animation") {
			btn.innerHTML = "Stop animation";
		} else {
			btn.innerHTML = "Start animation";
		}
		animation();
	} else {
		for (i=0; i<possible_elem.length; i++){
			document.getElementById(possible_elem[i]).addEventListener("change", (event) => {
				if (btn.innerHTML == "Stop animation") {
					btn.innerHTML = "Start animation";
				}
			});
		}
		alert("There are no images for " + document.getElementById("datePicker").value);
	}
}


function animation(){
	let image_element = document.getElementById('immagine');
	let images_available = find_available_imgs();
	var btn = document.getElementById("animButton");

	// Stop the animation and update its button when there are no images available
	if (images_available.size == 0){
		if (btn.innerHTML == "Stop animation") {
			btn.innerHTML = "Start animation";
			clearTimeout('animation()');
		}
	}
	
	if (document.getElementById('backnav').disabled || document.getElementById('forwardnav').disabled){
		document.getElementById('backnav').disabled = false;
		document.getElementById('forwardnav').disabled = false;
	}

	if (currentidx>images_available.size){
		currentidx = 0;
	}

	if (document.getElementById('spatial_interval_6').checked) {
		let vcampo_6km = document.getElementById("vcampo_6km");
		select = document.getElementById("vtime_6km");
	} else if(document.getElementById('spatial_interval_3').checked){
		let vcampo_3km = document.getElementById("vcampo_3km");
		select = document.getElementById("vtime_3km");
	}
	
	for (i=0; i<select.length; i++){
		if (i === Array.from(images_available.keys())[currentidx]){
			select.options.selectedIndex = i;
			image_element.src = images_available.get(i);
			
		}
	}

	currentidx++;

	if (document.getElementById("animButton").innerHTML   == "Stop animation"){
		setTimeout('animation()',1000);
	} else if (document.getElementById("animButton").innerHTML   == "Start animation"){
		if (currentidx <= 0){
			document.getElementById('backnav').disabled = true;
		} else if (currentidx >= select.length){
			document.getElementById('forwardnav').disabled = true;
		}	
	}
};



function error_message(){
	let date_value = document.getElementById("datePicker");
	let param_name = null;
	let forecast_hr = null;

	var btn = document.getElementById("animButton");
	
    // if (btn.innerHTML == "Stop animation") {
    // 	btn.innerHTML = "Start animation";
    // } 

    if(document.getElementById('spatial_interval_6').checked) {
    	param_name = document.getElementById("vcampo_6km");
    	forecast_hr = document.getElementById("vtime_6km");
    } else if(document.getElementById('spatial_interval_3').checked) {
    	param_name = document.getElementById("vcampo_3km");
    	forecast_hr = document.getElementById("vtime_3km");
    }

    var message = "Image for "+ param_name.value + " on " + date_value.value + " at " + forecast_hr.value + " hr(s) is not available";
    return message;
};

function imgerror(){
	let image_element = document.getElementById('immagine');
	if (image_element.naturalHeight <=0){
		alert(error_message());
	}
};


function layer_view(img_url) {
	var img = new Image();
	img.src = img_url;

	var boundary = new ol.layer.Image();

	img.onload = function(){
		var extent = [0, 0, img.naturalWidth, img.naturalHeight];
		var projection = new ol.proj.Projection({
			code: 'xkcd-image',
			units: 'pixels',
			extent: extent,
		});

		var mapElement = new ol.Map({
			layers: [boundary],
			view: new ol.View({
				projection: projection,
				center: ol.extent.getCenter(extent),
				zoom: 1,
				minZoom: 1,
				maxZoom: 4
			})
		});

		mapElement.getLayers().getArray()[0].setSource ( new ol.source.ImageStatic({
			url: img_url,
			attributions: '© cnr-isac (2023)',
			projection: projection,
			imageExtent: extent,
		}));
		mapElement.setTarget(document.getElementById('mapim'));
		mapElement.getLayers().getArray()[0].getSource().url = img_url;		
		mapElement.changed();
	
	}
};
