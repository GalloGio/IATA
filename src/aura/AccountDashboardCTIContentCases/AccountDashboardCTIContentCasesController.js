({
	init: function (component, event, helper) {
		helper.initTable(component);
		helper.loadCases(component, helper);
	},
	openCase: function (component, event, helper) {
		let ctarget = event.currentTarget;
		let id_case = ctarget.dataset.value;
		if (id_case != undefined) {
			let urlToOpen = "/lightning/r/Case/" + id_case + "/view";
			helper.openUrlOnSubTab(component, urlToOpen);
		}
	},
});
