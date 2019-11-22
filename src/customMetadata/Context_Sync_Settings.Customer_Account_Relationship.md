<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Customer - Account Relationship</label>
    <protected>false</protected>
    <values>
        <field>Context__c</field>
        <value xsi:type="xsd:string">Customer</value>
    </values>
    <values>
        <field>Fields_To_Check_On_Update__c</field>
        <value xsi:type="xsd:string">Child_Account__c,Parent_Account__c</value>
    </values>
    <values>
        <field>Object__c</field>
        <value xsi:type="xsd:string">Account_Relationship__c</value>
    </values>
</CustomMetadata>
