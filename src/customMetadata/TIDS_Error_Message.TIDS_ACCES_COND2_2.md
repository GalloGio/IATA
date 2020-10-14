<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>TIDS ACCES COND 2.2</label>
    <protected>false</protected>
    <values>
        <field>Business_Conditions__c</field>
        <value xsi:type="xsd:string">IF User’s is registered in a Country (&quot;IATA_ISO_Country__c&quot;) WHERE &quot;Sanctioned_Country__c&quot; = TRUE:

&gt;&gt;&gt; Display “TIDS Condition Page“ with a “Condition Specific Error Message“ to notify the user that he his not eligible to TIDS due to economic sanctions.

&gt;&gt;&gt; Based on “Country_ISO_Code__c” at Account Level</value>
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
        <value xsi:type="xsd:string">For reference, due to economic sanctions, IATA cannot offer the TIDS Program to travel sellers in your market.</value>
    </values>
    <values>
        <field>Description_P3__c</field>
        <value xsi:type="xsd:string">Condition 2.2</value>
    </values>
    <values>
        <field>Description__c</field>
        <value xsi:type="xsd:string">Per our records, your company account is currently registered on our Customer Portal in a country which is not eligible to the TIDS Program.</value>
    </values>
    <values>
        <field>Discard_Application__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Open_A_Case_Text__c</field>
        <value xsi:type="xsd:string">Contact us if you think there is an error with your company details</value>
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
