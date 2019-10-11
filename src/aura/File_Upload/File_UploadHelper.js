({

    getSettings : function(component, event) {
        this.toggleSpinner(component);
        let action = component.get('c.getGadmSettings');
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                let gadmSettings = response.getReturnValue();
                if(! $A.util.isEmpty(gadmSettings)) {
                    let maxFileSize = gadmSettings.Max_File_Size_MB__c;
                    if($A.util.isEmpty(maxFileSize) || maxFileSize < 0) {
                        maxFileSize = 1;
                    }
                    if(maxFileSize === 0) {//this means unlimited file size
                        component.set('v.maxFileSize', 0);
                    }else{
                        component.set('v.maxFileSize', maxFileSize*1048576);//in bytes
                    }

                    let maxFileCount = gadmSettings.Max_Files_Count__c;
                    if($A.util.isEmpty(maxFileCount) || maxFileCount < 0) {
                        maxFileCount = 0;
                    }

                    let emptyFileSize = gadmSettings.Empty_File_Size_B__c;
                    if($A.util.isEmpty(emptyFileSize) || emptyFileSize < 0) {
                        emptyFileSize = 1;
                    }

                    let iataEmailContact = gadmSettings.IATA_Email_Contact__c;
                    if(! $A.util.isEmpty(iataEmailContact)) {
                        let label = $A.get('$Label.c.GADM_Data_Submission_help');
                        label = label.replace('{0}', iataEmailContact);
                        component.set('v.iataEmailContact', label);
                    }

                    let credentialsName = gadmSettings.Credentials_Name__c;

                    component.set('v.maxFileCount', maxFileCount);
                    component.set('v.emptyFileSize', emptyFileSize);
                    component.set('v.credentialsName', credentialsName);

                    let permittedExtensions = gadmSettings.Permitted_File_Extensions__c;
                    if(! $A.util.isEmpty(permittedExtensions)) {
                        let allowedExtensions = [];
                        allowedExtensions = permittedExtensions.split(';');
                        component.set('v.allowedExtensions', allowedExtensions);
                    }else{
                        component.set('v.allowedExtensions', []);
                    }

                    this.fetchUserInformation(component, event);

                }else{
                    console.log('getSettings method returned empty settings');
                    this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_unexpected_error'), $A.get('$Label.c.GADM_Data_Submission_no_gadm_settings'));
                    this.toggleSpinner(component);
                }
            }else{
                console.log('getSettings error');
                this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_unexpected_error'), $A.get('$Label.c.GADM_Data_Submission_no_gadm_settings'));
                this.toggleSpinner(component);
            }

        });
        $A.enqueueAction(action);
    },

    fetchUserInformation : function(component, event) {
        let action = component.get('c.getUserInformation');
        action.setParams({
            'userId' : $A.get('$SObjectType.CurrentUser.Id')
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS'){
                let userInformation = response.getReturnValue();
                if(! $A.util.isEmpty(userInformation)) {

                    let isInternalUser = userInformation.isInternalUser;
                    component.set('v.isInternalUser', isInternalUser);

                    let isExternalUser = userInformation.isExternalUser;
                    component.set('v.isExternalUser', isExternalUser);

                    /*internal user must have permission set Data Submissions to be able to see the component */
                    if(isInternalUser == true) {
                        this.checkInternalUserPermissionSet(component, event);
                    }

                    if(isExternalUser == true) {
                        /*if external user, users sends data for himself only */
                        let userId = userInformation.userId;
                        component.set('v.userId', userId);

                        let actors = userInformation.actors;
                        if(! $A.util.isEmpty(actors)) {
                            let actorsData = [];
                            for(let actor in actors) {
                                actorsData.push({'label':actors[actor].Name, 'value':actors[actor].Id});
                            }

                            if(actors.length > 1) {
                                component.set('v.actors', actorsData);
                                this.showContent(component);
                                this.toggleSpinner(component);
                            }else{
                                component.set('v.actors', actorsData);
                                component.set('v.actorId', actors[0].Id);
                                this.showContent(component);
                                this.toggleSpinner(component);
                            }
                        }else{
                            console.log('no actors retrieved');
                            this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_unexpected_error'), $A.get('$Label.c.GADM_Data_Submission_no_valid_actor'));
                            this.toggleSpinner(component);
                            this.showContent(component);
                            this.disableContent(component, event);
                        }
                    }

                }else{
                    console.log('empty user information retrieved');
                    this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_unexpected_error'), $A.get('$Label.c.GADM_Data_Submssion_no_user_information'));
                    this.toggleSpinner(component);
                }
            }else{
                console.log('error retrieving user information');
                this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_unexpected_error'), $A.get('$Label.c.GADM_Data_Submssion_no_user_information'));
                this.toggleSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },


    checkInternalUserPermissionSet : function(component, event) {
        let action = component.get('c.checkForInternalUserPermissionSet');
        action.setParams({
            'userId' : $A.get('$SObjectType.CurrentUser.Id')
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const result = response.getReturnValue();
                if(! $A.util.isEmpty(result)) {
                    if(result === true) {
                        component.set('v.hasPermissionSet', true);
                        this.showContent(component);
                        this.toggleSpinner(component);
                    }else{
                        //user does not have permission set fot Data submission
                        component.set('v.hasPermissionSet', false);
                        this.showContent(component);
                        this.toggleSpinner(component);
                    }
                }else{
                    console.log('checkInternalUserPermissionSet error');
                    this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_unexpected_error'), $A.get('$Label.c.GADM_Data_Submission_no_permission_set'));
                    this.toggleSpinner(component);
                }
            }else{
                console.log('checkInternalUserPermissionSet error');
                this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_unexpected_error'), $A.get('$Label.c.GADM_Data_Submission_no_permission_set'));
                this.toggleSpinner(component);
            }

        });
        $A.enqueueAction(action);
    },

    fetchUserFromContact : function(component, event, contactId) {
        let action = component.get('c.getUserFromContact');
        action.setParams({
            'contactId' : contactId
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const result = response.getReturnValue();
                if(! $A.util.isEmpty(result)) {
                    let userId = result;

                    this.fetchDesignedUserInformation(component, event, userId);

                }else {
                    console.log('error retrieving user information');
                    this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_unexpected_error'), $A.get('$Label.c.GADM_Data_Submssion_no_user_information'));
                }
            }else{
                console.log('error retrieving user information');
                this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_unexpected_error'), $A.get('$Label.c.GADM_Data_Submssion_no_user_information'));
            }
        });
        $A.enqueueAction(action);
    },


    fetchDesignedUserInformation : function(component, event, designedUserId) {
        let action = component.get('c.getUserInformation');
        action.setParams({
            'userId' : designedUserId
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                let userInformation = response.getReturnValue();
                if(! $A.util.isEmpty(userInformation)) {

                    let userId = userInformation.userId;
                    component.set('v.userId', userId);

                    let actors = userInformation.actors;
                    if(! $A.util.isEmpty(actors)) {
                        let actorsData = [];
                        for(let actor in actors) {
                            actorsData.push({'label':actors[actor].Name, 'value':actors[actor].Id});
                        }

                        if(actors.length > 1) {
                            component.set('v.actors', actorsData);

                        }else{
                            component.set('v.actorId', actors[0].Id);
                        }
                    }else{
                        console.log('no actors with configured ExternalActorId found');
                        this.disableContentInternal(component, event);
                        this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_unexpected_error'), $A.get('$Label.c.GADM_Data_Submission_no_valid_actor'));
                    }
                }else{
                    console.log('error retrieving user information');
                    this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_unexpected_error'), $A.get('$Label.c.GADM_Data_Submssion_no_user_information'));
                }
            }else{
                console.log('error retrieving user information');
                this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_unexpected_error'), $A.get('$Label.c.GADM_Data_Submssion_no_user_information'));
            }
        });
        $A.enqueueAction(action);
    },


    handleDrop : function(component, event) {
        console.log('File(s) dropped');
        //list of new files
        var filesToAdd = [];

        if (event.dataTransfer.items) {
            // Use DataTransferItemList interface to access the file(s)
            for (var i = 0; i < event.dataTransfer.items.length; i++) {
                // If dropped items aren't files, reject them
                if (event.dataTransfer.items[i].kind === 'file') {
                    var file = event.dataTransfer.items[i].getAsFile();
                    var validationResult = this.checkFile(component, event, file, filesToAdd.length);
                    if(validationResult === 1) {
                        filesToAdd.push(file);
                        console.log(i + ':... file[' + i + '].name = ' + file.name);
                    }else if(validationResult === 2) {
                        this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_bad_file_extension'), 'File: ' + file.name + ' could not be added. Allowed file extensions: ' + this.getAllowedExtensions(component));
                    }else if(validationResult === 3) {
                        this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_empty_file'), 'File: ' + file.name + ' could not be added.');
                    }else if(validationResult === 4) {
                        this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_file_is_selected'), 'File: ' + file.name + ' could not be added.');
                    }else if(validationResult === 5) {
                        this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_file_is_big') + ' Allowed file size is ' + component.get('v.maxFileSize')/1048576 +' MB!', 'File: ' + file.name);
                    }else if(validationResult === 6){
                        this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_too_many_files'), 'Only ' + component.get('v.maxFileCount') + ' files allowed to attach!');
                    }
                }else{
                    //add error - it is not a file!
                    this.showToast(component, 'error', 'Error!', file.name + ' - is not a file!');
                }
            }

        } else {
            //Use DataTransfer interface to access the file(s)
            for (var i = 0; i < event.dataTransfer.files.length; i++) {
                var file = event.dataTransfer.files[i];
                var validationResult = this.checkFile(component, event, file, filesToAdd.length);
                if(validationResult === 1) {
                    filesToAdd.push(file);
                    console.log(i + ':... file[' + i + '].name = ' + file.name);
                }else if(validationResult === 2) {
                    this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_bad_file_extension'), 'File: ' + file.name + ' could not be added. Allowed file extensions: ' + this.getAllowedExtensions(component));
                }else if(validationResult === 3) {
                    this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_empty_file'), 'File: ' + file.name + ' could not be added.');
                }else if(validationResult === 4) {
                    this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_file_is_selected'), 'File: ' + file.name + ' could not be added.');
                }else if(validationResult === 5) {
                    this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_file_is_big') + ' Allowed file size is ' + component.get('v.maxFileSize')/1048576 +' MB!', 'File: ' + file.name);
                }else if(validationResult === 6){
                    this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_too_many_files'), 'Only ' + component.get('v.maxFileCount') + ' files allowed to attach!');
                }
            }
        }

        if(filesToAdd.length > 0) {
            this.addNewFiles(component, event, filesToAdd);
        }

        var dropZone = component.find('dropZone');
        $A.util.removeClass(dropZone, 'is-dragover');
    },


    addNewFiles : function(component, event, newFiles) {
        var existingFiles = component.get('v.files');
        for(let i = 0; i < newFiles.length; i++) {
            existingFiles.push(newFiles[i]);
        }
        component.set('v.files', existingFiles);

    },

    handleDrag : function(component, event) {
        this.handleDefault(component, event);
        var dropZone = component.find('dropZone');
        $A.util.addClass(dropZone, 'is-dragover');
    },

    handleDragEnd : function(component, event) {
        this.handleDefault(component, event);
    },

    handleDragLeave : function(component, event) {
        this.handleDefault(component, event);
        var dropZone = component.find('dropZone');
        $A.util.removeClass(dropZone, 'is-dragover');
    },

    handleDefault : function(component, event) {
        // Prevent default behavior (Prevent file from being opened)
        event.preventDefault();
        event.stopPropagation();
    },

    handleFileInput : function(component, event) {
        var attachedFiles = component.get('v.files');

        var fileInput = document.getElementById("fileInput");
        var files = fileInput.files;

        var filesToAdd = [];

        for(let i = 0; i < files.length; i++) {
            var file = files[i];
            var validationResult = this.checkFile(component, event, file, filesToAdd.length);
            if(validationResult === 1) {
                filesToAdd.push(file);
                console.log(i + ':... file[' + i + '].name = ' + file.name);
            }else if(validationResult === 2) {
                this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_bad_file_extension'), 'File: ' + file.name + ' could not be added. Allowed file extensions: ' + this.getAllowedExtensions(component));
            }else if(validationResult === 3) {
                this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_empty_file'), 'File: ' + file.name + ' could not be added.');
            }else if(validationResult === 4) {
                this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_file_is_selected'), 'File: ' + file.name + ' could not be added.');
            }else if(validationResult === 5) {
                this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_file_is_big') + ' Allowed file size is ' + component.get('v.maxFileSize')/1048576 +' MB!', 'File: ' + file.name);
            }else if(validationResult === 6){
                this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_too_many_files'), 'Only ' + component.get('v.maxFileCount') + ' files allowed to attach!');
            }
        }

        if(filesToAdd.length > 0) {
            fileInput.value = '';//null the input - otherwise adding the same file again wont work
            this.addNewFiles(component, event, filesToAdd);
        }

    },

    checkFile : function(component, event, file, filesCount) {
        let validFileExtensions = component.get('v.allowedExtensions');
        let validationResult = 2;// set to unsupported extension

        //valid file extension check
        let fileName = file.name;
        if (fileName.length > 0) {
            for (let j = 0; j < validFileExtensions.length; j++) {
                let sCurExtension = validFileExtensions[j];
                if (fileName.substr(fileName.length - sCurExtension.length, sCurExtension.length).toLowerCase() == sCurExtension.toLowerCase()) {
                    validationResult = 1;
                    break;
                }
            }
            if(validationResult === 2) {
                return 2;
            }
        }
        //empty file check
        let emptyFileSize = component.get('v.emptyFileSize');
        if(file.size < emptyFileSize) {
            return 3;
        }

        //duplicate file name check
        let existingFiles = component.get('v.files');
        for(let i = 0; i < existingFiles.length; i++) {
            if(existingFiles[i].name === file.name) {
                return 4;
            }
        }

        //too large file check
        let maxFileSize = component.get('v.maxFileSize');
        if(maxFileSize === 0) {
            //file size is unlimited - do not check it
            console.log('unlimited file size is set!');
        }else{
          if(file.size > maxFileSize) {
              return 5;
          }
        }

        let maxFileCount = component.get('v.maxFileCount');
        let existingFilesCount = existingFiles.length;
        if(existingFilesCount + filesCount >= maxFileCount) {
            return 6;
        }

        return 1;

    },

    showToast : function(component, type, title, message) {
        let isLightning = component.get('v.theme') === 'Theme4d';
        if(isLightning) {
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": type,
                "title": title,
                "message": message
            });
            toastEvent.fire();
        }else{
            let toastMessageEvent = $A.get("e.c:Data_Submission_Message_EVT");
            if(toastMessageEvent) {
                toastMessageEvent.setParams({
                    "heading" : title,
                    "message" : message,
                    "messageType" : type
                });
                toastMessageEvent.fire();
            }

        }
    },

    getAllowedExtensions : function(component) {
        var allowedExtensions = component.get('v.allowedExtensions');
        var result = '';
        if(allowedExtensions) {
            result = allowedExtensions[0];
            for(let i = 1; i < allowedExtensions.length; i ++) {
                result += ', ' + allowedExtensions[i];
            }
        }
        return result;
    },

    handleRemoveFile : function(component, event) {
        var value = event.currentTarget.getAttribute("data-value");

        var allFiles = component.get('v.files');
        for(let i = 0; i < allFiles.length; i++) {
            if(allFiles[i].name === value) {
                allFiles.splice(i, 1);
                break;
            }
        }
        component.set('v.files', allFiles);
    },

    handleRemoveUploadedFile : function(component, event, fileName) {
        var allFiles = component.get('v.files');
        for(let i = 0; i < allFiles.length; i++) {
            if(allFiles[i].name === fileName) {
                allFiles.splice(i, 1);
                break;
            }
        }
        component.set('v.files', allFiles);

    },

    handleUpdateDataSubmission : function(component, event, dataSubmissionWrappers) {
        if(dataSubmissionWrappers && dataSubmissionWrappers.length > 0) {
            let action = component.get('c.updateDataSubmission');
            action.setParams({
                dataSubmissionWrappers : dataSubmissionWrappers
            })
            action.setCallback(this, function(response){
                const state = response.getState();
                if(state === 'SUCCESS') {
                    let result = response.getReturnValue();
                    if(result === true) {
                        console.log('Data_Submission__c updated successfully!');
                    }
                }else{
                    console.log('Error updating Data_Submission__c : ' + dataSubmissionWrappers);
                }
            });
            $A.enqueueAction(action);
        }
    },


    toggleSpinner : function(component) {
        component.set('v.showSpinner', ! component.get('v.showSpinner'));
    },

    displayUploadMessages : function(component, event, successes, errors) {
        let isLightning = component.get('v.theme') === 'Theme4d';
        if(isLightning) {
            for(let i = 0; i < successes.length; i++) {
                this.showToast(component, 'success', $A.get('$Label.c.GADM_Data_Submission_upload_successful'), $A.get('$Label.c.GADM_Data_Submission_file_uploaded') + ' ' + successes[i].fileName);
            }

            for(let i = 0; i < errors.length; i++) {
                this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_upload_error'), $A.get('$Label.c.GADM_Data_Submission_upload_error') + ' ' + errors[i].fileName);
            }

        }else{
            if(! $A.util.isEmpty(successes)) {
                let successMessage = '';
                for(let success in successes) {
                    successMessage += successes[success].fileName + '\n';
                }
                this.showToast(component, 'success', $A.get('$Label.c.GADM_Data_Submission_upload_successful'), successMessage);
            }

            if(! $A.util.isEmpty(errors)) {
                let errorMessage = '';
                for(let error in errors) {
                    errorMessage += errors[error].fileName + '\n';
                }
                this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_upload_errors'), errorMessage);
            }

        }

        var dataSubmissionWrappers = successes;
        successes = [];
        component.set('v.successfullyUploaded', successes);

        errors = [];
        component.set('v.uploadedErrors', errors);

        var allFiles = component.get('v.files');
        allFiles = [];
        component.set('v.files', allFiles);
        this.toggleSpinner(component);
        this.handleUpdateDataSubmission(component, event, dataSubmissionWrappers);
    },

    handleActorChange : function(component, event) {
        let selectedActorId = event.getParam('value');
        if(! $A.util.isEmpty(selectedActorId)) {
            component.set('v.actorId', selectedActorId);
        }
    },

    showContent : function(component) {
        let content = component.find('content');
        $A.util.toggleClass(content, 'slds-hide');
    },

    checkContactAndActor : function(component, event, files) {
        let userId = component.get('v.userId');
        let actorId = component.get('v.actorId');

        if($A.util.isEmpty(userId)) {
            this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_no_user'), $A.get('$Label.c.GADM_Data_Submission_select_user'));
            this.toggleSpinner(component);
            return;
        }

        if($A.util.isEmpty(actorId)) {
            this.showToast(component, 'error', $A.get('$Label.c.GADM_Data_Submission_no_actor'), $A.get('$Label.c.GADM_Data_Submission_select_actor'));
            this.toggleSpinner(component);
            return;
        }
        /*if all is OK, start uploading files*/
        this.uploadFiles(component, event, files);

    },


    uploadFiles : function(component, event, files) {

        let self = this;

        let fileCounter = {
            value: 0,
            reset: function (val) { value = val; },
            //increase: function() { value++; },
            //decrease: function() { value--; },
            refreshIfEmpty: function () {
                value--;
                if (value == 0) refreshList();
            }
        }

        function uploadFile(file, component, event) {
            let action = component.get('c.createDataSubmission');
            action.setParams({
                'submitterId' : component.get('v.userId'),
                'actorId' : component.get('v.actorId'),
                'fileName': file.name
            });
            action.setCallback(this, function(response){
                const state = response.getState();
                if(state === 'SUCCESS') {
                    const dataSubmission = response.getReturnValue();
                    if(! $A.util.isEmpty(dataSubmission)) {

                        let dataSubmissionId = dataSubmission.Id;
                        let externalActorId = '';
                        if(! $A.util.isEmpty(dataSubmission.External_Actor_Id__c)) {
                            externalActorId = dataSubmission.External_Actor_Id__c;
                        }
                        checkOnTimeSubmission(component, event, file, dataSubmissionId, externalActorId);

                    }else{
                        console.log('function uploadFile returned empty dataSubmissionId');
                        let errors = component.get('v.uploadedErrors');
                        errors.push({
                            dataSubmission : '',
                            fileName : file.name
                        });
                        component.set('v.uploadedErrors', errors);
                        component.set('v.uploadDone', true);
                    }
                }else{
                    console.log('uploadFile error');
                    let errors = component.get('v.uploadedErrors');
                    errors.push({
                        dataSubmission : '',
                        fileName : file.name
                    });
                    component.set('v.uploadedErrors', errors);
                    component.set('v.uploadDone', true);
                }

            });
            $A.enqueueAction(action);

        }

        function checkOnTimeSubmission(component, event, file, dataSubmissionId, externalActorId) {
            let action = component.get('c.isSubmissionOnTime');
            action.setParams({
                'actorId' : component.get('v.actorId')
            });
            action.setCallback(this, function(response){
                const state = response.getState();
                if(state === 'SUCCESS') {
                    const isOnTime = response.getReturnValue();
                    if(! $A.util.isEmpty(isOnTime)) {

                        createUploadFile(component, event, file, dataSubmissionId, !isOnTime, externalActorId);

                    }else{
                        console.log('function uploadFile returned empty uploadFile');
                        let errors = component.get('v.uploadedErrors');
                        errors.push({
                            dataSubmissionId : '',
                            fileName : file.name
                        });
                        component.set('v.uploadedErrors', errors);
                        component.set('v.uploadDone', true);

                    }
                }
            });
            $A.enqueueAction(action);
        }

        function createUploadFile(component, event, file, dataSubmissionId, isOutsidePeriod, externalActorId) {
            let action = component.get('c.createUploadFile');
            action.setParams({
                'dataSubmissionId' : dataSubmissionId,
                'credentialName' : component.get('v.credentialsName'),
                'contentType' : file.type,
                'fileName' : file.name,
                'userId' :component.get('v.userId'),
                'actorId' : externalActorId,
                'isOnTime' : isOutsidePeriod
            });
            action.setCallback(this, function(response){
            let state = response.getState();
                if(state === 'SUCCESS') {
                    let uploadFile = response.getReturnValue();

                    if(! $A.util.isEmpty(uploadFile)) {
                       let reader = new FileReader();
                       reader.readAsArrayBuffer(file);
                       reader.onload = function() {
                           let arrayBuffer = reader.result;
                           remoteFunctionPut(component, event, file, arrayBuffer, uploadFile);
                       };

                    }else{
                        console.log('function uploadFile returned empty uploadFile');
                        let errors = component.get('v.uploadedErrors');
                        errors.push({
                            dataSubmissionId : '',
                            fileName : file.name
                        });
                        component.set('v.uploadedErrors', errors);
                        component.set('v.uploadDone', true);
                    }

                }else{
                    console.log('function uploadFile error2');
                    let errors = component.get('v.uploadedErrors');
                    errors.push({
                        dataSubmissionId : '',
                        fileName : file.name
                    });
                    component.set('v.uploadedErrors', errors);
                    component.set('v.uploadDone', true);
                }
            });
            $A.enqueueAction(action);

        }


        function remoteFunctionPut(component, event, file, fileBody, uploadFile) {
            let amazonFilePath = uploadFile.endpoint + uploadFile.bucketName + '/' + uploadFile.fullFileNameEncoded;
            let successes = component.get('v.successfullyUploaded');
            let errors = component.get('v.uploadedErrors');

            let xhr = new XMLHttpRequest();

            if (!xhr.upload && window.Sarissa && window.Sarissa.originalXMLHttpRequest) {
                xhr = new Sarissa.originalXMLHttpRequest();
            }

            xhr.onreadystatechange = function () {
                if (this.readyState == 4) {

                    //fileCounter.value--;

                    let status = this.status;
                    if (status == 200) {
                        /*successful upload*/
                        successes.push({
                            dataSubmissionId : uploadFile.dataSubmissionId,
                            fileName : file.name
                        });
                        component.set('v.successfullyUploaded', successes);

                    } else {

                        /*upload with error*/
                        errors.push({
                            dataSubmissionId : uploadFile.dataSubmissionId,
                            fileName : file.name
                        });
                    }
                    /*upload done*/
                    if(--fileCounter.value === 0) {
                        console.log('upload done');
                        component.set('v.uploadDone', true);
                    }

                }
            };

            xhr.open("PUT", amazonFilePath);

            xhr.setRequestHeader("Cache-Control", "no-cache");
            xhr.setRequestHeader("Authorization", uploadFile.authorization);
            xhr.setRequestHeader("X-Amz-Date", uploadFile.timestamp);
            xhr.setRequestHeader("Content-Type", file.type + ';charset=UTF-8');
            xhr.setRequestHeader("x-amz-meta-submission", uploadFile.dataSubmissionId);
            xhr.setRequestHeader("x-amz-meta-filename", uploadFile.fileNameEncoded);
            xhr.setRequestHeader("x-amz-meta-user", uploadFile.userId);
            xhr.setRequestHeader("x-amz-meta-actor", uploadFile.actorId);
            xhr.setRequestHeader("x-amz-meta-outsideperiod", uploadFile.isOnTime);
            xhr.send(fileBody);

        }

        fileCounter.value = files.length;
        for(let i in files) {
            uploadFile(files[i], component, event);
        }

    },

    disableContent : function(component, event) {
        let content = component.find('content');
        $A.util.addClass(content, 'disable_content');
    },

    disableContentInternal : function(component, event) {
        let content = component.find('content_internal');
        content.getElement().classList.add('disable_content');
    },

    enableContentInternal : function(component, event) {
        let content = component.find('content_internal');
        content.getElement().classList.remove('disable_content');
    },




})