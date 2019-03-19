({
    uploadFiles: function (component, files, fileIdentifierPick) {
        var panelProperties = component.get("v.panelProperties");
        var parentId = component.get("v.recordId");
        var uploaderWizard = component.get("v.uploaderWizard");
        var sourceSystem = component.get("v.sourceSystem");

        var fileCounter = {
            value: 0,
            reset: function (val) { value = val; },
            //increase: function() { value++; },
            //decrease: function() { value--; },
            refreshIfEmpty: function () {
                value--;
                if (value == 0) refreshList();
            }
        }
       
        function uploadFile(file, fileIdentifierPick, component) {

            var notifyOwner = $("#notifyOwner:checked");
          
            var createUploadFileAction = component.get("c.createUploadFile");
            createUploadFileAction.setParams({
                "id": parentId,
                "filenameupload": file.name,
                "contentType": file.type,
                "filesize": file.size,
                "folder": panelProperties.amazonPath,
                "credentialName": panelProperties.credentialName
            });
            createUploadFileAction.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var responseValue = response.getReturnValue();
                    if (!responseValue.isSuccess) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'dismissable',
                            title: 'ERROR',
                            message: responseValue.errorMessage,
                            type: 'error'
                        });
                        toastEvent.fire();
                    } else {

                        var amazonCredentials = responseValue;
                        var reader = new FileReader();
                        reader.readAsArrayBuffer(file);
                        reader.onload = function (e) {
                            var arrayBuffer = reader.result;
                            remoteFunctionPut(amazonCredentials, file, reader.result, fileIdentifierPick, component);
                        };

                  
                    }

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
            $A.enqueueAction(createUploadFileAction);

        }

        function remoteFunctionPut(amazonCredentials, file, fileBody, fileIdentifierPick, component) {
            var amazonFilePath = amazonCredentials.endpoint + amazonCredentials.bucketName + '/' + amazonCredentials.fullFileNameEncoded;
            
            //var progressBar;

            var xhr = new XMLHttpRequest();

            // salesforce overrides original XMLHttpRequest in IE
            if (!xhr.upload && window.Sarissa && window.Sarissa.originalXMLHttpRequest) {
                xhr = new Sarissa.originalXMLHttpRequest();
            }

            xhr.onreadystatechange = function () {
                if (this.readyState == 4) {
                    //fileCounter.refreshIfEmpty(); /* AMSU-135 commented */

                    var status = this.status;
                    if (status == 200) {
                        ////progressUpload(100, this.progressBar);
                        //uploadFile(file);
                    } else {
                        if (this.responseText) {
                            getResponseFromXML(this.responseText);
                            //uploadFile(file);
                        } else {
                            var message = '';
                            if (this.statusText) {
                                message = 'Status: ' + this.status + '. Error: ' + this.statusText;
                            }
                            else if (this.responseText) {
                                message = 'Status: ' + this.status + '. Error: ' + this.responseText;
                            }
                            else {
                                message = 'Status:' + this.status + '. Error: Unknown error.';
                            }
                        }
                    }
                }
            };

            xhr.open("PUT", amazonFilePath);

            xhr.setRequestHeader("Cache-Control", "no-cache");
            xhr.setRequestHeader("Authorization", amazonCredentials.authorization);
            xhr.setRequestHeader("X-Amz-Date", amazonCredentials.timestamp);
            xhr.setRequestHeader("Content-Type", file.type + ';charset=UTF-8');

            xhr.send(fileBody);

            callToCreateAmazonFileObject(file, amazonCredentials.fullFileName, fileIdentifierPick, component);
        }

        function getResponseFromXML(response) {
            parser = new DOMParser();
            var xmlDoc = parser.parseFromString(response, "text/xml");
            if (xmlDoc.getElementsByTagName("Message")[0].childNodes[0].nodeValue) {
                alert('Error. Message from Amazon S3: ' + xmlDoc.getElementsByTagName("Message")[0].childNodes[0].nodeValue);
                stopLoading();
            }
        }

        function callToCreateAmazonFileObject(file, path, fileIdentifierPick, component) {
            if (fileIdentifierPick == null) {
                fileIdentifierPick = '';
            }

            //path, file.size,"{!sobjectId}", "{!uploader}", fileIdentifierPick, "{!source}"
            //(String amazonKey, Long filesize, String parentId, String recordType, String fileIdentifierPick, String source)
            var createAmazonFileObjectAction = component.get("c.createAmazonFileObject");
            createAmazonFileObjectAction.setParams({
                "amazonKey": path,
                "filesize": file.size,
                "parentId": parentId,
                "recordType": uploaderWizard,
                "fileIdentifierPick": fileIdentifierPick,
                "source": sourceSystem
            });
            createAmazonFileObjectAction.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var responseValue = response.getReturnValue();
                    
                    //fileCounter.refreshIfEmpty();
                    fileCounter.value = fileCounter.value - 1;
                    if (fileCounter.value == 0) {
                        //this.helperGetAttachList(component);

                        component.set("v.doneUploading", true);

                    }
                    //this.helperGetAttachList(component);

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
            $A.enqueueAction(createAmazonFileObjectAction);
        }


        fileCounter.value = files.length;
        $.each(files, function (i, file) {
            uploadFile(file, fileIdentifierPick, component);
        });
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
               

                lstcases.forEach(function(elem){
                                 
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

    makeAllAttachmentsPublicButtonHandler: function (component, event, helper) {
        var parentId = component.get("v.recordId");
        var isPortal = component.get("v.isPortal");

        var isSAAMorSIDRA = component.get("v.panelProperties").isSAAMorSIDRA;

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
        var isPortal = component.get("v.isPortal");

        var isSAAMorSIDRA = component.get("v.panelProperties").isSAAMorSIDRA;

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
    downloadAllFilesButtonHandler: function (component, event, helper) {
        var parentId = component.get("v.recordId");

        var isPortal = component.get("v.isPortal");

        var getAllExpiringLinkAction = component.get("c.getAllExpiringLink");
        getAllExpiringLinkAction.setParams({
            "objectId": parentId,
            "isPortal": isPortal
        });
        getAllExpiringLinkAction.setCallback(this, function (response2) {
            var state = response2.getState();
            if (state === "SUCCESS") {
                helper.helperCreateZip(response2.getReturnValue(), "files.zip");


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


    getRowActions: function (component, row, doneCallback) {
        var isPortal = component.get("v.isPortal");
        var isSAAMorSIDRA = component.get("v.panelProperties").isSAAMorSIDRA;

        //create actions
        var actions = [];
        if (!isPortal) {
            actions.push(
                {
                    'label': 'Edit',
                    'name': 'edit'
                }
            );
        }
        actions.push(
            {
                'label': 'View',
                'name': 'view'
            });
        if (!isPortal) {
            actions.push(
                {
                    'label': 'Delete',
                    'name': 'delete'
                }
            );
        }
        if (!isPortal && row['filetype'] != 'Archived') {
            if (row['isPublic']) {
                actions.push({
                    'label': 'Make Private',
                    'name': 'makePrivate'
                });
            } else {
                actions.push({
                    'label': 'Make Public',
                    'name': 'makePublic'
                });
            }
        }

        doneCallback(actions);
    },

    helperCreateZip: function (listFiles, zipFileName) {

        //used to download the zip from the attachments. 
        //these are the resources from jszip folder responsible for the creation of 
        //the zip that have to be here because "lightning"


        this.listFiles = listFiles;
        this.zipFileName = zipFileName;

        function checkLastFile() {
            for (var i = 0; i < listFiles.length; i++) {
                var file = listFiles[i];
                if (file.status == undefined) {
                    return;
                }
            }
            // check all status codes OK
            for (var i = 0; i < listFiles.length; i++) {
                var file = listFiles[i];
                if (file.error == "ERROR") {
                    alert("File download error");
                    return;
                }
            }
            zipFiles(listFiles, zipFileName);
        }

        function getFileBlob(file) {
            JSZipUtils.getBinaryContent(file.url, function (err, data) {
                if (err) {
                    file.status = "ERROR";;
                } else {
                    file.status = "OK";
                }
                file.blob = data;
                file.type = "blob";
                checkLastFile();
            });
        }

        function zipFiles(files, zipName) {
            var zip = new JSZip();
            for (var i = 0; i < files.length; i++) {
                var file = files[i];
                if (file.type == "blob") {
                    zip.file(file.name, file.blob);
                    file.blob = ""; // free memory
                }
                if (file.type == "base64") {
                    zip.file(file.name, file.data, { base64: true });
                    file.data = ""; // free memory
                }
            }
            zip.generateAsync({ type: "blob" })
                .then(function (blob) {
                    saveAs(blob, zipName);
                    listFiles = new Array(); // free memory
                });
        }

        var saveAs = saveAs || (function (view) {
            "use strict";
            // IE <10 is explicitly unsupported
            if (typeof view === "undefined" || typeof navigator !== "undefined" && /MSIE [1-9]\./.test(navigator.userAgent)) {
                return;
            }
            var
                doc = view.document
                // only get URL when necessary in case Blob.js hasn't overridden it yet
                , get_URL = function () {
                    return view.URL || view.webkitURL || view;
                }
                , save_link = doc.createElementNS("http://www.w3.org/1999/xhtml", "a")
                , can_use_save_link = "download" in save_link
                , click = function (node) {
                    var event = new MouseEvent("click");
                    node.dispatchEvent(event);
                }
                , is_safari = /constructor/i.test(view.HTMLElement) || view.safari
                , is_chrome_ios = /CriOS\/[\d]+/.test(navigator.userAgent)
                , throw_outside = function (ex) {
                    (view.setImmediate || view.setTimeout)(function () {
                        throw ex;
                    }, 0);
                }
                , force_saveable_type = "application/octet-stream"
                // the Blob API is fundamentally broken as there is no "downloadfinished" event to subscribe to
                , arbitrary_revoke_timeout = 1000 * 40 // in ms
                , revoke = function (file) {
                    var revoker = function () {
                        if (typeof file === "string") { // file is an object URL
                            get_URL().revokeObjectURL(file);
                        } else { // file is a File
                            file.remove();
                        }
                    };
                    setTimeout(revoker, arbitrary_revoke_timeout);
                }
                , dispatch = function (filesaver, event_types, event) {
                    event_types = [].concat(event_types);
                    var i = event_types.length;
                    while (i--) {
                        var listener = filesaver["on" + event_types[i]];
                        if (typeof listener === "function") {
                            try {
                                listener.call(filesaver, event || filesaver);
                            } catch (ex) {
                                throw_outside(ex);
                            }
                        }
                    }
                }
                , auto_bom = function (blob) {
                    // prepend BOM for UTF-8 XML and text/* types (including HTML)
                    // note: your browser will automatically convert UTF-16 U+FEFF to EF BB BF
                    if (/^\s*(?:text\/\S*|application\/xml|\S*\/\S*\+xml)\s*;.*charset\s*=\s*utf-8/i.test(blob.type)) {
                        return new Blob([String.fromCharCode(0xFEFF), blob], { type: blob.type });
                    }
                    return blob;
                }
                , FileSaver = function (blob, name, no_auto_bom) {
                    if (!no_auto_bom) {
                        blob = auto_bom(blob);
                    }
                    // First try a.download, then web filesystem, then object URLs
                    var
                        filesaver = this
                        , type = blob.type
                        , force = type === force_saveable_type
                        , object_url
                        , dispatch_all = function () {
                            dispatch(filesaver, "writestart progress write writeend".split(" "));
                        }
                        // on any filesys errors revert to saving with object URLs
                        , fs_error = function () {
                            if ((is_chrome_ios || (force && is_safari)) && view.FileReader) {
                                // Safari doesn't allow downloading of blob urls
                                var reader = new FileReader();
                                reader.onloadend = function () {
                                    var url = is_chrome_ios ? reader.result : reader.result.replace(/^data:[^;]*;/, 'data:attachment/file;');
                                    var popup = view.open(url, '_blank');
                                    if (!popup) view.location.href = url;
                                    url = undefined; // release reference before dispatching
                                    filesaver.readyState = filesaver.DONE;
                                    dispatch_all();
                                };
                                reader.readAsDataURL(blob);
                                filesaver.readyState = filesaver.INIT;
                                return;
                            }
                            // don't create more object URLs than needed
                            if (!object_url) {
                                object_url = get_URL().createObjectURL(blob);
                            }
                            if (force) {
                                view.location.href = object_url;
                            } else {
                                var opened = view.open(object_url, "_blank");
                                if (!opened) {
                                    // Apple does not allow window.open, see https://developer.apple.com/library/safari/documentation/Tools/Conceptual/SafariExtensionGuide/WorkingwithWindowsandTabs/WorkingwithWindowsandTabs.html
                                    view.location.href = object_url;
                                }
                            }
                            filesaver.readyState = filesaver.DONE;
                            dispatch_all();
                            revoke(object_url);
                        }
                        ;
                    filesaver.readyState = filesaver.INIT;

                    if (can_use_save_link) {
                        object_url = get_URL().createObjectURL(blob);
                        setTimeout(function () {
                            save_link.href = object_url;
                            save_link.download = name;
                            click(save_link);
                            dispatch_all();
                            revoke(object_url);
                            filesaver.readyState = filesaver.DONE;
                        });
                        return;
                    }

                    fs_error();
                }
                , FS_proto = FileSaver.prototype
                , saveAs = function (blob, name, no_auto_bom) {
                    return new FileSaver(blob, name || blob.name || "download", no_auto_bom);
                }
                ;
            // IE 10+ (native saveAs)
            if (typeof navigator !== "undefined" && navigator.msSaveOrOpenBlob) {
                return function (blob, name, no_auto_bom) {
                    name = name || blob.name || "download";

                    if (!no_auto_bom) {
                        blob = auto_bom(blob);
                    }
                    return navigator.msSaveOrOpenBlob(blob, name);
                };
            }

            FS_proto.abort = function () { };
            FS_proto.readyState = FS_proto.INIT = 0;
            FS_proto.WRITING = 1;
            FS_proto.DONE = 2;

            FS_proto.error =
                FS_proto.onwritestart =
                FS_proto.onprogress =
                FS_proto.onwrite =
                FS_proto.onabort =
                FS_proto.onerror =
                FS_proto.onwriteend =
                null;

            return saveAs;
        }(
            typeof self !== "undefined" && self
            || typeof window !== "undefined" && window
            || this.content
        ));
        // `self` is undefined in Firefox for Android content script context
        // while `this` is nsIContentFrameMessageManager
        // with an attribute `content` that corresponds to the window

        if (typeof module !== "undefined" && module.exports) {
            module.exports.saveAs = saveAs;
        } else if ((typeof define !== "undefined" && define !== null) && (define.amd !== null)) {
            define("FileSaver.js", function () {
                return saveAs;
            });
        }

        for (var i = 0; i < this.listFiles.length; i++) {
            var file = this.listFiles[i];
            if (file.data === undefined || file.data == "") {
                getFileBlob(file);
            } else {
                // file already in data field
                file.type = "base64";
                file.status = "OK";
                checkLastFile();
            }
        }
    },

    helperGetAttachList: function (component) {

        var parentId = component.get("v.recordId");
        var isPortal = component.get("v.isPortal");
        var isSAAMorSIDRA = component.get("v.panelProperties").isSAAMorSIDRA;

        //get this page properties
        var getLstAttachmentsAction = component.get("c.getAllAttachmentsByParentIdAndPortal");
        getLstAttachmentsAction.setParams({
            "parentId": parentId,
            "isPortal": isPortal,
            "isSAAMorSIDRA": isSAAMorSIDRA
        });
        getLstAttachmentsAction.setCallback(this, function (response2) {
            var state = response2.getState();
            if (state === "SUCCESS") {
                var lstCases = response2.getReturnValue();
                if (lstCases) {

                    for (var i = 0; i < lstCases.length; i++) {
                        lstCases[i].size = lstCases[i].size.toFixed(2) + 'MB';
                    }

                    component.set("v.lstAttachments", lstCases);
                    component.set("v.lstAttachmentsLength", lstCases.length);

                    component.set("v.showLoadingSpinner", false);
                }
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
        $A.enqueueAction(getLstAttachmentsAction);

    },

    attachLineEditAction: function (component, attachId, isPortal) {
        var attachAux = null;

        var lstAttachments = component.get("v.lstAttachments");
        for (var i = 0; i < lstAttachments.length; i++) {
            if (lstAttachments[i].id == attachId) {
                attachAux = lstAttachments[i];
            }
        }
        component.set("v.editAttachment", attachAux);
        component.set("v.viewEditAttachmentPopup", true);

    },

    attachLineEditActionRedirect: function (component, attachId, event) {
        var getExpiringLinkAction = component.get("c.getExpiringLink");
        getExpiringLinkAction.setParams({
            "fileName": fullName
        });
        getExpiringLinkAction.setCallback(this, function (response1) {
            var state = response1.getState();
            if (state === "SUCCESS") {
                var link = response1.getReturnValue().replace("&amp;", "&");

                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": link
                });
                urlEvent.fire();
            }
        });
        $A.enqueueAction(getExpiringLinkAction);
    },

    attachLineViewAction: function (component, attachId, event) {
        var isAmazon = false;
        var fullName = '';

        var lstAttachments = component.get("v.lstAttachments");
        for (var i = 0; i < lstAttachments.length; i++) {
            if (lstAttachments[i].id == attachId && lstAttachments[i].filetype == 'Amazon') {
                isAmazon = true;
                fullName = lstAttachments[i].fullName;
            }
        }

        if (isAmazon) {
            var getExpiringLinkAction = component.get("c.getExpiringLink");
            getExpiringLinkAction.setParams({
                "fileName": fullName
            });
            getExpiringLinkAction.setCallback(this, function (response1) {
                var state = response1.getState();
                if (state === "SUCCESS") {
                    var link = response1.getReturnValue().replace("&amp;", "&");

                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": link
                    });
                    urlEvent.fire();
                }
            });
            $A.enqueueAction(getExpiringLinkAction);
        } else {
            var link = "/servlet/servlet.FileDownload?file=" + attachId;

            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": link
            });
            urlEvent.fire();
        }

    },

    attachLineDeleteAction: function (component, attachId) {
        component.set("v.attachmentIdToDelete", attachId);
        component.set("v.viewDeleteAttachmentPopup", true);
    },

    attachLineMakePrivatePublicAction: function (component, parentId, attachId, isPortal, isSAAMorSIDRA) {
        var changeAttachVisibilityAction = component.get("c.changeAttachVisibility");
        changeAttachVisibilityAction.setParams({
            "parentId": parentId,
            "attachId": attachId,
            "isPortal": isPortal,
            "isSAAMorSIDRA": isSAAMorSIDRA
        });
        changeAttachVisibilityAction.setCallback(this, function (response2) {
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

                    this.helperGetAttachList(component);

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
            component.set("v.showLoadingSpinner", false);
        }
        );
        $A.enqueueAction(changeAttachVisibilityAction);
    },
    uploadAttachments: function (component, files, helper) {
        var parentId = component.get("v.recordId");

        var fileCounter = {
            value: 0,
            reset: function (val) { value = val; },
            refreshIfEmpty: function () {
                value--;
                if (value == 0) refreshList();
            }
        }



        function uploadFile(file, component) {

            var createAttachmentAction = component.get("c.createAttachment");

            if (file.size > 3000000) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'dismissable',
                    title: 'ERROR',
                    message: 'File Max size 3Mb',
                    type: 'error'
                });
                toastEvent.fire();

                fileCounter.value = fileCounter.value - 1;
                if (fileCounter.value == 0) {
                    helper.helperGetAttachList(component);
                }

            } else {
                var reader = new FileReader();
                reader.readAsBinaryString(file);
                reader.onload = function (e) {
                    var arrayBuffer = reader.result;
                    createAttachmentAction.setParams({
                        "parentId": parentId,
                        "body": btoa(arrayBuffer),
                        "name": file.name,
                        "contentType": file.type,
                        "filesize": file.size
                    });

                    createAttachmentAction.setCallback(this, function (response) {
                        var state = response.getState();
                        var resp = response.getReturnValue();
                        if (state === "SUCCESS") {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                mode: 'dismissable',
                                title: resp.isSuccess ? 'Success' : 'Warning',
                                message: resp.errorMsg == '' ? 'File Uploaded with Success!' : resp.errorMsg,
                                type: resp.isSuccess ? 'success' : 'error'

                            });
                            toastEvent.fire();

                        } 
                        else if (state === "ERROR") {
                            var errors = response.getError();
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        mode: 'dismissable',
                                        title: 'ERROR',
                                        message: 'Unexpected Error. Please Contact the Administrator',
                                        type: 'error'
                                    });
                                    toastEvent.fire();
                                }
                            } else {
                                console.log("Unknown error");
                            }
                        }

                        fileCounter.value = fileCounter.value - 1;
                        if (fileCounter.value == 0) {
                            helper.helperGetAttachList(component);
                        }
                    }
                    );
                    $A.enqueueAction(createAttachmentAction);
                }
            }
        }
        fileCounter.value = files.length;
        $.each(files, function (i, file) {
            uploadFile(file, component);
        });

    }

})