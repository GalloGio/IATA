import saveAttachmentApex from '@salesforce/apex/IGOMAttachmentUtil.saveAttachment';
import getPermissionsApex from '@salesforce/apex/IGOMPermissions.getPermissions';

const chunkedUpload = async (file, parentId) => {
    // Apex calls
    const uploadChunk = (chunk, fileId) => saveAttachmentApex({
        parentId: parentId, 
        fileName: file.name, 
        contentType: file.type, 
        fileId: fileId, 
        base64data: chunk
    });
    // Utility function
    const readFileAsBase64 = (fileObject) => {
        return new Promise((resolve, reject) => {
            const fileReader = new FileReader();
            fileReader.onerror = reject;
            fileReader.onload = () => {
                const fileContents = fileReader.result;
                const base64String = 'base64,';
                const dataStart = fileContents.indexOf(base64String) + base64String.length;
                resolve(fileContents.substring(dataStart));
            };
            fileReader.readAsDataURL(fileObject);
        })
    }
    // Constants for size control
    const CHUNK_SIZE = 750000;
    const MAX_FILE_SIZE = 4500000;
    // Check the file size
    if (file.size > MAX_FILE_SIZE) {
        throw new Error('Maximum file size of 4.5MB exceeded');
    }
    // Read the file as base64
    const fileContents = await readFileAsBase64(file);
    // Send the file in chunks
    let startPosition = 0;
    let endPosition = Math.min(fileContents.length, startPosition + CHUNK_SIZE);
    const fileId = await uploadChunk(fileContents.substring(startPosition, endPosition));
    while (endPosition !== fileContents.length) {
        startPosition = endPosition;
        endPosition = Math.min(fileContents.length, startPosition + CHUNK_SIZE); 
        await uploadChunk(fileContents.substring(startPosition, endPosition), fileId);
    } 
    return fileId;
}

const flattenByProperty = (targetObject, getListFromObject) => {
    const getFlattenProperty = (section, partialList) => {
        if (getListFromObject(section) && getListFromObject(section).length > 0) {
            getListFromObject(section).forEach(item => partialList = getFlattenProperty(item, partialList))
        } else {
            partialList.push(section);
        }
        return partialList;
    }
    return getFlattenProperty(targetObject, []);
}

const permissions = (() => {
    
    let loadedPermissions;

    const loadPermissions = async (stationId) => {
        loadedPermissions = await getPermissionsApex({
            stationId: stationId
        });
        return;
    };

    const hasPermission = (permission) => {
        if (loadedPermissions === undefined) {
            throw new Error(`No permissions loaded`);
        } else if (loadedPermissions[permission] === undefined) {
            throw new Error(`No permission named "${permission}" was loaded`);
        } else {
            return loadedPermissions[permission];
        }
    };

    return {
        load: loadPermissions,
        has: hasPermission
    };

})();

const util = {
    chunkedUpload: chunkedUpload,
    flattenArrayByProperty: flattenByProperty,
    permissions: permissions,
};

export { util }