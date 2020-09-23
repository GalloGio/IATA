<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>TIDS ACCES COND 7.1.Pending Review</label>
    <protected>false</protected>
    <values>
        <field>Business_Conditions__c</field>
        <value xsi:type="xsd:string">Condition applies if:

Existence of 1 TIDS Case with
- Case Type = &quot;New HO Application&quot;
AND
- Case Status = &quot;Pending Review&quot;
AND
- Related User IS the Contact Associated to the Case</value>
    </values>
    <values>
        <field>Cancel_Application__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Close_Vetting__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Create_a_Case__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Description_P2__c</field>
        <value xsi:type="xsd:string">If you submitted your application in error or would like to make a correction, you may recall it using the &quot;Recall&quot; button on the right-side of this screen. For reference, once IATA&apos;s review of your application begins, this option will no longer be available.</value>
    </values>
    <values>
        <field>Description_P3__c</field>
        <value xsi:type="xsd:string">Condition 7.1.Pending Review</value>
    </values>
    <values>
        <field>Description__c</field>
        <value xsi:type="xsd:string">Your application for a Head Office under the TIDS Program has been successfully submitted through Case Number {@Case} and is pending revision by IATA. You will be contacted in the coming days with the outcome of our review.</value>
    </values>
    <values>
        <field>Discard_Application__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Open_A_Case_Text__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Recall_Application__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Resume_Application__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Subtitle__c</field>
        <value xsi:type="xsd:string">TIDS Application Successfully Submitted</value>
    </values>
    <values>
        <field>Visit_A_Website_Text__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Visit_URL__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Yellow_Section_Header__c</field>
        <value xsi:type="xsd:string">Made a Mistake?</value>
    </values>
    <values>
        <field>Yellow_Section_Text__c</field>
        <value xsi:type="xsd:string">If you submitted your application too quickly and need to make a correction, recall your application below</value>
    </values>
</CustomMetadata>
