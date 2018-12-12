// *************************************
// Rémi de Jouvencel (sfdc)
// 27/01/2009
// Auto-Assign a case
// *************************************
global class AutoAssignmentEngineSF implements Database.Batchable<sObject> {

    global Iterable<sObject> start(Database.BatchableContext bc) {
        return getPendingCases();
    }

    global void execute(Database.BatchableContext BC, list<sObject> scope) {
        for (sObject c : scope)
            assignCase(c.Id);
    }

    global void finish(Database.BatchableContext BC) {

        try {
            AutoAssignmentEngineSF assignBatch = new AutoAssignmentEngineSF();

            //schedule the next batch
            System.scheduleBatch(assignBatch, 'AutoAssignmentBatch', 10, 10);

            AsyncApexJob a = [SELECT Id, Status, CompletedDate, JobItemsProcessed FROM AsyncApexJob WHERE Id = :BC.getJobId()];

            if (a != null && a.Status == 'Failed') {
                String mailSubject = 'AutoAssignmentEngine: Job failed!';
                String errorMessage = 'CompletedDate: ' + a.CompletedDate + 'Number of Cases processed: ' + a.JobItemsProcessed;

                emailAlert(mailSubject, errorMessage, getUserIds(getSupportEmails()));
            }

        } catch (Exception ex) {
            emailAlert('Auto Assignment Engine Exception', ex.getMessage() + ' ' + ex.getStackTraceString(), null, getUserIds(getSupportEmails()));
        }

    }

    public static List<Case> getPendingCases() {

        List<String> regionList = new List<String>();
        try {

            // if no System Settings are 'Active' and 'On', return null
            System_Settings__c[] syssets = [select Active__c, Region__c, Status__c, Workload_Weight__c, Skill_P3_Weighting__c, Skill_P2_Weighting__c, Skill_P1_Weighting__c, Open_Case_Workload_Weighting__c, In_Progress_Case_Workload_Weighting__c from System_Settings__c where Active__c = true and Status__c = 'On'];
            if (syssets.size() == 0) {
                return null;
            } else {

                for (System_Settings__c s : syssets)
                    regionList.add(s.Region__c);
            }
        } catch (Exception ex)   {
            String mailSubject = 'AutoAssignmentEngine: No System Settings were found!';
            String errorMessage = ex.getStackTraceString();

            List<ID> supportUserIDs = new List<ID>();

            supportUserIDs = getUserIds(getSupportEmails());
            emailAlert(mailSubject, errorMessage, supportUserIDs);

        }
        Auto_Queue__c[] aAutoQueue = [select Queue_ID__c from Auto_Queue__c where Active__c = true and Region__c in : regionList];
        set<Id> sAutoQueueId = new set<Id>();
        for (Auto_Queue__c a : aAutoQueue)
            sAutoQueueId.add(a.Queue_ID__c);

    case[] aCases=[select id, First_Business_Day__c from Case where status in ('Reopen', 'Open', 'Action Needed', 'In progress') AND RecordType.Name <> 'Invoicing_Collection_Cases' AND OwnerId in :sAutoQueueId ORDER BY CreatedDate ASC LIMIT 1000]; // RDJ:1000

        boolean isFirstBusinessDayInPast;
        List<Case> cId = new List<Case> {};
        for (Case c : aCases) {
            if (c.First_Business_Day__c != null) {
                if (System.currentTimeMillis() - c.First_Business_Day__c.getTime() >= 0)
                    isFirstBusinessDayInPast = true;
                else
                    isFirstBusinessDayInPast = false;
            } else
                //when first business day in missing we consider it for assignment
                isFirstBusinessDayInPast = true;

            if (isFirstBusinessDayInPast)
                cId.add(c);
        }

        return cId;
    }

    //--------------------------------
    // Assign a Case
    //--------------------------------
    public static string assignCase(string idCase) {
						
		System.debug('-------------------------');
        System.debug('Considering case: '+idCase);
        System.debug('-------------------------');
        try {
            String mailSubject = 'IATA Auto Assignment Error';

            //Need to get the IDs from the internal users to whom we want to send the email notifications
            List<ID> regionUserIDs =  new List<ID>();
            List<ID> supportUserIDs = new List<ID>();

            supportUserIDs = getUserIds(getSupportEmails());
            // ******************************
            // 1) Calculate Case Skills
            // ******************************
            // Retrieve Case fields
            List<Skill_Types__c> aSkillType = [select Name, Case_Location__c from Skill_Types__c where Case_Location__c not in ('Subject', 'Description', 'SuppliedEmail')];
            string soqlQuery = 'SELECT Id,Description, Subject,SuppliedEmail,CreatedDate, ownerid, Owner.Name, CaseNumber ';
            // changed on 2011-12:to avoid duplicate column 'ownerid' in select clause
            //for (Skill_Types__c skillType:aSkillType)
            //    soqlQuery+=','+skillType.Case_Location__c;
            soqlQuery += ' FROM Case WHERE id=\'' + idCase + '\'';
            Case caseToAssign;
            try {
                caseToAssign = Database.query(soqlQuery);
            } catch (Exception e) {

                String errorMessage = 'KO : Cannot retrieve information from CaseId: ' + idCase + '. Exception : ' + e.getMessage();
                emailAlert(mailSubject, errorMessage, supportUserIDs);

                return (errorMessage);
            }
            string caseRegion = '';
            System_Settings__c sysset = null;
            List<String> regionEmails = null;

            try { /*23Sept2013:Updated to add try-catch block*/
                // get region of the case via its assigned Auto_Queue
                Auto_Queue__c aq = [Select a.Name, a.Region__c, a.Queue_ID__c, a.Id From Auto_Queue__c a where Queue_ID__c = :caseToAssign.OwnerId limit 1];
                if (aq == null) {

                    String errorMessage = 'KO : Cannot retrieve Auto_Queue__c for caseid ' + idCase + ' having OwnerId ' + caseToAssign.OwnerId;
                    emailAlert(mailSubject, errorMessage, supportUserIDs);

                    return (errorMessage);

                }

                caseRegion = aq.Region__c;

                // get the System Settings for the case region
                System_Settings__c[] syssets = [select Active__c, Workload_Weight__c, Skill_P3_Weighting__c, Skill_P2_Weighting__c, Skill_P1_Weighting__c, Open_Case_Workload_Weighting__c, In_Progress_Case_Workload_Weighting__c, Email_on_Error__c from System_Settings__c where Active__c = true and Region__c = :caseRegion LIMIT 1];
                if (syssets.size() == 0) {

                    String errorMessage = 'KO : Cannot retrieve System_Settings__c for region ' + caseRegion;
                    emailAlert(mailSubject, errorMessage, supportUserIDs);

                    return (errorMessage);
                } else {
                    sysset = syssets[0];
                    regionEmails = parseEmails(sysset.Email_on_Error__c);
                    regionUserIDs = getUserIds(regionEmails);
                }
            } catch (Exception e) {
                String errorMessage = 'KO : Cannot retrieve Auto_Queue__c for caseid ' + idCase + ' having OwnerId ' + caseToAssign.OwnerId + ' Exception : ' + e.getMessage();
                emailAlert(mailSubject, errorMessage, supportUserIDs);

                return (errorMessage);
            }


            system.debug('************************************');
            system.debug('CASE Skills');
            system.debug('************************************');
            // get list of all Skills
            List<Skill__c> aSkills =  [select Name, Skill_Types__r.Name, Skill_Types__r.Case_Location__c  from Skill__c];
            List<Skill__c> aSkillsOnCase = new List<Skill__c>();
            for (Skill__c skill : aSkills) {
                string skillOnCase = (String)caseToAssign.get(skill.Skill_Types__r.Case_Location__c);
                if (skillOnCase != null && skillOnCase == skill.Name) {
                    aSkillsOnCase.add(skill);
                    System.debug('Skill :' + skill.Name);
                }
            }

            // ******************************
            // 2) Calculate Agents Workload
            // ******************************
            Agents__c[] aAgents = [select User__r.Name, id, Last_Case_Assigned_Date_Time__c, Next_case_request_date_time__c, Maximum_case_workload__c from Agents__c where Logged_on__c = true];
            if (aAgents.size() == 0) {

                String errorMessage = 'KO : No agents available (all logged off) for region ' + caseRegion + '.\n Case Number: ' + caseToAssign.CaseNumber + ' Case Owner: ' + caseToAssign.Owner.Name + ' Opened Date: ' + caseToAssign.CreatedDate;
                emailAlert(mailSubject, errorMessage, regionUserIDs, null);

                return (errorMessage);
            }

            set<Id> sUserId = new set<Id>();
            map<Id, double> m_agentWorkload = new map<Id, double>();
            for (Agents__c a : aAgents) {
                sUserId.add(a.User__c);
                m_agentWorkload.put(a.User__c, 0); // Set default workload to 0
            }

            // ********************************************************************
            // 2BIS) Check if the same case has already be asigned to one agent
            // (Duplicate, don't even check the workload)
            // ********************************************************************
            Datetime MinComparedttm = (caseToAssign).CreatedDate.addMinutes(-10);
            Datetime MaxComparedttm = (caseToAssign).CreatedDate.addMinutes(+10);
            Case[] dupCase = [select Id, OwnerId, Owner.Name, CaseNumber from Case where Id<>:caseToAssign.Id and Subject = :caseToAssign.Subject and SuppliedEmail = :caseToAssign.SuppliedEmail and CreatedDate > :MinComparedttm and CreatedDate < :MaxComparedttm and OwnerId in :sUserId LIMIT 1];
            if (dupCase.size() > 0) {
                if (caseToAssign.Description == null)
                    caseToAssign.Description = ' ';
                caseToAssign.Description +=  '\n(Tagged as duplicate of Case ' + dupCase[0].CaseNumber + ' - https://iata.my.salesforce.com/' + dupCase[0].Id + ')';
                caseToAssign.OwnerId = dupCase[0].OwnerId;
                try {
                    update caseToAssign;
                    system.debug('Tagged as duplicate of Case ' + dupCase[0].CaseNumber);

                    String infoMessage = 'OK : Duplicate Case of ' + dupCase[0].Id + ', assigned to ' + dupCase[0].Owner.Name;
                    return (infoMessage);
                } catch (Exception e) {
                    String errorMessage = 'KO : Cannot update duplicate case.\n Case Number: ' + caseToAssign.CaseNumber + ' Case Owner: ' + caseToAssign.Owner.Name + ' Opened Date: ' + caseToAssign.CreatedDate;
                    emailAlert(mailSubject, errorMessage, regionUserIDs, null);

                    return (errorMessage);
                }
            }


            for (Case[] aCase : [select id, OwnerId, status from Case where OwnerId in :sUserId and Status in ('Open', 'In Progress', 'Reopen', 'Action Needed', 'Escalated Internally', 'Escalated Externally', 'Pending customer') and RecordType.Name <> 'Invoicing_Collection_Cases'])
                for (Case c : aCase) {

                    double currentWorkload = m_agentWorkload.get(c.OwnerId);

                    //in case the case owner changed and the workload is null
                    if (currentWorkload != null) {

                        if (c.Status == 'Open' || c.Status == 'In Progress' || c.Status == 'Reopen' || c.Status == 'Action Needed')
                            currentWorkload += sysset.Open_Case_Workload_Weighting__c;
                        if (c.Status == 'Escalated Internally' || c.Status == 'Escalated Externally' || c.Status == 'Pending customer')
                            currentWorkload += sysset.In_Progress_Case_Workload_Weighting__c;

                        m_agentWorkload.put(c.OwnerId, currentWorkload);
                    }
                }

            //-----------------------------------------------------------------
            // Eliminate agents with too much workload
            //-----------------------------------------------------------------
            system.debug('************************************');
            system.debug('WORKLOAD for Active agents');
            system.debug('************************************');

            for (integer i = aAgents.size() - 1; i >= 0; i--) {
                Agents__c a = aAgents[i];
                system.debug('** Agent ' + a.User__r.Name + ' **');
                system.debug('-- Workload =' + m_agentWorkload.get(a.user__c) + '/Maximum case workload=' + a.Maximum_case_workload__c );
                system.debug('-- Next case request =' + a.Next_case_request_date_time__c );
                // Eliminate agents with to much workload
                if (a.Next_case_request_date_time__c == null && (m_agentWorkload.get(a.user__c) >= a.Maximum_case_workload__c)  ) {
                    system.debug('==> Too much workload, remove this agent');
                    aAgents.remove(i);
                }
            }
            if (aAgents.size() == 0) {

                String errorMessage = 'KO : No agent available (Workload is full).\n Case Number: ' + caseToAssign.CaseNumber + ' Case Owner: ' + caseToAssign.Owner.Name + ' Opened Date: ' + caseToAssign.CreatedDate;
                emailAlert(mailSubject, errorMessage, regionUserIDs, null);

                return (errorMessage);
            }

            // ******************************
            // 3) Calculate Agent Skills
            // ******************************
            map<Id, list<Skill_Assignment__c>> mAgentSkills = new map <Id, list<Skill_Assignment__c>>();
            map<Id, Double> mAgentSkillMark = new map <Id, Double>();
            set<Id> sAgentId = new set<Id>();
            for (Agents__c a : aAgents) {
                sAgentId.add(a.Id);
                mAgentSkills.put(a.Id, new list<Skill_Assignment__c>());
                mAgentSkillMark.put(a.Id, 0);
            }
            for (Skill_Assignment__c[] aSkillAssignment : [select agents__c, skills__c, skills__r.Skill_Types__r.Skill_Weight__c, skills__r.Name, priority__c from Skill_Assignment__c where agents__c in :sAgentId and skills__c in :aSkillsOnCase])
                for (Skill_Assignment__c skillAssignment : aSkillAssignment) {
                    //+++++++++++++++++++++++++++++++
                    // Skills Mark Calculations
                    //+++++++++++++++++++++++++++++++
                    Double AgentSkillMark = mAgentSkillMark.get(skillAssignment.agents__c);

                    if (skillAssignment.priority__c == '1')
                        AgentSkillMark += sysset.Skill_P1_Weighting__c * skillAssignment.skills__r.Skill_Types__r.Skill_Weight__c;
                    if (skillAssignment.priority__c == '2')
                        AgentSkillMark += sysset.Skill_P2_Weighting__c * skillAssignment.skills__r.Skill_Types__r.Skill_Weight__c;
                    if (skillAssignment.priority__c == '3')
                        AgentSkillMark += sysset.Skill_P3_Weighting__c * skillAssignment.skills__r.Skill_Types__r.Skill_Weight__c;
                    if (skillAssignment.priority__c != '0') {
                        mAgentSkills.get(skillAssignment.agents__c).add(skillAssignment);
                        mAgentSkillMark.put(skillAssignment.agents__c, AgentSkillMark);
                    }
                }
            //-----------------------------------------------------------------
            // Eliminate Agents with not enough skills
            //-----------------------------------------------------------------
            system.debug('************************************');
            system.debug('AGENT Skills');
            system.debug('************************************');
            for (integer i = aAgents.size() - 1; i >= 0; i--) {
                Agents__c a = aAgents[i];
                system.debug('** Agent ' + a.User__r.Name + ' **');

                for (Skill_Assignment__c s : mAgentSkills.get(a.Id))
                    system.debug('-- Skill ' + s.skills__r.Name + ' / Priority=' + s.priority__c + '  / Skill Weight=' + s.skills__r.Skill_Types__r.Skill_Weight__c);

                system.debug('-- Number of skills related to the Case =' + mAgentSkills.get(a.Id).size());
                system.debug('-- Number of skills on Case =' + aSkillsOnCase.size() );

                // Eliminate agents with not enough skill
                if (mAgentSkills.get(a.Id).size() != aSkillsOnCase.size() ) {
                    system.debug('==> Not enough skills, remove this agent');
                    aAgents.remove(i);
                }
            }
            if (aAgents.size() == 0) {
                String errorMessage = 'KO : No agent available (No agent has enough skills).\n Case Number: ' + caseToAssign.CaseNumber + ' Case Owner: ' + caseToAssign.Owner.Name + ' Opened Date: ' + caseToAssign.CreatedDate;
                emailAlert(mailSubject, errorMessage, regionUserIDs, null);
                return (errorMessage);
            }


            // **************************************************************
            // 4) Find the Best Agent
            // If 2 users have the same priority, chek the last assigned case
            // **************************************************************
            double highestPriority = -99999;
            double highestSkill = 0;
            map<Id, Double> mAgentPriority = new map <Id, Double>();
            Agents__c bestAgent = null;
            for (Agents__c a : aAgents) {
                system.debug('** Agent ' + a.User__r.Name + ' **');
                // Calculate Priority
                mAgentPriority.put(a.id, mAgentSkillMark.get(a.id) + sysset.Workload_Weight__c * (0 - m_agentWorkload.get(a.user__c)));
                //--------------------------------------------------------------------------------------------------------------------------------------------------------------------
                system.debug('-- Skill Mark = ' + mAgentSkillMark.get(a.id));
                system.debug('-- Workload Mark = ' + (0 - m_agentWorkload.get(a.user__c)) * sysset.Workload_Weight__c);
                system.debug('-- PRIORITY = ' + mAgentPriority.get(a.id));
                system.debug('-- Last Case Assigned Date = ' + a.Last_Case_Assigned_Date_Time__c);

                if (highestSkill <= mAgentSkillMark.get(a.id))
                    highestSkill = mAgentSkillMark.get(a.id);

                if (highestPriority <= mAgentPriority.get(a.id)) {
                    if ( (bestAgent == null) || (highestPriority < mAgentPriority.get(a.id)) ) bestAgent = a;
                    else if (bestAgent.Last_Case_Assigned_Date_Time__c > a.Last_Case_Assigned_Date_Time__c)
                        bestAgent = a;
                    highestPriority = mAgentPriority.get(a.id);
                }
            }
            if (highestSkill == 0) {
                String errorMessage = 'KO: No Skill => Leave on Queue. Case Id: ' + idCase + '\n Case Number: ' + caseToAssign.CaseNumber + ' Case Owner: ' + caseToAssign.Owner.Name + ' Opened Date: ' + caseToAssign.CreatedDate;
                emailAlert(mailSubject, errorMessage, regionUserIDs, null);
                return (errorMessage);
            }

            system.debug('************************************');
            system.debug('BEST AGENT - Case Assignment');
            system.debug('************************************');
            system.debug('====>' + bestAgent.User__r.Name);
            try {
                caseToAssign.OwnerId = bestAgent.User__c;
                bestAgent.Next_case_request_date_time__c = null;
                bestAgent.Last_Case_Assigned_Date_Time__c = system.now();
                update caseToAssign;
                update bestAgent;

                String infoMessage = 'OK - Case assigned to ' + bestAgent.User__r.Name + '=> New Workload=' + (m_agentWorkload.get(bestAgent.user__c) + sysset.Open_Case_Workload_Weighting__c + ', Priority=' + highestPriority);

                return (infoMessage);
            } catch (DMLException e) {
                String errorMessage = 'KO - ' + e.getDMLMessage(0) + '\n Case Number: ' + caseToAssign.CaseNumber + ' Case Owner: ' + caseToAssign.Owner.Name + ' Opened Date: ' + caseToAssign.CreatedDate;
                emailAlert(mailSubject, errorMessage, regionUserIDs, null);
                return (errorMessage);
            }
        }//try
        catch (Exception e) {

            TransformationHelper.sendEmailSupport('AutoAssignmentEngineSF', e.getMessage() + '   '  + e.getStacktraceString());
            return null;
        }
    }

    //Email alert for salesforce support team or the region defined emails in the system settings
    //Because region emails may not be retrieved in some situations, the salesforce support team emails will be used
    private static void emailAlert(String mailSubject, String mailBody, List<ID> regUserIDs, List<ID> supUserIDs) {

        List<ID> emailUsers = new List<ID>();

        if (regUserIDs != null && regUserIDs.size() > 0)
            emailUsers = regUserIDs;
        else if (supUserIDs != null && supUserIDs.size() > 0)
            emailUsers = supUserIDs;


        if (emailUsers.size() > 0)
            sendMessageToUsers(mailSubject, mailBody , emailUsers);
        else
            System.debug('No emails defined!');

    }

    private static void emailAlert(String mailSubject, String mailBody, List<ID> supUserIDs) {
        emailAlert(mailSubject, mailBody, null, supUserIDs);
    }

    private static List<String> parseEmails(String regionEmails) {

        List<String> emails = new List<String>();

        if (regionEmails != null && regionEmails.length() > 0)
            for (String email : regionEmails.split(';', 0)) {
                if (validateEmail(email))
                    emails.add(email);
            }

        return emails;
    }

    public static Boolean validateEmail(String email) {

        Boolean res = true;

        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        // source: <a href="http://www.regular-expressions.info/email.html" target="_blank">http://www.regular-expressions.info/email.html</a>
        Pattern MyPattern = Pattern.compile(emailRegex);

        Matcher MyMatcher = MyPattern.matcher(email);

        if (!MyMatcher.matches())
            res = false;
        return res;
    }

    public static void sendMessageToUsers(String title, String message, List<ID> userIDs) {

        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        try {
            system.debug('Try to send message . ' + title + ' ******  ' + message);


            for (ID userId : userIDs) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(userId);
                mail.setSubject(title);
                mail.setSaveAsActivity(false);
                mail.setPlainTextBody(message);
                emailsToSend.add(mail);
            }

            Messaging.sendEmail(emailsToSend);

        } catch (Exception  e) {
            system.debug('Failed to send email to users');
        }

    }

    //Get the internal user IDs to whom we want to send the emails
    private static List<ID> getUserIds(List<String> users) {
        List<ID> userIDs = new List<ID>();

        if (users != null && users.size() > 0) {
            User[] userList = [select ID from User where Email in : users];
            for (User user : userList)
                userIDs.add(user.Id);
        }

        return userIDs;
    }

    private static List<String> getSupportEmails() {
        List<String> supEmails = new List<String>();
        for (SalesforceSupportEmails__c email : SalesforceSupportEmails__c.getAll().values())
            supEmails.add(email.Support_Email__c);

        return supEmails;
    }

}