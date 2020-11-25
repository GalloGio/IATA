({
	openCabalities : function(component, event, helper) {
		let certId = event.getParam('ardCert');
		let isCapabCertiMode = event.getParam('isCapabCertiMode');
		let labelTab = isCapabCertiMode ? 'Edit' : 'Renewal';
		let navReference = {
			type: 'standard__component',
			attributes: {
			componentName: 'c__cwCapabilitiesManagerConsoleHandler'
			},
			state : {
				c__facilityId : component.get('v.recordId'),
				c__certificationId: certId,
				c__isCapabCertiMode: isCapabCertiMode
			}
		};
		component.set("v.pageReference", navReference);	
		const navService = component.find('navService');
		const workspaceAPI = component.find("workspace");
		const handleUrl = (url) => {
			workspaceAPI.openSubtab({
				url: url,
				focus: true
			}).then(function(subtabId) {
                workspaceAPI.setTabLabel({
				tabId: subtabId,
				label: labelTab
				});
            }).catch(function(error) {
                console.log("error");
            });
		};
		const handleError = (error) => {
			console.log(error);
		};
		
		//console.log(navService.generateUrl(navReference));
		navService.generateUrl(navReference).then(handleUrl, handleError);
	}
})