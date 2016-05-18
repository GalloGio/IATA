/*
	Created by: Tomer Glicksman
	Date: 24/9/2015
	Description: Client asked to put more previous years in a specific date picker.
	We bind a focus event to the specific input, and the change the year select options manually.
*/

var datePickerYearsAdded = false;
$(window).load(function(){
	//using on load because date picker is created only after the page is fully loaded
	datePickerYearsAdded = false;
	// var saveLastSelectValues = null;
	var pastYearsToAdd = 30;
	// $("[id$='dateOpenedAsTravelAgency']").focus(function(){
	$(".dateInput input").focus(function(){		
		// dateInput
		if (!datePickerYearsAdded) {
			var select = document.getElementById('calYearPicker');
			if (!select) return;

			// saveLastSelectValues = select.innerHTML;	//saving the previous option values
			select.innerHTML = '';
			var startYear = new Date().getFullYear() - pastYearsToAdd;
			for (var year = startYear; year < startYear + pastYearsToAdd + 1; year++) {
				select.options[select.options.length] = new Option(year, year);
			}
			datePickerYearsAdded = true;
		}
  	});
  // 	$("[id$='dateOpenedAsTravelAgency']").blur(function(){
  // 		//when we blur we want to bring back the previous values of the year picker.
  // 		if ($("#datePicker").is(":hidden")) {	//we want to this only after the datepicker is closed, because when we click on the datepicker we blur from the input too
		// 	var select = document.getElementById('calYearPicker');
		// 	if (!select) return;

		// 	select.innerHTML = saveLastSelectValues;
		// }
  // 	});
});