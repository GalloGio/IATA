({
    handleInit : function(component, event) {
        debugger;
        this.toggleSpinner(component);
        this.prepareManagementData(component, event);
    },


    prepareManagementData : function(component, event) {
        debugger;
        let selectedUserInfo = component.get('v.selectedUserInfo');
        let currentUserInfo = component.get('v.currentUserInfo');
        let isSuperUser = component.get('v.isSuperUser');
        let contact = selectedUserInfo.con;
        component.set('v.contact', contact);

        let action = component.get('c.prepareManagementData');
        action.setParams({
            'currentUserData' : JSON.stringify(currentUserInfo),
            'selectedUserData' : JSON.stringify(selectedUserInfo),
            'isSuperUser' : isSuperUser
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const result = response.getReturnValue();
                if(! $A.util.isEmpty(result)) {

                    let roles = result.roles;
                    let rolesData = [];
                    if(! $A.util.isEmpty(roles)) {
                        for(let i in roles) {
                            rolesData.push({value:roles[i], key:i});
                        }
                    }

                    let businessUnits = result.businessUnits;
                    let businessUnitsData = [];
                    if(! $A.util.isEmpty(businessUnits)) {
                        for(let i in businessUnits) {
                            businessUnitsData.push({value: businessUnits[i], key:i});
                        }
                    }

                    let actors = result.actors;
                    let actorsData = [];
                    if(! $A.util.isEmpty(actors)) {
                        for(let i in actors) {
                            actorsData.push({value:actors[i], key:i})
                        }
                    }

                    component.set('v.dataActors', actorsData);
                    component.set('v.dataBusinessUnits', businessUnitsData);
                    component.set('v.dataRoles', rolesData);

                    //save the copy and use it as original data
                    let copy = JSON.stringify(result);
                    component.set('v.copyData', copy);


                    component.set('v.showTable', true);
                    this.toggleSpinner(component);

                }
            }else{
                console.log('prepareManagementData error');
                this.handleErrorMessage(component, 'Unable to get user data!');
                this.toggleSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },


    handleSave : function(component, event) {
        debugger;
        this.toggleSpinner(component);
        let roles = component.get('v.dataRoles');
        let businessUnits = component.get('v.dataBusinessUnits');
        let actors = component.get('v.dataActors');
        let originalData = component.get('v.copyData');

        /*console.log('roles:: ', JSON.stringify(roles));
        console.log('businessUnits:: ', JSON.stringify(businessUnits));
        console.log('actors:: ', JSON.stringify(actors));
        console.log('originalData:: ', JSON.stringify(originalData));*/


        let dataRoles = {};
        if(! $A.util.isEmpty(roles)) {
            for(let i in roles) {
                let key = roles[i].key;
                let value =roles[i].value;
                dataRoles[key] = value;
            }
        }

        let dataBusinessUnits = {};
        if(! $A.util.isEmpty(businessUnits)) {
            for(let i in businessUnits) {
                let key = businessUnits[i].key;
                let value = businessUnits[i].value;
                dataBusinessUnits[key] = value;
            }
        }

        let dataActors = {};
        if(! $A.util.isEmpty(actors)) {
           for (let i in actors) {
               let key = actors[i].key;
               let value = actors[i].value;
               dataActors[key] = value;
           }
        }

        let changedData = {};
        changedData.actors = dataActors;
        changedData.roles = dataRoles;
        changedData.businessUnits = dataBusinessUnits;

        let selectedUserInfo = component.get('v.selectedUserInfo');
        let action = component.get('c.saveManagementData');
        action.setParams({
            'originalData' : originalData,
            'modifiedData' : JSON.stringify(changedData),
            'selectedUserInfo' : JSON.stringify(selectedUserInfo)
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const result = response.getReturnValue();
                if(! $A.util.isEmpty(result)) {

                    //result === true; all OK
                    if(result) {

                        component.set('v.dataModified', true);
                        this.toggleSpinner(component);

                    //result !== true; error occurred
                    }else{

                        console.log('handleSave - unable to save changes');
                        this.handleErrorMessage(component, 'Unable to save data!');
                        this.toggleSpinner(component);
                    }

                }else{
                    console.log('handleSave - unable to save changes');
                    this.handleErrorMessage(component, 'Unable to save data!');
                    this.toggleSpinner(component);
                }
            }else{
                console.log('handleSave - unable to save changes');
                this.handleErrorMessage(component, 'Unable to save data!');
                this.toggleSpinner(component);

            }
        });
        $A.enqueueAction(action);
    },

    handleErrorMessage : function(component, message){
        let action = $A.get('e.force:showToast');
        action.setParams({
            title: 'User Management Error',
            message: message,
            type: 'error'
        });
        action.fire();
    },


    toggleSpinner : function(component) {
        component.set('v.showSpinner', !component.get('v.showSpinner'));
    },


})