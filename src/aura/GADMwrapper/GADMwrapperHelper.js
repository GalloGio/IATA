({

    handleInit : function(component, event) {
        this.toggleSpinner(component);
        let action = component.get('c.getUserRoles');
        action.setParams({
            'userId' : $A.get("$SObjectType.CurrentUser.Id")
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const status = response.getReturnValue();

                if(! $A.util.isEmpty(status)) {

                    if(status === 'Granted') {// access status is granted, check account access status
                        this.checkAccountStatus(component, event);
                    }

                    if(status === 'Pending') {
                        component.set('v.accessMessage', $A.get("$Label.c.GADM_Access_Pending"));
                        component.set('v.accessDenied', true);
                        this.toggleSpinner(component);
                    }

                    if(status === 'Denied') {
                        component.set('v.accessMessage', $A.get("$Label.c.GADM_Access_Denied"));
                        component.set('v.accessDenied', true);
                        this.toggleSpinner(component);
                    }

                }else{
                    //no access to gadm
                    component.set('v.accessMessage', $A.get("$Label.c.GADM_No_Access"));
                    component.set('v.accessDenied', true);
                    this.toggleSpinner(component);
                }
            }else{
                this.toggleSpinner(component);
                component.set('v.accessDenied', true);
                component.set('v.accessMessage', 'Error during initialization.');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": "Error during initialization."
                });
                toastEvent.fire();
            }

        });
        $A.enqueueAction(action);
    },


    checkAccountStatus : function(component, event) {
        let action = component.get('c.getAccountDetails');
        action.setParams({
            'userId' : $A.get("$SObjectType.CurrentUser.Id")
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const result = response.getReturnValue();
                if(! $A.util.isEmpty(result)) {
                    if(! $A.util.isEmpty(result)['status']) {
                        let status = result['status'];

                        if(status === 'Active') {//status active

                            if(! $A.util.isEmpty(result)['effective']) {

                                let effective = result['effective'];

                                if(effective === 'true') {//status active and effective => access granted

                                    component.set('v.accessGranted', true);

                                }else{//effective is not valid

                                    component.set('v.accessMessage', $A.get("$Label.c.GADM_account_not_effective"));
                                    component.set('v.accessDenied', true);
                                }
                            }else{//empty effective

                                component.set('v.accessMessage', $A.get("$Label.c.GADM_No_Access"));
                                component.set('v.accessDenied', true);
                            }
                        }else{//status is not active

                            component.set('v.accessMessage', $A.get("$Label.c.GADM_Account_not_active"));
                            component.set('v.accessDenied', true);
                        }
                    }else{//empty status

                        component.set('v.accessMessage', $A.get("$Label.c.GADM_No_Access"));
                        component.set('v.accessDenied', true);
                    }
                }else{//empty response

                    component.set('v.accessMessage', $A.get("$Label.c.GADM_No_Access"));
                    component.set('v.accessDenied', true);
                }

                this.toggleSpinner(component);

            }else{//unsuccessful response
                this.toggleSpinner(component);
                component.set('v.accessDenied', true);
                component.set('v.accessMessage', 'Error during initialization.');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": "Error during initialization."
                });
                toastEvent.fire();

            }

        });
        $A.enqueueAction(action);
    },


    toggleSpinner : function(component) {
        const spinner = component.find('spinner');
        $A.util.toggleClass(spinner, 'slds-hide');
    }


})