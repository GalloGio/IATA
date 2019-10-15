<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Court_case_warning-Case</label>
    <protected>false</protected>
    <values>
        <field>Icon__c</field>
        <value xsi:type="xsd:string">utility:warning</value>
    </values>
    <values>
        <field>Main_Object__c</field>
        <value xsi:type="xsd:string">Case</value>
    </values>
    <values>
        <field>Message__c</field>
        <value xsi:type="xsd:string">This account has a court case open. Please contact {!Case.Owner.Name} before interacting with the customer.</value>
    </values>
    <values>
        <field>Multiple_Records__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Query__c</field>
        <value xsi:type="xsd:string">SELECT Id, Owner.Name, CaseNumber
FROM Case
WHERE RecordType.DeveloperName = &apos;ProcessEuropeSCE&apos; AND IsClosed = false
AND (NOT Owner.Name LIKE &apos;%Recycle%&apos;) AND Reason1__c = &apos;Court Case&apos; AND AccountId = {!AccountId} AND
Id &lt;&gt; {!Id}</value>
    </values>
    <values>
        <field>Related_Object__c</field>
        <value xsi:type="xsd:string">Case</value>
    </values>
    <values>
        <field>Variant__c</field>
        <value xsi:type="xsd:string">warning</value>
    </values>
</CustomMetadata>
