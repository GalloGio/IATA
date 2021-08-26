<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Airline_Becomes_Active_for_the_First_Time_Alert</fullName>
        <description>Airline Becomes Active for the First Time Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>humbertdrc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kirkl@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>martinsp@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pilonb@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Airline_Becomes_Active_for_the_First_Time_Notification</template>
    </alerts>
    <alerts>
        <fullName>Airline_Becomes_Inactive_Alert</fullName>
        <description>Airline Becomes Inactive Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>humbertdrc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kirkl@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>martinsp@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pilonb@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Airline_Becomes_Inactive_Notification</template>
    </alerts>
    <alerts>
        <fullName>Airline_Becomes_Re_Activated_Alert</fullName>
        <description>Airline Becomes Re-Activated Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>humbertdrc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kirkl@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>martinsp@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pilonb@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Airline_Becomes_Re_Activated_Notification</template>
    </alerts>
    <alerts>
        <fullName>FDS_CodingAOC2</fullName>
        <description>FDS Coding - AOC Expiry alert 2</description>
        <protected>false</protected>
        <recipients>
            <recipient>bricenoa@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kaddafo@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pietranget@iata.org.prod</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sanchezc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Airline_Coding/AUTO_Expiry_of_AOC_approaching2</template>
    </alerts>
    <alerts>
        <fullName>FDS_Coding_AOC_Expiry_date_alert_10_Days_before2</fullName>
        <description>FDS Coding AOC Expiry date alert 10 Days before</description>
        <protected>false</protected>
        <recipients>
            <recipient>bricenoa@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kaddafo@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pietranget@iata.org.prod</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sanchezc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Airline_Coding/AUTO_Expiry_of_AOC_approaching</template>
    </alerts>
    <alerts>
        <fullName>Irregularity_Thresold_Met</fullName>
        <description>Irregularity Thresold Met</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/SURVEY_a1Q20000000UD7AEAW</template>
    </alerts>
    <fieldUpdates>
        <fullName>AccountIATAAirlineSetName</fullName>
        <description>Set the name of an IATA Airline Account, first using Trade Name, in second place using Legal Name and in third place Name_on_AOC__c</description>
        <field>Name</field>
        <formula>IF(
  OR( ISNULL( TradeName__c ), TradeName__c == &apos;&apos;),
  IF (
			OR( ISNULL( Legal_name__c ), Legal_name__c == &apos;&apos;),
				IF (
    OR( ISNULL( Name_on_AOC__c ), Name_on_AOC__c == &apos;&apos;),
    Name,
    Name_on_AOC__c
  ),
				Legal_name__c
		),
  TradeName__c
)</formula>
        <name>AccountIATAAirlineSetName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Airline_Designator_Backup</fullName>
        <description>Copy the Airline Designator value to the field Airline Designator Old</description>
        <field>Old_Airline_designator__c</field>
        <formula>PRIORVALUE(Airline_designator__c)</formula>
        <name>Airline Designator Backup</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Data_quality_comment_history</fullName>
        <description>Historize the data quality feedback comment</description>
        <field>Data_quality_history__c</field>
        <formula>Data_quality_history__c + BR() + TEXT(TODAY()) + &apos;: &apos; + Comment_data_quality_feedback__c</formula>
        <name>Data quality comment history</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rename_Branch</fullName>
        <field>Name</field>
        <formula>if(NOT(ISBLANK( Parent.TradeName__c)),Parent.TradeName__c,Parent.Name)</formula>
        <name>Rename Branch</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_irregularity_email</fullName>
        <field>Send_Irregularity_Email__c</field>
        <literalValue>0</literalValue>
        <name>Reset irregularity email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateIndustry</fullName>
        <description>It will update industry as &apos;Travel Agency&apos;</description>
        <field>Industry</field>
        <literalValue>Travel Agency</literalValue>
        <name>Update Industry</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_acct_name</fullName>
        <field>Name</field>
        <formula>if(NOT(ISBLANK( Parent.TradeName__c)),Parent.TradeName__c,Parent.Name)</formula>
        <name>Update acct name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ACLIAccountSetName</fullName>
        <actions>
            <name>AccountIATAAirlineSetName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set the name of an ACLI account (RT = Airline Headquarters OR RT = Agency WW HQ ) using its Trade Name or AOC Name</description>
        <formula>AND (   OR(RecordType.DeveloperName = &apos;IATA_Airline&apos;, RecordType.DeveloperName = &apos;Agency_WW_HQ&apos;),   OR( ISNEW(), ISCHANGED( TradeName__c ), ISCHANGED( Legal_name__c ), ISCHANGED( Name_on_AOC__c ) )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AMS_PCI_Auto_Expire</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Account.Is_PCI_compliant__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <description>When PCI Expire date is reach auto change PCI to &quot;No&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Account.ANG_PCI_compliance_expiry_date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Airline Becomes Active for the First Time</fullName>
        <actions>
            <name>Airline_Becomes_Active_for_the_First_Time_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Sends a notification email when an airline becomes active for the first time</description>
        <formula>AND(RecordType.DeveloperName = &apos;IATA_Airline&apos;, ISPICKVAL(ACLI_Status__c, &apos;Active Company&apos;), NOT(ISPICKVAL(PRIORVALUE(ACLI_Status__c), &apos;Inactive Company&apos;)), OR(ISCHANGED(ACLI_Status__c), ISCHANGED(RecordTypeId)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Airline Becomes Inactive</fullName>
        <actions>
            <name>Airline_Becomes_Inactive_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Sends a notification email when an airline becomes inactive</description>
        <formula>AND(  RecordType.DeveloperName = &apos;IATA_Airline&apos;,  ISCHANGED( ACLI_Status__c),  ISPICKVAL(PRIORVALUE(ACLI_Status__c), &apos;Active Company&apos;),  ISPICKVAL(ACLI_Status__c, &apos;Inactive Company&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Airline Becomes Re-Activated</fullName>
        <actions>
            <name>Airline_Becomes_Re_Activated_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Sends a notification email when an airline becomes re-activated</description>
        <formula>AND(  RecordType.DeveloperName = &apos;IATA_Airline&apos;,  ISCHANGED( ACLI_Status__c),  ISPICKVAL(PRIORVALUE(ACLI_Status__c), &apos;Inactive Company&apos;),  ISPICKVAL(ACLI_Status__c, &apos;Active Company&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Airline Designator Backup</fullName>
        <actions>
            <name>Airline_Designator_Backup</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the filed &apos;Airline Designator&apos; is changed in an Airline this process saves the old value in another field.
Previously it was done only for ACLI process but now it applies always, including manual changes.</description>
        <formula>AND(   OR(     RecordType.DeveloperName==&apos;IATA_Airline&apos;,     RecordType.DeveloperName==&apos;IATA_Airline_BR&apos;   ),   ISCHANGED(Airline_designator__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>FDS Coding AOC Expiry date alert 10 Days before</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Account.ACLI_Status__c</field>
            <operation>equals</operation>
            <value>Active Company</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.AOC_Expiry_Date__c</field>
            <operation>greaterThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Airline Headquarters</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.ACLI_SAP_Id__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>An update to start receiving notification and case 10 days before AOC expiry as a reminder.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>FDS_Coding_AOC_Expiry_date_alert_10_Days_before2</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Account.AOC_Expiry_Date__c</offsetFromField>
            <timeLength>-10</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>FDS Coding AOC Expiry date alert 30 days before</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Account.ACLI_Status__c</field>
            <operation>equals</operation>
            <value>Active Company</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.AOC_Expiry_Date__c</field>
            <operation>greaterThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Airline Headquarters</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.ACLI_SAP_Id__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>FDS Coding (Airline Management) - developped as part of changes for coding, Manuel G. - Used to alert a few users in the coding team, via email alert, than an AOC expiry date is approaching for the airline - business owner:  Ann Farrell</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>FDS_CodingAOC2</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Account.AOC_Expiry_Date__c</offsetFromField>
            <timeLength>-30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Send Irregularity Email</fullName>
        <actions>
            <name>Irregularity_Thresold_Met</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reset_irregularity_email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Send_Irregularity_Email__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Sends email when the account reaches the irregularity thresold for the country. This validation is made on the AccountTrigger trigger</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
