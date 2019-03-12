({

    aftersScriptsLoadedScript: function (component, event, helper) {
        jQuery("document").ready(function () {
            var fileInput = $("#file-field");

            fileInput.bind("change", function () {
                //startLoading();
                //uploadFiles(this.files, $('[id$=fileIdentifierPick]').val());
                //console.log(this.files);
                component.set("v.showLoadingSpinner", true);

                var isUploadingAttachment= component.get("v.isUploadingAttachments");
               
                if(isUploadingAttachment){
                    helper.uploadAttachments(component, this.files,helper);
                }else{
                    helper.uploadFiles(component, this.files, $('[id$=fileIdentifierPick]').val());
                }
            });
        });
    },

    doInit: function (component, event, helper) {

        var getFileIdentifierPickValuesAction = component.get("c.getFileIdentifierPickValues");
        getFileIdentifierPickValuesAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var fileIdentifierPickValues = response.getReturnValue();
                component.set("v.fileIdentifierPickValues", fileIdentifierPickValues);
            }
        });
        $A.enqueueAction(getFileIdentifierPickValuesAction);

        var getReviewStatusPickValuesAction = component.get("c.getReviewStatusPickValues");
        getReviewStatusPickValuesAction.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var reviewStatusPickValues = response.getReturnValue();
                component.set("v.reviewStatusPickValues", reviewStatusPickValues);
            }
        });
        $A.enqueueAction(getReviewStatusPickValuesAction);

        var parentId = component.get("v.recordId");
        //console.log(parentId);

        var isPortal = component.get("v.isPortal");
        //console.log(isPortal);

        var communityName = component.get("v.communityName");
        //console.log(communityName);

        var uploaderWizard = component.get("v.uploaderWizard");
        //console.log(uploaderWizard);

        //get this page properties and 
        var getPanelPropertiesAction = component.get("c.getPanelProperties");
        getPanelPropertiesAction.setParams({
            "parentId": parentId,
            "isPortal": isPortal,
            "communityName": communityName
        });
        getPanelPropertiesAction.setCallback(this, function (response1) {
            var state = response1.getState();
            if (state === "SUCCESS") {
                var panelProperties = response1.getReturnValue();
                console.log(panelProperties);
                component.set("v.panelProperties", panelProperties);

                var rowActions = helper.getRowActions.bind(this, component);

                var isSAAMorSIDRA = panelProperties.isSAAMorSIDRA;

                var columns = [];
                if (isSAAMorSIDRA && (uploaderWizard == 'AMS_File' || isPortal)) {
                    columns.push(
                        {
                            label: 'Review Status',
                            fieldName: 'reviewStatus',
                            type: 'text'
                        });
                }
                if (isSAAMorSIDRA && uploaderWizard == 'AMS_File') {
                    columns.push(
                        {
                            label: 'File Identifier',
                            fieldName: 'fileIdentifierPick',
                            type: 'text'
                        });
                }
                if (isSAAMorSIDRA && uploaderWizard == 'AMS_File') {
                    columns.push(
                        {
                            label: 'Source',
                            fieldName: 'source',
                            type: 'text'
                        });
                }
                if (!isPortal) {
                    columns.push(
                        {
                            label: 'Public',
                            fieldName: 'isPublic',
                            type: 'boolean'
                        });
                }
                columns.push(
                    {
                        label: 'Name',
                        fieldName: 'name',
                        type: 'text'
                    });
                if (isSAAMorSIDRA) {
                    columns.push(
                        {
                            label: 'File Identifier',
                            fieldName: 'fileIdentifierPick',
                            type: 'text'
                        });
                }
                columns.push(
                    {
                        label: 'Size',
                        fieldName: 'size',
                        type: 'text'
                    },
                    {
                        label: 'Created Date',
                        fieldName: 'createdDate',
                        type: 'date'
                    }
                );
                if (!isPortal) {
                    columns.push(
                        {
                            label: 'Created By',
                            fieldName: 'createdByName',
                            type: 'text'
                        });
                }
                if (isSAAMorSIDRA && panelProperties.showFileIdentifier) {
                    columns.push(
                        {
                            label: 'File Identifier',
                            fieldName: 'fileIdentifier',
                            type: 'text'
                        });
                }
                if (panelProperties.isAdminUser) {
                    columns.push(
                        {
                            label: 'Location',
                            fieldName: 'filetype',
                            type: 'text'
                        });
                }

                //push actions into columns
                columns.push(
                    {
                        type: 'action',
                        typeAttributes:
                        {
                            rowActions: rowActions
                        }
                    }
                );

                component.set("v.columns", columns);

                var col2s = [
                    {
                        label: 'Name',
                        fieldName: 'name',
                        type: 'text',
                        sortable: false
                    },
                    {
                        label: 'Size',
                        fieldName: 'size',
                        type: 'text',
                        sortable: false
                    },
                    {
                        label: 'Created Date',
                        fieldName: 'createdDate',
                        type: 'date'
                    }
                ];
                component.set("v.columnspopup", col2s);



                helper.helperGetAttachList(component);

            } else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response1.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }

        });
        $A.enqueueAction(getPanelPropertiesAction);



    },

    uploadFileButtonHandler: function (component, event, helper) {
        $("#file-field").click();
    },

    attachLineActionHandler: function (component, event, helper) {
        //var selectedMenuItemValues = event.getParam("value").split("-");
        //console.log(selectedMenuItemValues);
        var action = event.getParam('action').name;
        var row = event.getParam('row').id;
        console.log(action);
        console.log(row);

        var parentId = component.get("v.recordId");
        //console.log(parentId);
        var isPortal = component.get("v.isPortal");
        //console.log(isPortal);

        var isSAAMorSIDRA = component.get("v.panelProperties").isSAAMorSIDRA;
        //console.log(isSAAMorSIDRA);

        if (action == 'edit') {
            helper.attachLineEditAction(component, row, isPortal);
        }

        if (action == 'view') {
            helper.attachLineViewAction(component, row, event);
        }

        if (action == 'delete') {
            helper.attachLineDeleteAction(component, row);
        }

        if (action == 'makePublic') {
            component.set("v.showLoadingSpinner", true);
            helper.attachLineMakePrivatePublicAction(component, parentId, row, isPortal, isSAAMorSIDRA);
        }

        if (action == 'makePrivate') {
            component.set("v.showLoadingSpinner", true);
            helper.attachLineMakePrivatePublicAction(component, parentId, row, isPortal, isSAAMorSIDRA);
        }
    },

    makeAllAttachmentsPublicButtonHandler: function (component, event, helper) {
        var parentId = component.get("v.recordId");
        //console.log(parentId);
        var isPortal = component.get("v.isPortal");
        //console.log(isPortal);
        //makeAllAttachPublic(String parentId, Boolean isPortal){

        var isSAAMorSIDRA = component.get("v.panelProperties").isSAAMorSIDRA;
        //console.log(isSAAMorSIDRA);

        var makeAllAttachPublicAction = component.get("c.makeAllAttachPublic");
        makeAllAttachPublicAction.setParams({
            "parentId": parentId,
            "isPortal": isPortal,
            "isSAAMorSIDRA": isSAAMorSIDRA
        });
        makeAllAttachPublicAction.setCallback(this, function (response2) {
            var state = response2.getState();
            if (state === "SUCCESS") {
                if (response2.getReturnValue().severity === 'SUCCESS') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'dismissable',
                        title: response2.getReturnValue().severity,
                        message: 'Record updated',
                        type: 'success'
                    });
                    toastEvent.fire();

                    helper.helperGetAttachList(component);

                } else if (response2.getReturnValue().severity === 'ERROR') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'dismissable',
                        title: response2.getReturnValue().severity,
                        message: response2.getReturnValue().extraDetails,
                        type: 'error'
                    });
                    toastEvent.fire();
                }

            } else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response2.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(makeAllAttachPublicAction);
    },

    makeAllAttachmentsPrivateButtonHandler: function (component, event, helper) {
        var parentId = component.get("v.recordId");
        //console.log(parentId);
        var isPortal = component.get("v.isPortal");
        //console.log(isPortal);
        //makeAllAttachPrivate(String parentId, Boolean isPortal){

        var isSAAMorSIDRA = component.get("v.panelProperties").isSAAMorSIDRA;
        //console.log(isSAAMorSIDRA);

        var makeAllAttachPrivateAction = component.get("c.makeAllAttachPrivate");
        makeAllAttachPrivateAction.setParams({
            "parentId": parentId,
            "isPortal": isPortal,
            "isSAAMorSIDRA": isSAAMorSIDRA
        });
        makeAllAttachPrivateAction.setCallback(this, function (response2) {
            var state = response2.getState();
            if (state === "SUCCESS") {
                if (response2.getReturnValue().severity === 'SUCCESS') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'dismissable',
                        title: response2.getReturnValue().severity,
                        message: 'Record updated',
                        type: 'success'
                    });
                    toastEvent.fire();

                    helper.helperGetAttachList(component);

                } else if (response2.getReturnValue().severity === 'ERROR') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'dismissable',
                        title: response2.getReturnValue().severity,
                        message: response2.getReturnValue().extraDetails,
                        type: 'error'
                    });
                    toastEvent.fire();
                }

            } else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response2.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(makeAllAttachPrivateAction);
    },

    //Attachment Delete Popup methods
    handleCancelDeletePopup: function (component, event, helper) {
        component.set("v.handleCancelDeletePopup", false);
    },

    handleConfirmDeletePopup: function (component, event, helper) {
        var parentId = component.get("v.recordId");
        //console.log(parentId);
        var isPortal = component.get("v.isPortal");
        //console.log(isPortal);
        //makeAllAttachPrivate(String parentId, Boolean isPortal){

        var attachId = component.get("v.attachmentIdToDelete");
        var lstAttachments = component.get("v.lstAttachments");

        var attachFullName = '';

        for (var i = 0; i < lstAttachments.length; i++) {
            if (lstAttachments[i].id == attachId) {
                attachFullName = lstAttachments[i].fullName;
            }
        }
        //console.log(attachFullName);




        var deleteAttachmentAction = component.get("c.deleteAttachment");
        deleteAttachmentAction.setParams({
            "attachId": attachId,
            "fullName": attachFullName
        });
        deleteAttachmentAction.setCallback(this, function (response2) {
            component.set("v.viewDeleteAttachmentPopup", false);

            var state = response2.getState();
            if (state === "SUCCESS") {
                if (response2.getReturnValue().severity === 'SUCCESS') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'dismissable',
                        title: response2.getReturnValue().severity,
                        message: 'Attachment Deleted',
                        type: 'success'
                    });
                    toastEvent.fire();

                    helper.helperGetAttachList(component);

                } else if (response2.getReturnValue().severity === 'ERROR') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'dismissable',
                        title: response2.getReturnValue().severity,
                        message: response2.getReturnValue().extraDetails,
                        type: 'error'
                    });
                    toastEvent.fire();
                }

            } else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response2.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(deleteAttachmentAction);
    },

    //Attachment Delete Popup methods
    handleCancelEditPopup: function (component, event, helper) {
        component.set("v.viewEditAttachmentPopup", false);
        component.set("v.transferAttachmentsPopup", false);
    },

    handleConfirmEditPopup: function (component, event, helper) {
        var parentId = component.get("v.recordId");
        //console.log(parentId);
        var isPortal = component.get("v.isPortal");
        //console.log(isPortal);
        //updateAttachment(String parentId, String attachId, Boolean isPortal, String description, String fileIdentifier, String reviewStatus)

        //var attachId = component.get("v.attachmentIdToDelete");

        var editAttachment = component.get("v.editAttachment");
        //console.log(editAttachment);

        var description = null;
        if (editAttachment.fileAmazon.amazonFile.Description__c) {
            description = editAttachment.fileAmazon.amazonFile.Description__c;
        }
        var fileIdentifier = null;
        if (editAttachment.fileAmazon.amazonFile.File_Identifier_picklist__c) {
            fileIdentifier = editAttachment.fileAmazon.amazonFile.File_Identifier_picklist__c;
        }
        var reviewStatus = null;
        if (editAttachment.fileAmazon.amazonFile.Review_Status__c) {
            reviewStatus = editAttachment.fileAmazon.amazonFile.Review_Status__c;
        }
        //console.log(description);
        //console.log(fileIdentifier);
        //console.log(reviewStatus);

        var attachId = editAttachment.id;
        var isSAAMorSIDRA= component.get("v.panelProperties").isSAAMorSIDRA;
        var updateAttachmentAction = component.get("c.updateAttachment");
        updateAttachmentAction.setParams({
            "parentId": parentId,
            "attachId": attachId,
            "isPortal": isPortal,
            "description": description,
            "fileIdentifier": fileIdentifier,
            "reviewStatus": reviewStatus,
            "isSAAMorSIDRA":isSAAMorSIDRA

        });
        updateAttachmentAction.setCallback(this, function (response2) {
            component.set("v.viewEditAttachmentPopup", false);

            var state = response2.getState();
            if (state === "SUCCESS") {
                if (response2.getReturnValue().severity === 'SUCCESS') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'dismissable',
                        title: response2.getReturnValue().severity,
                        message: 'Attachment Deleted',
                        type: 'success'
                    });
                    toastEvent.fire();

                    helper.helperGetAttachList(component);

                } else if (response2.getReturnValue().severity === 'ERROR') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'dismissable',
                        title: response2.getReturnValue().severity,
                        message: response2.getReturnValue().extraDetails,
                        type: 'error'
                    });
                    toastEvent.fire();
                }

            } else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response2.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(updateAttachmentAction);
    },

    downloadAllFilesButtonHandler: function (component, event, helper) {
        var parentId = component.get("v.recordId");
        //console.log(parentId);

        var isPortal = component.get("v.isPortal");
        //console.log(isPortal);

        //getAllExpiringLink(String objectId, Boolean isPortal)
        var getAllExpiringLinkAction = component.get("c.getAllExpiringLink");
        getAllExpiringLinkAction.setParams({
            "objectId": parentId,
            "isPortal": isPortal
        });
        getAllExpiringLinkAction.setCallback(this, function (response2) {
            var state = response2.getState();
            if (state === "SUCCESS") {
                //var zipfiles = new ZipFiles(response2.getReturnValue(), "files.zip");
                //zipfiles.downloadZip();
                helper.helperCreateZip(response2.getReturnValue(), "files.zip");


            } else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response2.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(getAllExpiringLinkAction);

    },

    transferAttachmentsButtonHandler: function (component, event, helper) {
        var parentId = component.get("v.panelProperties").relatedCase.ParentId;
        var caseId = component.get("v.recordId");

        //get related Cases
        var getRelatedCasestAction = component.get("c.getParentCaseRelatedCases");
        getRelatedCasestAction.setParams({
            "parentId": parentId,
            "caseId": caseId
        });
        getRelatedCasestAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var lstcases = response.getReturnValue();
                console.log(lstcases);

                lstcases.forEach(function(elem){
                    console.log(elem.CaseRecord.RecordTypeId);
               
                    elem.caseNumber=elem.CaseRecord.CaseNumber,
                    elem.subject=elem.CaseRecord.Subject,
                    elem.status=elem.CaseRecord.Status,
                    elem.recordType=elem.CaseRecord.RecordType.Name
                   
                });
                component.set("v.relatedCaseList",lstcases);

                var cols=[
                    {
                        label: 'Relationship',
                        fieldName: 'strRelationship',
                        type: 'text'
                    },
                    {
                        label: 'Case Number',
                        fieldName: 'caseNumber',
                        type: 'text'
                    },
                    {
                        label: 'Subject',
                        fieldName: 'subject',
                        type: 'text'
                    },
                    {
                        label: 'Status',
                        fieldName: 'status',
                        type: 'text'
                    },
                    {
                        label: 'Record Type',
                        fieldName: 'recordType',
                        type: 'text'
                    }
                ];
                
                component.set("v.columnscasepopup",cols);
            } else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }

        });

        $A.enqueueAction(getRelatedCasestAction);


        component.set("v.transferAttachmentsPopup", true);

    },
    updateSelectedFilesToTransfer: function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        component.set("v.selectedRowsToTransfer", event.getParam("selectedRows"));
    },

    updateSelectedCasesToTransfer: function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        component.set("v.selectedRowsCaseToTransfer", event.getParam("selectedRows"));
    },

    submitTransferAttachments: function (component, event, helper) {

        var selectedRows = component.get("v.selectedRowsToTransfer");
        var selectedcaseRows = component.get("v.selectedRowsCaseToTransfer");
        var targetCase = component.find('targetCasefld').get("v.value");
        var parentId = component.get("v.recordId");
        var isPortal = component.get("v.isPortal");
        var isSAAMorSIDRA = component.get("v.panelProperties").isSAAMorSIDRA;
        var caseParentId = component.get("v.panelProperties").relatedCase.ParentId;

        var selectedAttchList = [];

        selectedRows.forEach(function (el) {
            selectedAttchList.push(el.id);
        });

        var selectedCaseList = [];
        selectedcaseRows.forEach(function (el) {
            selectedCaseList.push(el.CaseRecord.Id);
        });

        var transferAttachmentAction = component.get("c.transferAttachments");
        transferAttachmentAction.setParams({
            "parentId": parentId,
            "selIdAttachmentStr": JSON.stringify(selectedAttchList),
            "targetCaseStr": JSON.stringify(selectedCaseList),
            "isPortal": isPortal,
            "isSAAMorSIDRA": isSAAMorSIDRA,
            "caseParentId": caseParentId,
            "targetSingleCase":targetCase
        });
        
        component.set("v.showPopupLoader", true);
        transferAttachmentAction.setCallback(this, function (response2) {
            var state = response2.getState();
            if (state === "SUCCESS") {
               var resp=response2.getReturnValue();
               console.log(resp);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'dismissable',
                       title: resp.isSuccess?'Success':'Warning',
                        message: resp.errorMsg==''?'Success':resp.errorMsg,
                        type:resp.isSuccess?'success':'error'

                    });
                    toastEvent.fire();
                    component.set("v.showPopupLoader", false);
                    if (resp.isSuccess)
                        component.set("v.transferAttachmentsPopup", false);



            } else if (state === "INCOMPLETE") {
              
            }
            else if (state === "ERROR") {
              
                var errors = response2.getError();
                var msg='';
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        msg=errors[0].message;
                    }
                } else {
                    msg="Internal Error. Please Contact the Admin.";
                }

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'dismissable',
                    title: 'Error',
                    message: msg,
                    type:'error'

                });
                toastEvent.fire();

               
            }
        });
        $A.enqueueAction(transferAttachmentAction);


    },
    doneUploadFiles: function (component, event, helper) {
        var doneUploading = event.getParam("value");
        if (doneUploading) {
            component.set("v.doneUploading", false);
            helper.helperGetAttachList(component);
        }
    },

    uploadFileNonSAAMSIDRAButtonHandler: function (component, event, helper) {
      
        component.set("v.isUploadingAttachments",true);
        $("#file-field").click();
    },
    
})