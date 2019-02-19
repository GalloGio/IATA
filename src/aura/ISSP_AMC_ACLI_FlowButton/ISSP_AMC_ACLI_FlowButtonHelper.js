({
	showToast : function(typeOfToast, messageOfToast){
        var successParams = {"mode": "pester", "message": messageOfToast, "type": "success"};
        var warningParams = {"mode": "dismissible", "message": messageOfToast, "type": "warning"};
        var errorParams = {"mode": "dismissible", "message": messageOfToast, "type": "error"};

        var toastParams;

        if(typeOfToast==="success"){
           toastParams = successParams;
        } else if(typeOfToast==="warning"){
           toastParams = warningParams;
        } else{
           toastParams = errorParams;
        }

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    }

})