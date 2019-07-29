({
	doInit : function(component, event, helper) {
        
        //Check if contact is DPO
        var checkIfContactIsDPOAction = component.get("c.checkIfContactIsDPO");
        checkIfContactIsDPOAction.setCallback(this, function(responseOne){
        	var state = responseOne.getState();
            
        	if (state === "SUCCESS") {
                var isDPO = responseOne.getReturnValue();
                if(isDPO==null)
                    isDPO = false;

                component.set("v.isContactDPO", isDPO);
                
                if(isDPO){
                	helper.retrieveDPOCase(component);
                }
         	}
      	});
       	$A.enqueueAction(checkIfContactIsDPOAction);
        
        var isTabletOrPhone = $A.get("$Browser.isTablet") || $A.get("$Browser.isPhone");
        component.set("v.isTabletOrPhone", isTabletOrPhone);
        
        window.addEventListener('resize', $A.getCallback(function(){
            if(component.isValid()) {
                var isTabletOrPhoneAux = component.get("v.isTabletOrPhone");
                if(!isTabletOrPhoneAux){
                    var viewAsCardAux = component.get("v.viewAsCard");
                    if(!viewAsCardAux){
                        //table still availabe
                        var tableWidth = document.getElementById('requestListDPOTableId').offsetWidth;
                        var screenWidth = window.innerWidth;
                        if(tableWidth >= screenWidth){
                            component.set("v.viewAsCard", true);
                            component.set("v.tableMinWidth", tableWidth);
                        }
                    }else{
                        //show table again
                        var screenWidth = window.innerWidth;
                        var tableMinWidth = component.get("v.tableMinWidth");
                        if(tableMinWidth <= screenWidth){
                            component.set("v.viewAsCard", false);
                        }
                    }
                }
            }
        }));
    },
    
    openDPOCasePopupHandleClick : function (component, event, helper){
        var clickedCaseId = event.getSource().get("v.name");
        var lstCases = component.get("v.lstCases");
        for(var i = 0; i < lstCases.length; i++){
            if(lstCases[i].Id == clickedCaseId){
				component.set("v.showCasePopupObjectDPO", lstCases[i]);
                component.set("v.showCasePopupDPO", true);
                break;
            }
        }
    },
    
    closeDPOCasePopupHandleClick : function (component, event, helper){
        component.set("v.showCasePopupDPO", false);
    },

    handleEVT_GDPR_UpdateCaseList : function (component, event, helper){
        helper.retrieveDPOCase(component);
    }
    
    
})