<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_on_Operational_Improvement_Creation</fullName>
        <description>Notify on Operational Improvement Creation</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quality/OI_Creation_Notification</template>
    </alerts>
    <alerts>
        <fullName>OI_Approval_notification</fullName>
        <description>OI Approval notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quality/OI_Approved_by_RPM</template>
    </alerts>
    <alerts>
        <fullName>OI_Approved_by_RPM</fullName>
        <description>OI Approved by RPM</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quality/OI_Approved_by_RPM</template>
    </alerts>
    <alerts>
        <fullName>OI_Extension_Approved_by_RPM</fullName>
        <description>OI Extension Approved by RPM</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quality/OI_Extension_Approved_by_RPM</template>
    </alerts>
    <alerts>
        <fullName>OI_Extension_Rejected_by_RPM</fullName>
        <description>OI Extension Rejected by RPM</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quality/OI_Extension_Rejected_by_RPM</template>
    </alerts>
    <alerts>
        <fullName>OI_Rejected_by_RPM</fullName>
        <description>OI Rejected by RPM</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quality/OI_Rejected_by_RPM</template>
    </alerts>
    <fieldUpdates>
        <fullName>Auto_fill_OI_subject</fullName>
        <description>used to fill in CPS issue check subject with a standard naming convention</description>
        <field>Subject__c</field>
        <formula>TEXT(Region__c) &amp; &quot; - &quot; &amp; TEXT(  OperationCPS__c ) &amp; &quot; - &quot; &amp; text(Country__c) &amp; &quot; - &quot;  &amp; &quot; - &quot; &amp; TEXT(YEAR( Reporting_Month__c )) &amp; &quot;/&quot; &amp; IF(MONTH(Reporting_Month__c)&lt;10,&quot;0&quot;&amp; TEXT(MONTH(Reporting_Month__c)),TEXT(MONTH(Reporting_Month__c))) &amp; &quot; - &quot; &amp; TEXT( Issue_Categorization__c )&amp; &quot; - &quot; &amp;TEXT( Issue_Sub_Category__c ) &amp; &quot; - USD &quot; &amp; TEXT( ROUND( Amount_USD_auto__c, 2 ) )</formula>
        <name>Auto fill OI subject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OI_Status_WF</fullName>
        <description>Update field Status WF</description>
        <field>OI_Status_WF__c</field>
        <formula>IF(NOT(ISNULL(Date_Time_Closed__c)), &quot;Closed&quot;,
IF(NOT(ISNULL(Terminated_Date__c)),&quot;Terminated&quot;,
IF(NOT(ISNULL(Conclusion_Date__c)),&quot;Concluded&quot;,
IF(NOT(ISNULL(Submission_for_extension_date__c)),
	IF(NOT(ISNULL(Extension_approved_date__c)),
		&quot;Extended Delayed&quot;,
		IF(NOT(ISNULL(Extension_rejected_date__c)),
			&quot;Ongoing Action Plan Delayed&quot;,
			&quot;Pending Extension Approval Delayed&quot;
		)
	),
IF(NOT(ISNULL(Submission_for_Approval_Date__c)),
	IF(ISNULL(OI_Approval_date__c),
		&quot;Pending Approval Delayed&quot;,
		&quot;Ongoing Action Plan Delayed&quot;
	),
	&quot;Investigation Delayed&quot;
)))))</formula>
        <name>OI Status WF</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OI_Submitted_for_approval</fullName>
        <field>Submission_for_Approval_Date__c</field>
        <formula>now()</formula>
        <name>OI Submitted for approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OI_Submitted_for_extension</fullName>
        <description>Updates Submission for extension date field to start Extension for approval process</description>
        <field>Submission_for_extension_date__c</field>
        <formula>now()</formula>
        <name>OI Submitted for extension</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OI_Update_Approval_date</fullName>
        <field>OI_Approval_date__c</field>
        <formula>NOW()</formula>
        <name>OI Update Approval date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OI_Update_Extension_Approval_date</fullName>
        <description>Update Extension approved date field to finish the Extension approval process</description>
        <field>Extension_approved_date__c</field>
        <formula>NOW()</formula>
        <name>OI Update Extension Approval date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OI_Update_Extension_Rejection_date</fullName>
        <description>Update OI extension Rejection field</description>
        <field>Extension_rejected_date__c</field>
        <formula>TODAY()</formula>
        <name>OI Update Extension Rejection date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_approval_date_OI</fullName>
        <description>used to reset the approval date of the Oi for CPS issues whenever data from the object is changed.</description>
        <field>OI_Approval_date__c</field>
        <name>Reset approval date OI</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Terminate_OI</fullName>
        <description>Set today as Termination Date to set the status as Terminated</description>
        <field>Terminated_Date__c</field>
        <formula>TODAY()</formula>
        <name>Terminate OI</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Date_Time_Closed</fullName>
        <field>Date_Time_Closed__c</field>
        <formula>NOW()</formula>
        <name>Update Date/Time Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>X_rate_CPS_checks_OI</fullName>
        <description>This workflow is used to enter the yearly USD exchange rates that are used by CPS</description>
        <field>Exchange_rate__c</field>
        <formula>case(text(Currency__c),&quot;AED&quot;,3.6728,&quot;AFN&quot;,75.1,&quot;ALL&quot;,107.29,&quot;AMD&quot;,482.5,&quot;ANG&quot;,1.77,&quot;AOA&quot;,307.055,&quot;ARS&quot;,37.619,&quot;AUD&quot;,1.4176,&quot;AWG&quot;,1.78,&quot;AZN&quot;,1.693,&quot;BAM&quot;,1.7051,&quot;BBD&quot;,1.9801,&quot;BDT&quot;,83.13,&quot;BGN&quot;,1.7052,&quot;BHD&quot;,0.3767,&quot;BIF&quot;,1788.4,&quot;BMD&quot;,1,&quot;BND&quot;,1.3627,&quot;BOB&quot;,6.86,&quot;BRL&quot;,3.8804,&quot;BSD&quot;,1,&quot;BTN&quot;,69.79,&quot;BWP&quot;,10.6838,&quot;BYN&quot;,2.162,&quot;BZD&quot;,1.9982,&quot;CAD&quot;,1.2957,&quot;CDF&quot;,1622,&quot;CHF&quot;,0.9444,&quot;CLP&quot;,692.85,&quot;CNH&quot;,6.8344,&quot;CNY&quot;,6.8344,&quot;COP&quot;,3245,&quot;CRC&quot;,603.5,&quot;CUP&quot;,1,&quot;CVE&quot;,96.13,&quot;CZK&quot;,22.415,&quot;DJF&quot;,177.5,&quot;DKK&quot;,6.5107,&quot;DOP&quot;,50.2,&quot;DZD&quot;,118.1048,&quot;EGP&quot;,17.86,&quot;ETB&quot;,27.9203,&quot;EUR&quot;,0.8341,&quot;FJD&quot;,2.1079,&quot;FKP&quot;,0.7883,&quot;GBP&quot;,0.7836,&quot;GEL&quot;,2.66,&quot;GHS&quot;,4.82,&quot;GIP&quot;,0.7883,&quot;GMD&quot;,50.1,&quot;GNF&quot;,9080,&quot;GTQ&quot;,7.715,&quot;GYD&quot;,207.35,&quot;HKD&quot;,7.8315,&quot;HNL&quot;,24.2652,&quot;HRK&quot;,6.4601,&quot;HTG&quot;,76.8102,&quot;HUF&quot;,279.73,&quot;IDR&quot;,14375,&quot;ILS&quot;,3.7355,&quot;INR&quot;,69.56,&quot;IQD&quot;,1186.43,&quot;IRR&quot;,42000,&quot;ISK&quot;,116.02,&quot;JMD&quot;,126.5,&quot;JOD&quot;,0.7092,&quot;JPY&quot;,109.56,&quot;KES&quot;,101.8,&quot;KGS&quot;,69.7,&quot;KHR&quot;,3992.004,&quot;KMF&quot;,428.5,&quot;KPW&quot;,130,&quot;KRW&quot;,1113.3,&quot;KWD&quot;,0.3031,&quot;KYD&quot;,0.825,&quot;KZT&quot;,384.07,&quot;LAK&quot;,8542,&quot;LBP&quot;,1505.7,&quot;LKR&quot;,182.6,&quot;LRD&quot;,156.71,&quot;LSL&quot;,14.35,&quot;LYD&quot;,1.3875,&quot;MAD&quot;,9.5558,&quot;MDL&quot;,16.993,&quot;MKD&quot;,53.52,&quot;MMK&quot;,1540,&quot;MNT&quot;,2617,&quot;MOP&quot;,8.063,&quot;MRU&quot;,36.423,&quot;MUR&quot;,34.15,&quot;MVR&quot;,15.42,&quot;MWK&quot;,719.77,&quot;MXN&quot;,19.6403,&quot;MYR&quot;,4.13,&quot;MZN&quot;,61.35,&quot;NAD&quot;,14.346,&quot;NGN&quot;,364.44,&quot;NIO&quot;,32.4,&quot;NOK&quot;,8.6387,&quot;NPR&quot;,111.63,&quot;NZD&quot;,1.4879,&quot;OMR&quot;,0.3848,&quot;PAB&quot;,1,&quot;PEN&quot;,3.368,&quot;PGK&quot;,3.2841,&quot;PHP&quot;,52.47,&quot;PKR&quot;,138.6,&quot;PLN&quot;,3.7397,&quot;PYG&quot;,5948,&quot;QAR&quot;,3.6405,&quot;RON&quot;,4.0561,&quot;RSD&quot;,103.07,&quot;RUB&quot;,69.68,&quot;RWF&quot;,892.2429,&quot;SAR&quot;,3.7509,&quot;SBD&quot;,8.2919,&quot;SCR&quot;,13.55,&quot;SDG&quot;,47.4992,&quot;SEK&quot;,8.8524,&quot;SGD&quot;,1.3515,&quot;SHP&quot;,0.7849,&quot;SLL&quot;,8625,&quot;SOS&quot;,575,&quot;SRD&quot;,7.43,&quot;STN&quot;,21.45,&quot;SVC&quot;,8.7495,&quot;SYP&quot;,515,&quot;SZL&quot;,14.3235,&quot;THB&quot;,32.33,&quot;TND&quot;,2.9883,&quot;TOP&quot;,2.1725,&quot;TRY&quot;,5.2877,&quot;TTD&quot;,6.782,&quot;TWD&quot;,30.563,&quot;TZS&quot;,2295,&quot;UAH&quot;,27.7,&quot;UGX&quot;,3699.3,&quot;USD&quot;,1,&quot;UYU&quot;,32.4,&quot;UZS&quot;,8331.22,&quot;VES&quot;,636.5846,&quot;VND&quot;,23190,&quot;VUV&quot;,111.69,&quot;WST&quot;,2.5349,&quot;XAF&quot;,604,&quot;XCD&quot;,2.7,&quot;XOF&quot;,569.22,&quot;XPF&quot;,103.51,&quot;YER&quot;,249.95,&quot;ZAR&quot;,14.3473,&quot;ZMW&quot;,11.91,&quot;ZWD&quot;,378,0)</formula>
        <name>X-rate CPS checks (OI)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Auto fill subject</fullName>
        <actions>
            <name>Auto_fill_OI_subject</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Operational_Improvements__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CPS Checks</value>
        </criteriaItems>
        <description>fill in the subject of CPS OI as per agreed convention</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify on OI creation</fullName>
        <actions>
            <name>Notify_on_Operational_Improvement_Creation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Operational_Improvements__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>OI CPS checks x rate update</fullName>
        <actions>
            <name>X_rate_CPS_checks_OI</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>updates the x rate used by CPS when the CPS check object is created or the currency is changed.</description>
        <formula>AND(RecordType.DeveloperName = &quot;CPS_Checks&quot;, OR( isblank(Exchange_rate__c), ischanged( Currency__c )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reset approval date</fullName>
        <actions>
            <name>Reset_approval_date_OI</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>sets the approval date as blank when certain parameters of the CPS issue are edited. since they require further approval.</description>
        <formula>and( RecordType.DeveloperName = &quot;CPS_Checks&quot;,  OR ( ISNEW(), ischanged(Issue_Categorization__c ),  ISCHANGED( Issue_Sub_Category__c ),  ISCHANGED( Amount_LC__c ),  ISCHANGED( Back_Valued__c ) ,  ISCHANGED( OperationCPS__c ),  ISCHANGED( Country__c ),  ISCHANGED( Region__c ),  ISCHANGED (Currency__c),   ISCHANGED(Back_Valuation_Date__c),  ISCHANGED(Back_Valuation_Reporting_Month__c),  ISCHANGED(Reporting_Month__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update OI Status</fullName>
        <actions>
            <name>OI_Status_WF</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Fills the field &apos;OI Status (WF)&apos; with current calculated status</description>
        <formula>OR(	ISNEW(), 	AND(NOT(ISNEW()), 		OR( 			ISCHANGED(Date_Time_Closed__c), 			ISCHANGED(Extension_approved_date__c), 			ISCHANGED(Submission_for_extension_date__c), 			ISCHANGED(Submission_for_Approval_Date__c), 			ISCHANGED(Overall_Deadline__c), 			ISCHANGED(Pending_eff_validation_date__c), 			ISCHANGED(Terminated_Date__c), 			ISCHANGED(OI_Approval_date__c), 			ISCHANGED(Conclusion_Date__c), 			ISCHANGED(Extension_rejected_date__c) 		) 	) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
