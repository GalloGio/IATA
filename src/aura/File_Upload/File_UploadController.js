({

    doInit : function(component, event, helper) {
        helper.getSettings(component, event);
    },

    dragover : function(component, event, helper) {
        var eventType = event.type;
        helper.handleDrag(component, event);
    },

    dragenter : function(component, event, helper) {
        helper.handleDrag(component, event);
    },

    dragleave : function(component, event, helper) {
        helper.handleDragLeave(component, event);
    },

    dragend : function(component, event, helper) {
        helper.handleDragEnd(component, event);
    },

    drop : function(component, event, helper) {
        event.preventDefault();
        event.stopPropagation();
        helper.handleDrop(component, event);
    },

    chooseFile : function(component, event) {
        document.getElementById('fileInput').click();
    },

    handleInput : function(component, event, helper) {
        helper.handleFileInput(component, event);
    },

    removeFile : function(component, event, helper) {
        helper.handleRemoveFile(component, event);
    },

    submitFile : function(component, event, helper) {
        var files = component.get('v.files');
        if(files && files.length > 0) {
            helper.toggleSpinner(component);
            helper.checkContactAndActor(component, event, files);

        }
    },

    changeActor : function(component, event, helper) {
        helper.handleActorChange(component, event);
    },

    handleSelectedUser : function(component, event, helper) {
        let selectedContactId = event.getParam('sObjectId');
        if(! $A.util.isEmpty(selectedContactId)) {
          helper.fetchUserFromContact(component, event, selectedContactId);
        }
    },

    clearSelectedUser : function(component, event, helper) {
        let userId = component.get('v.userId');
        userId = '';
        component.set('v.userId', userId);

        let actorId = component.get('v.actorId');
        actorId = '';
        component.set('v.actorId', actorId);

        let actors = component.get('v.actors');
        actors = [];
        component.set('v.actors', actors);
        helper.enableContentInternal(component, event);
    },

    finishUpload : function(component, event, helper) {
        let status = event.getParam('value');
        if(status === true) {
            component.set('v.uploadDone', false);
            let successes = component.get('v.successfullyUploaded');
            let errors = component.get('v.uploadedErrors');
            helper.displayUploadMessages(component, event, successes, errors);
        }

    },

})