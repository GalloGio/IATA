<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>TIDS ACCES COND 8</label>
    <protected>false</protected>
    <values>
        <field>Business_Conditions__c</field>
        <value xsi:type="xsd:string">IF Legal Name provided on &quot;New TIDS HO Application - Step 1&quot; is found in the TIDS Population in the same country

&gt;&gt;&gt; Display “TIDS Condition Page“ with a “Condition Specific Error Message“ to notify the user that only 1 TIDS Head Office is allowed per Legal Entity in a given country.

Search Exact Match on “Legal Name” on all Accounts WHERE:
-	Account Record Type = “Agency”
AND
-	Account Location Class = “T” (Location_Class__c)
AND
-	Account Location Type = “HO” (Location_Type__c)
AND
-	Account Country = “Same as Provided in Step 1” (IATA_ISO_Country__c)</value>
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
        <value xsi:type="xsd:string">For reference, the same legal entity may only have one TIDS Head Office in a given country.
If you want to add a Branch Office, please do so by logging in under your Head Office account or contact your Agency&apos;s TIDS Administrator.</value>
    </values>
    <values>
        <field>Description_P3__c</field>
        <value xsi:type="xsd:string">Condition 8</value>
    </values>
    <values>
        <field>Description__c</field>
        <value xsi:type="xsd:string">It appears that your Legal Entity already participates to the TIDS Program.</value>
    </values>
    <values>
        <field>Discard_Application__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Open_A_Case_Text__c</field>
        <value xsi:type="xsd:string">Contact us for further assistance or if you think there is an error with your company details</value>
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
        <value xsi:type="xsd:string">Oops, we have found an existing TIDS Agency with the same Legal Name</value>
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
