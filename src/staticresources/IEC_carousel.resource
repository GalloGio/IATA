var iata_carousel_interval = 6000;

$(window).load(function(){
	var carousel_index = 0;
	var carousel_slide_num = $(".carousel .carousel__slide").length;
	var carousel_is_animate = false;

	//Auto scroll, set interval timeout
	var t = setInterval(function(){
		slideCarousel('+=1');
	}, iata_carousel_interval);

	//Carousel click on arrow navigation
	$('.carouselWrapper .arrow').click(function(){
		if($(this).hasClass('right-arrow')) slideCarousel('+=1');
		else slideCarousel('-=1');
	});
	
	//Carousel click on pager navigation
	$('.carouselWrapper .pager .button').click(function(){
		if(carousel_index == $(this).attr("rel")) return;
		var new_index;
		if($(this).attr("rel") > carousel_index) new_index = '+=' + ($(this).attr("rel") - carousel_index);
		else new_index = '-=' + (carousel_index - $(this).attr("rel"));
		slideCarousel(new_index);
	});

	var slideCarousel = function(index) {
		if(!carousel_is_animate) {
			carousel_is_animate = true;
			$('.carousel').jcarousel('scroll', index, function(){
				carousel_is_animate = false;
			});
			carousel_index = eval(carousel_index + index.replace("=", ""));
			if(carousel_index >= carousel_slide_num) carousel_index = 0;
			else if(carousel_index < 0) carousel_index = carousel_slide_num - 1;
			$(".carouselWrapper .pager .button").removeClass("active");
			$(".carouselWrapper .pager .button").eq(carousel_index).addClass("active");
			clearInterval(t);
			t = setInterval(function() {
				slideCarousel('+=1');
			}, iata_carousel_interval);
		}
	};
});


