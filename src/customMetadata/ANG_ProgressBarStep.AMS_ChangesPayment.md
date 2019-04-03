<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>ISSP_ProgressBar_Payment</label>
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
        <value xsi:type="xsd:string">usd</value>
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
        <value xsi:type="xsd:double">3.0</value>
    </values>
    <values>
        <field>Parent__c</field>
        <value xsi:type="xsd:string">OSCAR_Changes</value>
    </values>
    <values>
        <field>ValueError__c</field>
        <value xsi:type="xsd:string">OSCAR__r.STEP29__c = &apos;Failed&apos;
OR
OSCAR__r.STEP28__c = &apos;Failed&apos;
OR
OSCAR__r.STEP27__c = &apos;Failed&apos;
OR
OSCAR__r.STEP26__c = &apos;Failed&apos;
OR
OSCAR__r.STEP8__c = &apos;Failed&apos;
OR
OSCAR__r.STEP9__c = &apos;Failed&apos;</value>
    </values>
    <values>
        <field>ValueOk__c</field>
        <value xsi:type="xsd:string">OSCAR__r.STEP29__c IN (&apos;Passed&apos;, &apos;Not Applicable&apos;)
AND
OSCAR__r.STEP8__c IN (&apos;Passed&apos;, &apos;Not Applicable&apos;)
AND
OSCAR__r.STEP9__c IN (&apos;Passed&apos;, &apos;Not Applicable&apos;)
AND
(
	NOT
	(
		OSCAR__r.STEP28__c = &apos;Failed&apos;
		OR
		OSCAR__r.STEP27__c = &apos;Failed&apos;
		OR
		OSCAR__r.STEP26__c = &apos;Failed&apos;
	)
)</value>
    </values>
    <values>
        <field>ValueProgress__c</field>
        <value xsi:type="xsd:string">OSCAR__r.STEP29__c IN (&apos;Passed&apos;, &apos;Not Applicable&apos;)
AND
(
	OSCAR__r.STEP8__c = &apos;In Progress&apos;
	OR
	OSCAR__r.STEP9__c = &apos;In Progress&apos;
)</value>
    </values>
</CustomMetadata>
