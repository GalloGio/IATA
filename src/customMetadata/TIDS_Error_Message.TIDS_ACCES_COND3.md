<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>TIDS ACCES COND 3</label>
    <protected>false</protected>
    <values>
        <field>Business_Conditions__c</field>
        <value xsi:type="xsd:string">IF User’s Related Account Record Type is “Agency&quot; AND &quot;Account “Location_Class__c“ = &quot;C,D,G,I,K,M,P,Q,R,V,W,X“

&gt;&gt;&gt; Display “TIDS Condition Page“ with a “Condition Specific Error Message“ to notify the user that he his not eligible to TIDS under this account as it is already enrolled under an accreditation program.</value>
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
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Description_P2__c</field>
        <value xsi:type="xsd:string">For reference, a customer account may only be enrolled under one agency program at a time. If you wish to apply for TIDS, a different account must be used.</value>
    </values>
    <values>
        <field>Description_P3__c</field>
        <value xsi:type="xsd:string">Condition 3</value>
    </values>
    <values>
        <field>Description__c</field>
        <value xsi:type="xsd:string">Per our records, your company is registered on our Customer Portal under an account  that is or has been part of another IATA agency program.</value>
    </values>
    <values>
        <field>Discard_Application__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Open_A_Case_Text__c</field>
        <value xsi:type="xsd:string">Contact us for further assistance</value>
    </values>
    <values>
        <field>Recall_Application__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Resume_Application__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Subtitle__c</field>
        <value xsi:type="xsd:string">Oops, you do not appear to be eligible to the TIDS Program</value>
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
        <value xsi:type="xsd:string">What can I do?</value>
    </values>
    <values>
        <field>Yellow_Section_Text__c</field>
        <value xsi:nil="true"/>
    </values>
</CustomMetadata>
