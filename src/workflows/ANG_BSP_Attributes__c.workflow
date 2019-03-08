<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>GenerateUniqueKey</fullName>
        <field>UniqueKey__c</field>
        <formula>IF(RecordType.DeveloperName = &apos;Remittance_Frequency&apos;, RecordType.DeveloperName &amp;&apos;.&apos;&amp;  Operation__r.Name  &amp;&apos;.&apos;&amp; TEXT(Class_Type__c) &amp;&apos;.&apos;&amp; TEXT(Remittance_Frequency__c),

 IF(RecordType.DeveloperName = &apos;Cash_Condition_Conf&apos;,  BSP__c &amp;&apos;.&apos;&amp;  RecordTypeId,

  IF(RecordType.DeveloperName = &apos;RHC_Amount_Conf&apos;, BSP__c &amp;&apos;.&apos;&amp; RecordTypeId &amp;&apos;.&apos;&amp; TEXT(Risk_Status__c) &amp;&apos;.&apos;&amp;  TEXT(Min_FA_Points__c), &apos;&apos;)
 )
)</formula>
        <name>GenerateUniqueKey</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ANG_BSP_Attributes_Calculate_UniqueKey_Cash_Condition_RT</fullName>
        <active>false</active>
        <criteriaItems>
            <field>ANG_BSP_Attributes__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cash Condition Conf</value>
        </criteriaItems>
        <description>Calculate Unique Key when RecordType = &quot;Cash_Condition_Conf&quot;</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>GenerateUniqueKey</fullName>
        <actions>
            <name>GenerateUniqueKey</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Generate Unique Key for BSP Attributes</description>
        <formula>OR( 
  RecordType.DeveloperName = &apos;Cash_Condition_Conf&apos;, 
  RecordType.DeveloperName = &apos;RHC_Amount_Conf&apos;,
  RecordType.DeveloperName = &apos;Remittance_Frequency&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
