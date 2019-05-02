({
    handleInit : function(component, event) {
        /*this.toggleSpinner(component);
        let action = component.get('c.getAccounts');
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const accounts = response.getReturnValue();
                if(! $A.util.isEmpty(accounts)) {
                    component.set('v.accounts', accounts);
                    this.getUserAccount(component, event);
                }
            }else{
                this.toggleSpinner(component);
            }
        });
        $A.enqueueAction(action);*/
        this.toggleSpinner(component);
        this.getContactDetails(component, event);
    },


    getContactDetails : function(component, event) {
        debugger;
        let action = component.get('c.getContactDetails');
        let contactId = component.get('v.contact').Id;
        action.setParams({
            'contactId' : contactId
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const contact = response.getReturnValue();
                if(! $A.util.isEmpty(contact)) {
                    component.set('v.contact', contact);

                    this.getAllRoles(component, event);

                }else{
                    //TODO:handle error
                    this.toggleSpinner(component);
                }
            }else{
                //TODO:handle error
                this.toggleSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },


    getAllRoles : function(component, event) {
        debugger;
        let action = component.get('c.getAllRoles');
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const roles = response.getReturnValue();
                if(! $A.util.isEmpty(roles)) {
                    component.set('v.roles', roles);
                    for(let role in roles) {
                        roles[role].checked = false;
                        roles[role].isEditable = false;
                    }

                    this.getManagingUserRoles(component, event);

                }else{
                    //TODO:handle error
                    this.toggleSpinner(component);
                }

            }else{
                //TODO:handle error
                this.toggleSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },


    getManagingUserRoles : function(component, event) {
        let action = component.get('c.getManagingUserGrantedUserRoles');
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const managingUserRoles = response.getReturnValue();
                if(! $A.util.isEmpty(managingUserRoles)) {
                    let allRoles = component.get('v.roles');
                    for(let i = 0; i < allRoles.length; i ++) {
                        for(let j = 0; j < managingUserRoles.length; j++) {
                            if(allRoles[i].Id == managingUserRoles[j].Id) {
                                allRoles[i].isEditable = true;
                                break;
                            }
                        }
                    }
                    component.set('v.roles', allRoles);
                    component.set('v.managingUserRoles', managingUserRoles);

                    this.getUserGrantedRoles(component, event);

                }else{
                    //TODO:handle error
                    this.toggleSpinner(component);
                }

            }else{
                //TODO:handle error
                this.toggleSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },


    getUserGrantedRoles : function(component, event) {
        let action = component.get('c.getGrantedUserRoles');
        let contact = component.get('v.contact');
        action.setParams({
            'contactId' : contact.Id
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                let userGrantedRoles = response.getReturnValue();
                if(! $A.util.isEmpty(userGrantedRoles)) {

                    let allRoles = component.get('v.roles');
                    for(let i = 0 ; i < allRoles.length; i ++) {
                        for(let j = 0; j < userGrantedRoles.length; j ++) {
                            if(allRoles[i].Id == userGrantedRoles[j].Id) {
                                allRoles[i].checked = true;
                                break;
                            }
                        }
                    }

                    component.set('v.roles', allRoles);
                    component.set('v.userGrantedRoles', userGrantedRoles);

                    this.getManagingUserAccountsWithGrantedAccess(component, event);

                }else{
                    //TODO:handle error
                    this.toggleSpinner(component);
                }
            }else{
                //TODO:handle error
                let error = response.getError();
                console.log(response.getError());
                this.toggleSpinner(component);
            }
        });
        $A.enqueueAction(action);

    },

    getManagingUserAccountsWithGrantedAccess : function(component, event) {
        let action = component.get('c.getGrantedAccessAccountsForManagingUser');
        /*let contactId = component.get('v.contact').Id;
        action.setParams({
            'contactId' : contactId
        });*/
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const result = response.getReturnValue();
                if(! $A.util.isEmpty(result)) {
                    for(let account in result) {
                        result[account].checked = false;
                    }
                    component.set('v.managingUserAccessGrantedAccounts', result);

                    this.getAccountsWithGrantedAccess(component, event);

                }else{
                    //TODO:handle error
                    this.toggleSpinner(component);
                }

            }else{
                //TODO:handle error
                this.toggleSpinner(component);
            }

        });
        $A.enqueueAction(action);

    },


    getAccountsWithGrantedAccess : function(component, event) {
        debugger;
        let action = component.get('c.getGrantedAccessAccounts');
        let contactId = component.get('v.contact').Id;
        action.setParams({
            'contactId' : contactId
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const userAccounts = response.getReturnValue();
                if(! $A.util.isEmpty(userAccounts)) {

                    let managingUserAccounts = component.get('v.managingUserAccessGrantedAccounts');
                    for(let i = 0; i < managingUserAccounts.length; i++) {
                        for(let j = 0; j < userAccounts.length; j++) {
                            if(managingUserAccounts[i].Id === userAccounts[j].Id) {
                                managingUserAccounts[i].checked = true;
                                break;
                            }
                        }
                    }
                    component.set('v.managingUserAccessGrantedAccounts', managingUserAccounts);

                    component.set('v.accessGrantedAccounts', userAccounts);

                    component.set('v.displayTable', true);
                    this.toggleSpinner(component);

                }else{
                    //TODO:handle error
                    this.toggleSpinner(component);
                }

            }else{
                //TODO:handle error
                this.toggleSpinner(component);
            }

        });
        $A.enqueueAction(action);

    },




    toggleSpinner : function(component) {
        const spinner = component.find('spinner');
        $A.util.toggleClass(spinner, 'slds-hide');
    },


})