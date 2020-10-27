<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>TIDS ACCES COND 4.2</label>
    <protected>false</protected>
    <values>
        <field>Business_Conditions__c</field>
        <value xsi:type="xsd:string">IF User’s related Account is:
- Record Type = “Agency”
AND
- &quot;Location__c&quot; = “T“
AND
- &quot;Status__c&quot; = “Approved, Terminated”
AND
- &quot;Reinstatement Window&quot; != &quot;Expired&quot;
AND
- User IS NOT &quot;Admin&quot;
AND
- There is NO Active (AccessGranted Status) Admin for the Agency

&gt;&gt;&gt; Display “TIDS Condition Page“ with a “Condition Specific Error Message“ to notify the user that he has to contact his TIDS Admin.</value>
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
        <value xsi:type="xsd:string">At this time, it appears that your TIDS Agency has no Administrator set up in our system. Please contact IATA to assign this role. For reference, the TIDS Administrator role may only be assigned to a person authorized to act on behalf of the business.</value>
    </values>
    <values>
        <field>Description_P3__c</field>
        <value xsi:type="xsd:string">Condition 4.2</value>
    </values>
    <values>
        <field>Description__c</field>
        <value xsi:type="xsd:string">The TIDS Service can only be accessed by a designated TIDS Administrator.</value>
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
        <value xsi:type="xsd:string">Oops, you do not appear to have access to the TIDS service</value>
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
