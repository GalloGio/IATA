<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>ISSP_ProgressBar_Application_Approved</label>
    <protected>false</protected>
    <values>
        <field>Description__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>IconError__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>IconNotDone__c</field>
        <value xsi:type="xsd:string">thumbs-up</value>
    </values>
    <values>
        <field>IconOk__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>IconProgress__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Is_Visible__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Order__c</field>
        <value xsi:type="xsd:double">5.0</value>
    </values>
    <values>
        <field>Parent__c</field>
        <value xsi:type="xsd:string">OSCAR_NEW_BR</value>
    </values>
    <values>
        <field>ValueError__c</field>
        <value xsi:type="xsd:string">OSCAR__r.STEP15__c = &apos;Failed&apos; 
OR 
OSCAR__r.STEP2__c = &apos;Failed&apos;
OR
OSCAR__r.STEP1__c = &apos;Failed&apos;</value>
    </values>
    <values>
        <field>ValueOk__c</field>
        <value xsi:type="xsd:string">OSCAR__r.Status__c = &apos;Closed&apos;
AND
OSCAR__r.STEP15__c IN (&apos;Passed&apos;, &apos;Not Applicable&apos;)
AND
OSCAR__r.STEP2__c IN (&apos;Passed&apos;, &apos;Not Applicable&apos;)
AND
OSCAR__r.STEP1__c IN (&apos;Passed&apos;, &apos;Not Applicable&apos;)</value>
    </values>
    <values>
        <field>ValueProgress__c</field>
        <value xsi:type="xsd:string">(
	OSCAR__r.STEP11__c IN (&apos;Passed&apos;, &apos;Not applicable&apos;) 
	AND 
	OSCAR__r.STEP12__c IN (&apos;Passed&apos;, &apos;Not applicable&apos;) 
	AND 
	OSCAR__r.STEP13__c IN (&apos;Passed&apos;, &apos;Not applicable&apos;) 
	AND 
	OSCAR__r.STEP14__c IN (&apos;Passed&apos;, &apos;Not applicable&apos;)
) 
AND
(
	OSCAR__r.Status__c != &apos;Closed&apos;
	AND
	OSCAR__r.STEP15__c IN (&apos;Passed&apos;, &apos;Not Applicable&apos;, &apos;In Progress&apos;, &apos;Not Started&apos;)
	AND
	OSCAR__r.STEP2__c IN (&apos;Passed&apos;, &apos;Not Applicable&apos;, &apos;In Progress&apos;, &apos;Not Started&apos;)
	AND
	OSCAR__r.STEP1__c IN (&apos;Passed&apos;, &apos;Not Applicable&apos;, &apos;In Progress&apos;, &apos;Not Started&apos;)
)</value>
    </values>
</CustomMetadata>
