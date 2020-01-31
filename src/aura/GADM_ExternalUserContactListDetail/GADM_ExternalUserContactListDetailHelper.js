({
    handleInit : function(component, event) {
        this.toggleSpinner(component);
        this.prepareManagementData(component, event);
    },


    prepareManagementData : function(component, event) {
        let selectedUserInfo = component.get('v.selectedUserInfo');
        let currentUserInfo = component.get('v.currentUserInfo');
        let isSuperUser = component.get('v.isSuperUser');
		let isPowerUser = component.get('v.isPowerUser');
        let action = component.get('c.prepareManagementData');
        action.setParams({
            'currentUserData' : JSON.stringify(currentUserInfo),
            'selectedUserData' : JSON.stringify(selectedUserInfo),
            'isSuperUser' : isSuperUser,
            'isPowerUser' : isPowerUser
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const result = response.getReturnValue();
                if(! $A.util.isEmpty(result)) {

                    let isCurrentUseIsSelectedUser = result.currentUserIsSelectedUser;

                    let roles = result.roles;
                    let rolesData = [];
                    if(! $A.util.isEmpty(roles)) {
                        for(let i in roles) {
                            let error = '';

                            if(isCurrentUseIsSelectedUser) {
                               error = $A.get('$Label.c.GADM_User_Management_cannot_edit_own_assignments');
                            }
                            else if(! roles[i].isEditable) {
                                error = $A.get('$Label.c.GADM_User_Management_role_not_editable');
                            }else if(roles[i].isDomainBlocked) {
                                error = $A.get('$Label.c.GADM_User_Management_gadm_user_domain_blocked');
                            }
                            rolesData.push({value:roles[i], key:i, errorText:error});

                            if(roles[i].role.Name === 'GADM User') {
                                let isChecked = roles[i].isChecked;
                                if(! $A.util.isEmpty(isChecked)) {
                                    component.set('v.hasGadmUserRole', isChecked);
                                }else{
                                    component.set('v.hasGadmUserRole', false);
                                }
                            }
                        }
                    }

                    let businessUnits = result.businessUnits;
                    let businessUnitsData = [];
                    if(! $A.util.isEmpty(businessUnits)) {
                        for(let i in businessUnits) {
                            let error = '';

                            if(isCurrentUseIsSelectedUser) {
                               error = $A.get('$Label.c.GADM_User_Management_cannot_edit_own_assignments');
                            }
                            else if(! businessUnits[i].isEditable) {
                                error = $A.get('$Label.c.GADM_User_Management_business_unit_not_available');
                            }
                            businessUnitsData.push({value: businessUnits[i], key:i, errorText:error});
                        }
                    }

                    let actors = result.actors;
                    let actorsData = [];
                    if(! $A.util.isEmpty(actors)) {
                        for(let i in actors) {
                            let error = '';

                            if(isCurrentUseIsSelectedUser) {
                               error = $A.get('$Label.c.GADM_User_Management_cannot_edit_own_assignments');
                            }
                            else if(! actors[i].isEditable) {
                                error = $A.get('$Label.c.GADM_User_Management_actor_not_available');
                            }else if(actors[i].isDomainBlocked) {
                                error = $A.get('$Label.c.GADM_User_Management_domain_blocked');
                            }
                            actorsData.push({value:actors[i], key:i, errorText:error});
                        }

                        let maxUserCount = 0;
                        let currentUserCount = 0;
                        let userCountReached = 0;
                        let accountDetail = actors[selectedUserInfo.con.AccountId];
                        if(! $A.util.isEmpty(accountDetail)) {
                            maxUserCount = accountDetail.maxUserCount;
                            currentUserCount = accountDetail.currentUserCount;
                            userCountReached = currentUserCount >= maxUserCount;
                        }

                        component.set('v.userCountReached', userCountReached);
                        component.set('v.maxUserCount', maxUserCount);
                        component.set('v.activeUserCount', currentUserCount);
                        component.set('v.gadmUserReachedText', maxUserCount + ' ' + $A.get("$Label.c.GADM_active_users_reached"));
                    }

                    component.set('v.currentUserIsSelectedUser', isCurrentUseIsSelectedUser);
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
        this.toggleSpinner(component);
        component.set('v.showTable', false);
        let roles = component.get('v.dataRoles');
        let businessUnits = component.get('v.dataBusinessUnits');
        let actors = component.get('v.dataActors');
        let originalData = component.get('v.copyData');

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

                        //reload on same page
                        //this.reloadAfterSave(component, event);
                        
                        //redirect bach to list of all users
                        let myEvent = component.getEvent("Back_EVT");
                        myEvent.setParams({
                            'dataModified' : component.get('v.dataModified'),
                            'page' : 'detail'
                        });
                        myEvent.fire();

                    //result !== true; error occurred
                    }else{

                        console.log('handleSave - unable to save changes');
                        this.handleErrorMessage(component, $A.get("$Label.c.GADM_User_Management_unable_to_save"));
                        this.toggleSpinner(component);
                        component.set('v.showTable', true);
                    }

                }else{
                    console.log('handleSave - unable to save changes');
                    this.handleErrorMessage(component, $A.get("$Label.c.GADM_User_Management_unable_to_save"));
                    this.toggleSpinner(component);
                    component.set('v.showTable', true);
                }
            }else{
                console.log('handleSave - unable to save changes');
                this.handleErrorMessage(component, $A.get("$Label.c.GADM_User_Management_unable_to_save"));
                this.toggleSpinner(component);
                component.set('v.showTable', true);

            }
        });
        $A.enqueueAction(action);
    },


    reloadAfterSave : function(component, event) {
        let action = component.get('c.reloadData');
        let selectedUserInfo = component.get('v.selectedUserInfo');
        let selectedContact = selectedUserInfo.con;
        let isSuperUser = component.get('v.isSuperUser');
        let isGadmUser = component.get('v.isGadmUser');
        let businessUnits = component.get('v.businessUnits');
        action.setParams({
            'userId' : $A.get('$SObjectType.CurrentUser.Id'),
            'isSuperUser' : isSuperUser,
            'isGadmUser' : isGadmUser,
            'businessUnits' : businessUnits,
            'selectedContact' : selectedContact
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {

                const result = response.getReturnValue();
                if(! $A.util.isEmpty(result)) {

                    component.set('v.selectedUserInfo', result);
                    this.prepareManagementData(component, event);

                }else{
                    console.log('reloadAfterSave error - empty result');
                    this.handleErrorMessage(component, $A.get("$Label.c.GADM_User_Management_unable_to_save"));
                    this.toggleSpinner(component);
                    component.set('v.showTable', true);
                }
            }else{
                console.log('reloadAfterSave error');
                this.handleErrorMessage(component, $A.get("$Label.c.GADM_User_Management_unable_to_save"));
                this.toggleSpinner(component);
                component.set('v.showTable', true);
            }
        });
        $A.enqueueAction(action);
    },

    handleUserCountCheck : function(component, event) {
        let value = event.getSource().get("v.checked");
        if(value) {
            component.set('v.gadmUserRoleAdded', true);
        }else{
            component.set('v.gadmUserRoleAdded', false);
        }
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