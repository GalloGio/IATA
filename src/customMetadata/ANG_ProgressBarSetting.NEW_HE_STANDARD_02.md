<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>ISSP_ProgressBar_SanityCheck</label>
    <protected>false</protected>
    <values>
        <field>Description__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Is_Visible__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Order__c</field>
        <value xsi:type="xsd:double">2.0</value>
    </values>
    <values>
        <field>RecordType__c</field>
        <value xsi:type="xsd:string">ANG.NEW.HE.STANDARD.1.0|New HE standard</value>
    </values>
    <values>
        <field>ValueError__c</field>
        <value xsi:type="xsd:string">OSCAR__r.STEP6__c=&apos;Failed&apos; OR OSCAR__r.STEP17__c=&apos;Failed&apos;</value>
    </values>
    <values>
        <field>ValueOk__c</field>
        <value xsi:type="xsd:string">OSCAR__r.STEP6__c=&apos;Passed&apos; AND OSCAR__r.STEP17__c!=&apos;Failed&apos;</value>
    </values>
    <values>
        <field>ValueProgress__c</field>
        <value xsi:type="xsd:string">OSCAR__r.STEP6__c=&apos;In Progress&apos; OR OSCAR__r.STEP17__c=&apos;In Progress&apos;</value>
    </values>
</CustomMetadata>
