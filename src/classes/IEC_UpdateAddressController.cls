/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Controller for VF page "IEC_UpdateAddress"
****************************************************************************************************/
global without sharing class IEC_UpdateAddressController extends IEC_PageController
{

public Map<String, String> labels { get; set; }  //*** labels & messages
public String msgConfirmDelete { get; set; }     //*** need a variable for message of delete confirmation because technical issue

Id currentBillToLocationId;
public Address_DTO dtoBillToAddress { get; set; }
public List<SelectOption> lstBillToState { get; set; }
public Boolean showBillToZip { get; set; }
public Boolean showBillToVAT { get; set; }

public Id currentShipToLocationId { get; set; }
public Address_DTO dtoShipToAddress { get; set; }
public List<SelectOption> lstShipToState { get; set; }
public Boolean showShipToZip { get; set; }
public Boolean showShipToVAT { get; set; }
public Boolean showShipToDelete { get; set; }
public List<SelectOption> lstShipToAddress { get; set; }
public Boolean isDefaultShipTo { get; set; }
public Boolean makeShipToDefault { get; set; }

Set<String> setCountryWithZip = new Set<String>();   //*** set of countries requiring entry of zip/postal code
Set<String> setCountryWithVAT = new Set<String>();   //*** set of countries having VAT number to be enterred

public List<SelectOption> lstCountry { get; set; }
public String autocompleteFullAddress { get; set; }

Contact currentContact;


/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Initialize controller
****************************************************************************************************/
public IEC_UpdateAddressController()
{
    labels = Utility.buildMapFromString(Label.IEC_UpdateAddress_Labels1 + '\n' + Label.IEC_UpdateAddress_Labels2, '\n', ':');
    msgConfirmDelete = labels.get('msgConfirmDelete');
    labels.remove('msgConfirmDelete');
} //*** end of "IEC_UpdateAddressController"


/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Initialize data for page
****************************************************************************************************/
public PageReference onPageLoad()
{
    Map<Id, IATA_ISO_Country__c> mapId_Country;
    
    //*** verify customer is logged
    if (loggedCustomer == null)
    {
        PageReference retPage = new PageReference('/IEC_Login?returl=' + '/IEC_UpdateAddress');
        retPage.setRedirect(true);
        return retPage;
    }

    //*** initialize default locations for first time customer
    if (loggedCustomer.billTo == null || loggedCustomer.shipTos == null || loggedCustomer.shipTos.size() == 0)
    {
        Location_Svc.InitializeContactLocations(loggedCustomer.sfContact.Id);
        loggedCustomer = Customer_DTO.getCustomerByUser(UserInfo.getUserId());
        Customer_DTO.setCustomerAddresses(loggedCustomer);
    }
    currentContact = loggedCustomer.sfContact;
    
    //*** get countries requiring zip/postal code
    mapId_Country = ISO_Country_State_Helper.requiredCountriesZipCode();
    for (Id key : mapId_Country.keySet())
        setCountryWithZip.add(mapId_Country.get(key).ISO_Code__c);
    
    //*** get countries having VAT number
    mapId_Country = ISO_Country_State_Helper.requiredCountriesVAT();
    for (Id key : mapId_Country.keySet())
        setCountryWithVAT.add(mapId_Country.get(key).ISO_Code__c);

    //*** build picklist for countries
    lstCountry = ISO_Country_State_Helper.getCountriesSelectOption();
    lstBillToState = new List<SelectOption>();
    lstShipToState = new List<SelectOption>();
    
    //*** prepare data entry for bill to
    currentBillToLocationId = currentContact.BillTo_Location__c;
    dtoBillToAddress = copyAddress(loggedCustomer.billTo, null);
    changeBillToCountry(false);
    
    //*** prepare data entry for bill to
    lstShipToAddress = new List<SelectOption>();
    currentShipToLocationId = currentContact.ShipTo_Location__c;
    isDefaultShipTo = true;
    buildShipToAddressPicklist();
    changeShipToAddress();

    return null;
} //*** end of "onPageLoad"


/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Clone a DTO address
****************************************************************************************************/
Address_DTO copyAddress(Address_DTO sourceAddress, Address_DTO targetAddress)
{
    if (targetAddress == null)
        targetAddress = new Address_DTO();
    
    if (sourceAddress != null)
    {
        targetAddress.street1 = sourceAddress.street1;
        targetAddress.city = sourceAddress.city;
        //targetAddress.stateLabel = sourceAddress.stateLabel;
        targetAddress.stateCode = sourceAddress.stateCode;
        targetAddress.postalCode = sourceAddress.postalCode;
        //targetAddress.countryLabel = sourceAddress.countryLabel;
        targetAddress.countryCode = sourceAddress.countryCode;
        targetAddress.vatNumber = sourceAddress.vatNumber;
        targetAddress.email = sourceAddress.email;
        targetAddress.phone = sourceAddress.phone;
        targetAddress.attention = sourceAddress.attention;
        targetAddress.addressName = sourceAddress.addressName;
        targetAddress.locationId = sourceAddress.locationId;
    }
    
    return targetAddress;
} //*** end of "copyAddress"


/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Check address information before insert/update
****************************************************************************************************/
List<IECAddress__c> checkAddress(Address_DTO inputAddress, Boolean isShipToAddress)
{
    String errorMsg = '';

    //*** validate address information
    if (isShipToAddress && String.isBlank(inputAddress.addressName))
        errorMsg = labels.get('lblAddrName');
    else if (String.isBlank(inputAddress.street1))
        errorMsg = labels.get('lblStreet');
    else if (((!isShipToAddress && showBillToZip == true) || (isShipToAddress && showShipToZip == true)) && String.isBlank(inputAddress.postalCode))
        errorMsg = labels.get('lblZip');
    else if (String.isBlank(inputAddress.city))
        errorMsg = labels.get('lblCity');
    else if (String.isBlank(inputAddress.countryCode))
        errorMsg = labels.get('lblCountry');
        
    else if (!isShipToAddress && String.isBlank(inputAddress.stateCode) && lstBillToState.size() > 0){
    	errorMsg = labels.get('lblState');
    }
    
    else if (isShipToAddress && String.isBlank(inputAddress.stateCode) && lstShipToState.size() > 0){
    	errorMsg = labels.get('lblState');
    }
    
    
    else if (String.isBlank(inputAddress.email))
        errorMsg = labels.get('lblEmail');
    else if (!isEmailValid(inputAddress.email))
        errorMsg = labels.get('msgInvalidEmail');
    else if (String.isBlank(inputAddress.phone))
        errorMsg = labels.get('lblPhone');
    else if (((!isShipToAddress && showBillToVAT == true) || (isShipToAddress && showShipToVAT == true)) && !String.isBlank(inputAddress.vatNumber))
        errorMsg = IECVATUtil.Validate_VAT(inputAddress.countryCode, inputAddress.vatNumber);

    if (String.isBlank(errorMsg))
        //*** no error -> check if address is already in system
        return new IECAddress_Sel().getAddress(inputAddress.street1, inputAddress.city, inputAddress.countryCode, inputAddress.stateCode, inputAddress.postalCode);
    else
    {
        //*** error -> display
        addErrorMessage(Label.IEC_Error_Required_field + ' ' + errorMsg);
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' ' + errorMsg));
        return null;
    }
} //*** end of "checkAddress"


/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Check if email is valid
        Email pattern took from http://howtodoinjava.com/regex/java-regex-validate-email-address
        at the recommended section
****************************************************************************************************/
Boolean isEmailValid(String inputEmail)
{
    Matcher regexCheck;
    String emailPattern = '^[\\w!#$%&’*+/=?`{|}~^-]+(?:\\.[\\w!#$%&’*+/=?`{|}~^-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,6}$';
    regexCheck = Pattern.compile(emailPattern).matcher(inputEmail);
    return regexCheck.find();
} //*** end of "isEmailValid"


/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Check if address is modified
****************************************************************************************************/
Boolean isAddressModified(Address_DTO inputAddress, Address_DTO sourceAddress)
{
    if (inputAddress == null || sourceAddress == null)
        return true;
    else
        return (inputAddress.street1 != sourceAddress.street1 || inputAddress.city != sourceAddress.city ||
                //inputAddress.countryLabel != sourceAddress.countryLabel || inputAddress.countryCode != sourceAddress.countryCode ||
                //inputAddress.stateLabel != sourceAddress.stateLabel || inputAddress.stateCode != sourceAddress.stateCode ||
                inputAddress.countryCode != sourceAddress.countryCode || inputAddress.stateCode != sourceAddress.stateCode ||
                inputAddress.postalCode != sourceAddress.postalCode || inputAddress.vatNumber != sourceAddress.vatNumber ||
                inputAddress.email != sourceAddress.email || inputAddress.phone != sourceAddress.phone || 
                inputAddress.attention != sourceAddress.attention || inputAddress.addressName != sourceAddress.addressName);
} //*** end of "cloneAddress"


/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Return addresses for autocomplete while user types
****************************************************************************************************/
@remoteAction
global static List<String> findAddresses(string strInput, String isoCountryCode, String isoStateCode)
{
    return IECAddress_Sel.getAutocompleteAddresses(strInput, isoCountryCode, isoStateCode);
} //*** end of "findAddresses"


/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Copy autocomplete address to bill to
****************************************************************************************************/
public void getBillToAutoCompleteAddress()
{
    List<IECAddress__c> lstAddress =  new IECAddress_Sel().getFullAddress(autocompleteFullAddress);
    if(lstAddress != null && lstAddress.size() > 0)
    {
        dtoBillToAddress.street1     = lstAddress[0].Street__c;
        dtoBillToAddress.city        = lstAddress[0].City__c;
        dtoBillToAddress.postalCode  = lstAddress[0].ZipCode__c;
        dtoBillToAddress.countryCode = lstAddress[0].ISO_Country_Code__c;
        dtoBillToAddress.stateCode   = lstAddress[0].ISO_State_Code__c;
        changeBillToCountry(false);
    }
} //*** end of "getBillToAutoCompleteAddress"


/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Set country name and refresh state picklist when bill to country picklist is changed
****************************************************************************************************/
public void changeBillToCountry() {
    //*** this method is called from VF page
    //*** due to the use of "input" instead of "apex:inputText" for autocomplete, need to update value from input directly
    dtoBillToAddress.street1 = ApexPages.currentPage().getParameters().get('billToStreet');

    changeBillToCountry(true);
}
public void changeBillToCountry(Boolean resetState) {
    //*** reset state's fields
    lstBillToState.clear();
    if (resetState)
    {
        //dtoBillToAddress.stateLabel = null;
        dtoBillToAddress.stateCode = null;
    }
    
    //*** reset zip/postal code if necessary
    showBillToZip = setCountryWithZip.contains(dtoBillToAddress.countryCode);
    //if (!showBillToZip)
        //dtoBillToAddress.postalCode = null;
    
    //*** reset VAT information if necessary
    showBillToVAT = setCountryWithVAT.contains(dtoBillToAddress.countryCode);
    //if (!showBillToVAT)
        //dtoBillToAddress.vatNumber = null;
    
    //*** locate the country in picklist -> if a country is selected then save selected country name and build state picklist
    Integer ixCountry = Utility.findItemInSelectList(lstCountry, dtoBillToAddress.countryCode, null);
    if (ixCountry > 0)
    {
        //dtoBillToAddress.countryLabel = lstCountry[ixCountry].getLabel();
        lstBillToState.addAll(ISO_Country_State_Helper.getStatesSelectOption(dtoBillToAddress.countryCode));
    }
} //*** end of "changeBillToCountry"


/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Revert changes on bill to address to original
****************************************************************************************************/
public void cancelBillToAddress()
{
    dtoBillToAddress = null;
    dtoBillToAddress = copyAddress(loggedCustomer.billTo, null);
    changeBillToCountry(false);
} //*** end of "cancelBillToAddress"


/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Validate and save bill to address
****************************************************************************************************/
public void saveBillToAddress()
{
    List<IECAddress__c> lstAddress;
    Address_DTO sourceAddress = loggedCustomer.billTo;
    Location__c locationBillTo = null;

    //*** clear not applicable fields
    if (!showBillToZip)
        dtoBillToAddress.postalCode = null;
    if (!showBillToVAT)
        dtoBillToAddress.vatNumber = null;
    if (lstBillToState == null || lstBillToState.size() == 0)
    {
        dtoBillToAddress.stateCode = null;
        //dtoBillToAddress.stateLabel = null;
    }
    
    //*** due to the use of "input" instead of "apex:inputText" for autocomplete, need to update value from input directly
    dtoBillToAddress.street1 = ApexPages.currentPage().getParameters().get('billToStreet');
    
    //*** check if address enterred is valid and is already in system
    lstAddress = checkAddress(dtoBillToAddress, false);
    if (lstAddress == null)
        return;

    //*** do nothing if address is not modified
    if (!isAddressModified(dtoBillToAddress, sourceAddress))
    {
        addConfirmMessage(labels.get('lblSectionBillTo') + labels.get('msgSaved'));
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, labels.get('lblSectionBillTo') + labels.get('msgSaved')));
        return;
    }

    //*** add new address if not in database yet
    if (lstAddress.size() == 0)
        lstAddress.add(IECAddress_Svc.newAddress(dtoBillToAddress.street1, dtoBillToAddress.city, dtoBillToAddress.countryCode, dtoBillToAddress.stateCode, dtoBillToAddress.postalCode));
    
    if (dtoBillToAddress.countryCode != sourceAddress.countryCode || dtoBillToAddress.stateCode != sourceAddress.stateCode)
    {
        //*** what to do when country/province changes

        //*** check if a location for country/province already exist
        for (Location__c location : [select Id
                                     from Location__c
                                     where Contact__c = :currentContact.Id and Type__c = :IECConstants.BILLTO and Active__c = false
                                       and ISO_Country_Code__c = :dtoBillToAddress.countryCode and ISO_State_Code__c = :dtoBillToAddress.stateCode limit 1])
            locationBillTo = new Location__c(Id=location.Id, Address__c=lstAddress[0].Id, Email__c=dtoBillToAddress.email, Phone__c=dtoBillToAddress.phone
                                           , VAT_Number__c=dtoBillToAddress.vatNumber, Address_Name__c=null, Active__c=true);
        
        //*** deactivate existing location -> should be before create/update because of trigger for uniqueness
        update (new Location__c(Id=currentBillToLocationId, Active__c=false));

        //*** create/update location
        if (locationBillTo == null)
            locationBillTo = Location_Svc.createLocation(lstAddress[0].Id, currentContact.Id, dtoBillToAddress.email, dtoBillToAddress.phone, dtoBillToAddress.vatNumber, IECConstants.BILLTO);
        else
            update locationBillTo;
        dtoBillToAddress.locationId = locationBillTo.Id;

        //*** update new location as default on contact
        update (new Contact(Id=currentContact.Id, BillTo_Location__c=locationBillTo.Id));
        currentContact.BillTo_Location__c = locationBillTo.Id;
        currentBillToLocationId = locationBillTo.Id;
    }
    else
    {
        //*** update location when no change on country/province
        locationBillTo = new Location__c(Id=currentBillToLocationId, Address__c=null, Email__c=dtoBillToAddress.email, Phone__c=dtoBillToAddress.phone
                                       , VAT_Number__c=dtoBillToAddress.vatNumber, Address_Name__c=null);
        
        //*** ensure not to update address if not necessary
        for (IECAddress__c addr : lstAddress)
            if (addr.Id == currentContact.BillTo_Location__r.Address__c)
            {
                locationBillTo.Address__c = addr.Id;
                break;
            }
        if (locationBillTo.Address__c == null)
            locationBillTo.Address__c = lstAddress[0].Id;
        
        update locationBillTo;
        
        //if (locationBillTo.Address__c != currentContact.BillTo_Location__r.Address__c)
        //    Customer_DTO.setCustomerAddresses(loggedCustomer);
    }

    //*** update original address
    copyAddress(dtoBillToAddress, loggedCustomer.billTo);
    
    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, labels.get('lblSectionBillTo') + labels.get('msgSaved')));
    addConfirmMessage(labels.get('lblSectionBillTo') + labels.get('msgSaved'));
} //*** end of "saveBillToAddress"


/****************************************************************************************************
    Created by CGI, Thai 2016-04-15
        Build picklist for Ship To addresses
****************************************************************************************************/
void buildShipToAddressPicklist()
{
    String strTemp;
    Integer i1;
    
    lstShipToAddress.clear();
    
    //*** set label as key for sorting
    if(loggedCustomer.shipTos != null)
        for (i1 = 0; i1 < loggedCustomer.shipTos.size(); i1++)
            lstShipToAddress.add(new SelectOption((loggedCustomer.shipTos[i1].addressName == null ? loggedCustomer.shipTos[i1].street1 : loggedCustomer.shipTos[i1].addressName), loggedCustomer.shipTos[i1].locationId));
        
    //*** sort picklist by label
    lstShipToAddress.sort();
    
    //*** set proper key and label for picklist
    for (i1 = 0; i1 < lstShipToAddress.size(); i1++)
    {
        strTemp = lstShipToAddress[i1].getLabel();
        lstShipToAddress[i1].setLabel(lstShipToAddress[i1].getValue());
        lstShipToAddress[i1].setValue(strTemp);
    }
    
    showShipToDelete = lstShipToAddress.size() > 1;
} //*** end of "buildShipToAddressPicklist"


/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Copy autocomplete address to ship to
****************************************************************************************************/
public void getShipToAutoCompleteAddress()
{
    List<IECAddress__c> lstAddress =  new IECAddress_Sel().getFullAddress(autocompleteFullAddress);
    if(lstAddress != null && lstAddress.size() > 0)
    {
        dtoShipToAddress.street1     = lstAddress[0].Street__c;
        dtoShipToAddress.city        = lstAddress[0].City__c;
        dtoShipToAddress.postalCode  = lstAddress[0].ZipCode__c;
        dtoShipToAddress.countryCode = lstAddress[0].ISO_Country_Code__c;
        dtoShipToAddress.stateCode   = lstAddress[0].ISO_State_Code__c;
        changeShipToCountry(false);
    }
} //*** end of "getShipToAutoCompleteAddress"


/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Action when select an address from picklist
****************************************************************************************************/
public void changeShipToAddress()
{
    if(loggedCustomer.shipTos != null)
        for (Integer i1 = 0; i1 < loggedCustomer.shipTos.size(); i1++)
            if (currentShipToLocationId == loggedCustomer.shipTos[i1].locationId)
            {
                dtoShipToAddress = copyAddress(loggedCustomer.shipTos[i1], null);
                changeShipToCountry(false);
                break;
            }

    isDefaultShipTo = currentShipToLocationId == currentContact.ShipTo_Location__c;
    makeShipToDefault = isDefaultShipTo;
    showShipToDelete = lstShipToAddress.size() > 1;
} //*** end of "changeShipToAddress"


/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Set country name and refresh state picklist when ship to country picklist is changed
****************************************************************************************************/
public void changeShipToCountry() {
    //*** this method is called from VF page
    //*** due to the use of "input" instead of "apex:inputText" for autocomplete, need to update value from input directly
    dtoShipToAddress.street1 = ApexPages.currentPage().getParameters().get('shipToStreet');

    changeShipToCountry(true);
}
public void changeShipToCountry(Boolean resetState) {
    //*** reset state's fields
    lstShipToState.clear();
    if (resetState)
    {
        //dtoShipToAddress.stateLabel = null;
        dtoShipToAddress.stateCode = null;
    }
    
    //*** reset zip/postal code if necessary
    showShipToZip = setCountryWithZip.contains(dtoShipToAddress.countryCode);
    //if (!showShipToZip)
        //dtoShipToAddress.postalCode = null;
    
    //*** reset VAT information if necessary
    showShipToVAT = setCountryWithVAT.contains(dtoShipToAddress.countryCode);
    //if (!showShipToVAT)
        //dtoShipToAddress.vatNumber = null;
    
    //*** locate the country in picklist -> if a country is selected then save selected country name and build state picklist
    Integer ixCountry = Utility.findItemInSelectList(lstCountry, dtoShipToAddress.countryCode, null);
    if (ixCountry > 0)
    {
        //dtoShipToAddress.countryLabel = lstCountry[ixCountry].getLabel();
        lstShipToState.addAll(ISO_Country_State_Helper.getStatesSelectOption(dtoShipToAddress.countryCode));
    }
} //*** end of "changeShipToCountry"


/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Revert changes on ship to address to original
****************************************************************************************************/
public void cancelShipToAddress()
{
    dtoShipToAddress = null;
    
    changeShipToAddress();
} //*** end of "cancelShipToAddress"


/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Delete an address
****************************************************************************************************/
public void deleteShipToAddress()
{
    //*** inactivate the location
    update new Location__c(Id=currentShipToLocationId, Active__c=false);
    for (Integer i1 = 0; i1 < loggedCustomer.shipTos.size(); i1++)
        if (currentShipToLocationId == loggedCustomer.shipTos[i1].locationId)
        {
            loggedCustomer.shipTos.remove(i1);
            break;
        }
    
    //*** prepare to display the default address
    currentShipToLocationId = currentContact.ShipTo_Location__c;
    buildShipToAddressPicklist();
    changeShipToAddress();
    
    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, labels.get('lblSectionShipTo') + labels.get('msgDeleted')));
    addConfirmMessage(labels.get('lblSectionShipTo') + labels.get('msgDeleted'));
} //*** end of "deleteShipToAddress"


/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Preparation to add new ship to address
****************************************************************************************************/
public void prepareNewShipToAddress()
{
    dtoShipToAddress = null;
    dtoShipToAddress = new Address_DTO();
    dtoShiptoAddress.email = currentContact.Email;
    dtoShiptoAddress.phone = currentContact.Phone;
    dtoShiptoAddress.attention = currentContact.Name;
    
    isDefaultShipTo = false;
    makeShipToDefault = false;
    showShipToDelete = false;
    
    changeShipToCountry(false);
} //*** end of "prepareNewShipToAddress"


/****************************************************************************************************
    Created by CGI, Thai 2016-04-25
        Validate and save ship to address
****************************************************************************************************/
public void saveShipToAddress()
{
    List<IECAddress__c> lstAddress;
    Address_DTO sourceAddress;
    Location__c locationShipTo = null;
    Boolean isNewShipToAddress = dtoShipToAddress.locationId == null;
    Boolean newAddressCreated;
    Map<Id, Location__c> mapId_Location;
    Set<Id> setAddreddId = new Set<Id>();

    //*** clear not applicable fields
    if (!showShipToZip)
        dtoShipToAddress.postalCode = null;
    if (!showShipToVAT)
        dtoShipToAddress.vatNumber = null;
    if (lstShipToState == null || lstShipToState.size() == 0)
    {
        dtoShipToAddress.stateCode = null;
        //dtoShipToAddress.stateLabel = null;
    }
    
    //*** due to the use of "input" instead of "apex:inputText" for autocomplete, need to update value from input directly
    dtoShipToAddress.street1 = ApexPages.currentPage().getParameters().get('shipToStreet');
    
    //*** check if address enterred is valid and is already in system
    lstAddress = checkAddress(dtoShipToAddress, true);
    if (lstAddress == null)
        return;

    //*** do nothing if address is not modified
    if (!isNewShipToAddress)
    {
        for (Integer i1 = 0; i1 < loggedCustomer.shipTos.size(); i1++)
            if (currentShipToLocationId == loggedCustomer.shipTos[i1].locationId)
            {
                sourceAddress = loggedCustomer.shipTos[i1];
                break;
            }
        if (!isAddressModified(dtoShipToAddress, sourceAddress))
        {
            //*** update default
            if (!isDefaultShipTo && makeShipToDefault)
            {
                update (new Contact(Id=currentContact.Id, ShipTo_Location__c=currentShipToLocationId));
                currentContact.ShipTo_Location__c = currentShipToLocationId;
                isDefaultShipTo = true;
            }
            
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, labels.get('lblSectionShipTo') + labels.get('msgSaved')));
            addConfirmMessage(labels.get('lblSectionShipTo') + labels.get('msgSaved'));
            return;
        }
    }

    //*** prepare to check addresses
    newAddressCreated = lstAddress.size() == 0;
    if (lstAddress.size() > 0)
    {
        //*** get Ship To locationss
        mapId_Location = new Location_Sel().getContactsLocations(new Set<Id>{currentContact.Id});
        for (Id idLocation : mapId_Location.keySet())
            if (mapId_Location.get(idLocation).Type__c != IECConstants.SHIPTO)
                mapId_Location.remove(idLocation);

        //*** prepare checking address exists
        for (IECAddress__c addr : lstAddress)
            setAddreddId.add(addr.Id);
    }
    else
        lstAddress.add(IECAddress_Svc.newAddress(dtoShipToAddress.street1, dtoShipToAddress.city, dtoShipToAddress.countryCode, dtoShipToAddress.stateCode, dtoShipToAddress.postalCode));
    
    //*** insert/update location
    if (isNewShipToAddress)
    {
        //*** validate if inserting location already exists
        if (!newAddressCreated)
            for (Id idLocation : mapId_Location.keySet())
                if (setAddreddId.contains(mapId_Location.get(idLocation).Address__c))
                {
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, labels.get('msgAddrExist')));
                    addErrorMessage(labels.get('msgAddrExist'));
                    return;
                }
        
        //*** validate if inserting location was inactivated
        locationShipTo = null;
        for (Location__c location : [select Id
                                     from Location__c
                                     where Contact__c = :currentContact.Id and Type__c = :IECConstants.SHIPTO and Active__c = false
                                       and Address__c = :lstAddress[0].Id limit 1])
            locationShipTo = new Location__c(Id=location.Id, Address__c=lstAddress[0].Id, Address_Name__c=dtoShipToAddress.addressName, Attention__c=dtoShipToAddress.attention
                                           , Email__c=dtoShipToAddress.email, Phone__c=dtoShipToAddress.phone, VAT_Number__c=dtoShipToAddress.vatNumber, Active__c=true);
        
        //*** new address or location for this address not exists -> create
        if (locationShipTo == null)
            locationShipTo = Location_Svc.createLocation(lstAddress[0].Id, currentContact.Id, dtoShipToAddress.email, dtoShipToAddress.phone, dtoShipToAddress.vatNumber, IECConstants.SHIPTO, dtoShipToAddress.attention, dtoShipToAddress.addressName);
        else
            update locationShipTo;
        currentShipToLocationId = locationShipTo.Id;
        dtoShipToAddress.locationId = currentShipToLocationId;
        loggedCustomer.shipTos.add(copyAddress(dtoShipToAddress, null));
    }
    else
    {
        //*** validate if updating address already exists
        if (!newAddressCreated)
            for (Id idLocation : mapId_Location.keySet())
                if (idLocation == currentShipToLocationId)
                {
                    if (setAddreddId.contains(mapId_Location.get(idLocation).Address__c))
                        break;
                }
                else if (setAddreddId.contains(mapId_Location.get(idLocation).Address__c))
                {
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, labels.get('msgAddrExist')));
                    addErrorMessage(labels.get('msgAddrExist'));
                    return;
                }
        
        //*** update location
        if (dtoShipToAddress.countryCode != sourceAddress.countryCode || dtoShipToAddress.stateCode != sourceAddress.stateCode)
        {
            //*** what to do when country/province changes

            //*** check if a location for country/province already exist
            locationShipTo = null;
            for (Location__c location : [select Id
                                         from Location__c
                                         where Contact__c = :currentContact.Id and Type__c = :IECConstants.SHIPTO and Active__c = false
                                           and ISO_Country_Code__c = :dtoShipToAddress.countryCode and ISO_State_Code__c = :dtoShipToAddress.stateCode limit 1])
                locationShipTo = new Location__c(Id=location.Id, Address__c=lstAddress[0].Id, Address_Name__c=dtoShipToAddress.addressName, Attention__c=dtoShipToAddress.attention
                                               , Email__c=dtoShipToAddress.email, Phone__c=dtoShipToAddress.phone, VAT_Number__c=dtoShipToAddress.vatNumber, Active__c=true);
            
            //*** deactivate existing location -> should be before create/update because of trigger for uniqueness
            update (new Location__c(Id=currentShipToLocationId, Active__c=false));

            //*** create/update location
            if (locationShipTo == null){
                locationShipTo = Location_Svc.createLocation(lstAddress[0].Id, currentContact.Id, dtoShipToAddress.email, dtoShipToAddress.phone, dtoShipToAddress.vatNumber, IECConstants.SHIPTO, dtoShipToAddress.attention, dtoShipToAddress.addressName);
            }
            else
                update locationShipTo;
            dtoShipToAddress.locationId = locationShipTo.Id;
            currentShipToLocationId = locationShipTo.Id;
        }
        else
        {
            if (!newAddressCreated && setAddreddId.contains(mapId_Location.get(currentShipToLocationId).Address__c))
                update new Location__c(Id=currentShipToLocationId, Address_Name__c=dtoShipToAddress.addressName, Attention__c=dtoShipToAddress.attention
                                     , Email__c=dtoShipToAddress.email, Phone__c=dtoShipToAddress.phone, VAT_Number__c=dtoShipToAddress.vatNumber);
            else
                update new Location__c(Id=currentShipToLocationId, Address__c=lstAddress[0].Id, Address_Name__c=dtoShipToAddress.addressName, Attention__c=dtoShipToAddress.attention
                                     , Email__c=dtoShipToAddress.email, Phone__c=dtoShipToAddress.phone, VAT_Number__c=dtoShipToAddress.vatNumber);
        }
        copyAddress(dtoShipToAddress, sourceAddress);
    }

    //*** update default
    if (!isDefaultShipTo && makeShipToDefault)
    {
        update (new Contact(Id=currentContact.Id, ShipTo_Location__c=currentShipToLocationId));
        currentContact.ShipTo_Location__c = currentShipToLocationId;
        isDefaultShipTo = true;
    }

    if(makeShipToDefault && locationShipTo != null)
    {
        update (new Contact(Id=currentContact.Id, ShipTo_Location__c=locationShipTo.Id));
        currentContact.ShipTo_Location__c = locationShipTo.Id;
        isDefaultShipTo = true;
    }

    //*** rebuild picklist for addresses and display message
    buildShipToAddressPicklist();
    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, labels.get('lblSectionShipTo') + labels.get('msgSaved')));
    addConfirmMessage(labels.get('lblSectionShipTo') + labels.get('msgSaved'));
} //*** end of "saveShipToAddress"


} //*** end of class