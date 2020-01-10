({
	afterRender: function(component, helper)
	{
        this.superAfterRender();

        var utilityBarAPI = component.find("utilitybar");
        var eventHandler = function(response){
            helper.getAllTabInfo(component);
        };

        utilityBarAPI.onUtilityClick({ 
            eventHandler: eventHandler 
        })

    }        
})