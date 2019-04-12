({
	doInit : function(component, event, helper) {
        var isGuest = _userInfo.getUserInfo().isGuest;
        component.set("v.isGuest", isGuest);

        if(!isGuest)
            helper.retrieveCases(component);
        
        
        var isTabletOrPhone = $A.get("$Browser.isTablet") || $A.get("$Browser.isPhone");
        component.set("v.isTabletOrPhone", isTabletOrPhone);
        
        window.addEventListener('resize', $A.getCallback(function(){
            if(component.isValid()) {
                var isTabletOrPhoneAux = component.get("v.isTabletOrPhone");
                if(!isTabletOrPhoneAux){
                    var viewAsCardAux = component.get("v.viewAsCard");
                    if(!viewAsCardAux){
                        //table still availabe
                        var tableWidth = document.getElementById('requestListTableId').offsetWidth;
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
    
    openCasePopupHandleClick : function (component, event, helper){
        var clickedCaseId = event.getSource().get("v.name");
        var lstCases = component.get("v.lstCases");
        for(var i = 0; i < lstCases.length; i++){
            if(lstCases[i].Id == clickedCaseId){
				component.set("v.showCasePopupObject", lstCases[i]);
                component.set("v.showCasePopup", true);
                break;
            }
        }
    },
    
    closeCasePopupHandleClick : function (component, event, helper){
        component.set("v.showCasePopup", false);
    },

    handleEVT_GDPR_UpdateCaseList : function (component, event, helper){
        helper.retrieveCases(component);
    }
    
})