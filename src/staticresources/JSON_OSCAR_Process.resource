{ 
  "AMS_OSCAR_JSON": {
    "Processes": [
      {
        "Name": "NEW.HO.1.0",
        "Flows": [
          {
            "Name": "AMS_OSCAR_APPLICATIONRECEIPT",
            "Steps": [
              {
                "Name": "STEP6",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_failed"
                  }
                ],
                "DisplayFields": [
          "Is_PCI_compliant__c",
          "ANG_PCI_compliance_expiry_date__c",
                  "STEP6__c"          
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_MASTERDATA",
            "Steps": [
              {
                "Name": "STEP10",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "generateIataCode",
                    "ActionLabel": "AMS_OSCAR_Action1",
                    "args": [
                      "agencyid",
                      "accreditationid",
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step10_succeeded"
                  }
                ],
                "DisplayFields": [
                  "STEP10__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_ANTIMONEYLAUNDERING",
            "Steps": [
              {
                "Name": "STEP17",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "performAML",
                    "ActionLabel": "AMS_OSCAR_Action4",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_inProgress"
                  },
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_failed"
                  }
                ],
                "DisplayFields": [
                  "STEP17__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_AGENCYFEES",
            "Steps": [
              {
                "Name": "STEP8",
                "Required": [
                  "STEP6"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step8_succeeded"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step8_inProgress"
                  }
                ],
                "DisplayFields": [
                  "Billing_Document_Number__c",
                  "Send_invoice__c",
                  "Issue_billing_document__c",
                  "STEP8__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP9",
                "Required": [
                  "STEP6"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "STEP9__c"
                ],
                "IsDependent": true
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APPLICATIONPROCESSING",
            "Steps": [
              {
                "Name": "STEP11",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "createIFAP",
                    "ActionLabel": "AMS_OSCAR_Action3",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step11_inProgress"
                  }
                ],
                "DisplayFields": [
                  "STEP11__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP12",
                "Required": [
                  "STEP8",
                  "STEP9"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step12_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step12_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step12_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Bank_Guarantee_amount__c",
                  "Bank_Guarantee_Currency__c",
                  "Send_FS_request__c",
                  "STEP12__c"
                ],
                "IsDependent": true
              },
              {
                "Name": "STEP13",
                "Required": [
                  "STEP8",
                  "STEP9"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_failed"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_inProgress"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Send_inspection_request__c",
                  "STEP13__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP14",
                "Required": [
                  "STEP8",
                  "STEP9"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_succeeded"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_inProgress"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_failed"
                  }
                ],
                "DisplayFields": [
                  "Send_agreement__c",
                  "STEP14__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_VALIDATION",
            "Steps": [
              {
                "Name": "STEP15",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step15_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step15_failed"
                  }
                ],
                "DisplayFields": [
                  "Comments_validate__c",
                  "Validation_Status__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APPROVAL",
            "Steps": [
              {
                "Name": "STEP2",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step2_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step2_failed"
                  }
                ],
                "DisplayFields": [
                  "RPM_Approval__c",
                  "Comments_approval__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP1",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Update_DPC__c",
                  "Update_IRIS__c",
                  "Update_BSPLink_CASSLink__c",
                  "Update_Portal_Setup__c",
                  "Send_approval_letter__c",
                  "Welcome_pack__c",
                  "Off_site_storage__c",
                  "Welcome_call__c",
                  "Country_Specifics_Approval__c",
                  "Update_AIMS_Approval__c",
                  "Change_effective_as_of__c",
                  "STEP1__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_DISAPPROVAL",
            "Steps": [
              {
                "Name": "STEP3",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_disapproval_pack__c",
                  "Issue_credit_note_if_applicable__c",
                  "Release_FS_if_applicable__c",
                  "Country_Specifics_Disapproval__c",
                  "Update_AIMS_Disapproval__c",
                  "Close_IFAP_Disapproval__c",
                  "Cancel_Inspection_Requests_Disapproval__c",
                  "STEP3__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_REJECTION_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP18",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_rejection_notification_pack__c",
                  "Country_Specifics_Rejection__c",
                  "Update_AIMS_Rejection__c",
                  "Close_IFAP_Rejection__c",
                  "Cancel_Inspection_Requests_Rejection__c",
                  "AMS_Rejection_Withdrawal_remarks__c",
                  "STEP18__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_REJECTION_WITHDRAWAL",
            "Steps": [
              {
                "Name": "STEP4",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_Withdrawal_notification__c",
                  "Issue_credit_note_withdrawal__c",
                  "Release_FS_withdrawal__c",
                  "STEP4__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_RECONSIDERATION",
            "Steps": [
              {
                "Name": "STEP5",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "STEP5__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "NEW.BR",
        "Flows": [
          {
            "Name": "AMS_OSCAR_APPLICATIONRECEIPT",
            "Steps": [
              {
                "Name": "STEP6",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_failed"
                  }
                ],
                "DisplayFields": [
          "Is_PCI_compliant__c",
          "ANG_PCI_compliance_expiry_date__c",
                  "STEP6__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_MASTERDATA",
            "Steps": [
              {
                "Name": "STEP10",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "generateIataCode",
                    "ActionLabel": "AMS_OSCAR_Action1",
                    "args": [
                      "agencyid",
                      "accreditationid",
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step10_succeeded"
                  }
                ],
                "DisplayFields": [
                  "STEP10__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_AGENCYFEES",
            "Steps": [
              {
                "Name": "STEP8",
                "Required": [
                  "STEP6"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step8_succeeded"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step8_inProgress"
                  }
                ],
                "DisplayFields": [
                  "Billing_Document_Number__c",
                  "Send_invoice__c",
                  "Issue_billing_document__c",
                  "STEP8__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP9",
                "Required": [
                  "STEP6"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "STEP9__c"
                ],
                "IsDependent": true
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APPLICATIONPROCESSING",
            "Steps": [
              {
                "Name": "STEP11",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "createIFAP",
                    "ActionLabel": "AMS_OSCAR_Action3",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step11_inProgress"
                  }
                ],
                "DisplayFields": [
                  "STEP11__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP12",
                "Required": [
                  "STEP8",
                  "STEP9"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step12_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step12_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step12_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Bank_Guarantee_amount__c",
                  "Bank_Guarantee_Currency__c",
                  "Send_FS_request__c",
                  "STEP12__c"
                ],
                "IsDependent": true
              },
              {
                "Name": "STEP13",
                "Required": [
                  "STEP8",
                  "STEP9"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_failed"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_inProgress"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Send_inspection_request__c",
                  "STEP13__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP14",
                "Required": [
                  "STEP8",
                  "STEP9"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_succeeded"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_inProgress"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_failed"
                  }
                ],
                "DisplayFields": [
                  "Send_agreement__c",
                  "STEP14__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_VALIDATION",
            "Steps": [
              {
                "Name": "STEP15",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step15_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step15_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step15_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Comments_validate__c",
                  "Validation_Status__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APPROVAL",
            "Steps": [
              {
                "Name": "STEP2",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step2_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step2_failed"
                  }
                ],
                "DisplayFields": [
                  "RPM_Approval__c",
                  "Comments_approval__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP1",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Update_DPC__c",
                  "Update_IRIS__c",
                  "Update_BSPLink_CASSLink__c",
                  "Update_Portal_Setup__c",
                  "Send_approval_letter__c",
                  "Welcome_pack__c",
                  "Off_site_storage__c",
                  "Welcome_call__c",
                  "Country_Specifics_Approval__c",
                  "Update_AIMS_Approval__c",
                  "Change_effective_as_of__c",
                  "STEP1__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_DISAPPROVAL",
            "Steps": [
              {
                "Name": "STEP3",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_disapproval_pack__c",
                  "Issue_credit_note_if_applicable__c",
                  "Release_FS_if_applicable__c",
                  "Country_Specifics_Disapproval__c",
                  "Update_AIMS_Disapproval__c",
                  "Close_IFAP_Disapproval__c",
                  "Cancel_Inspection_Requests_Disapproval__c",
                  "STEP3__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_REJECTION_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP18",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_rejection_notification_pack__c",
                  "Country_Specifics_Rejection__c",
                  "Update_AIMS_Rejection__c",
                  "Close_IFAP_Rejection__c",
                  "Cancel_Inspection_Requests_Rejection__c",
                  "STEP18__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_REJECTION_WITHDRAWAL",
            "Steps": [
              {
                "Name": "STEP4",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_Withdrawal_notification__c",
                  "Issue_credit_note_withdrawal__c",
                  "Release_FS_withdrawal__c",
                  "STEP4__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_RECONSIDERATION",
            "Steps": [
              {
                "Name": "STEP5",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "STEP5__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "BANK.ACCOUNT.CHANGES",
        "Flows": [
          {
            "Name": "AMS_OSCAR_APPLICATIONRECEIPT",
            "Steps": [
              {
                "Name": "STEP6",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
                  }
                ],
                "DisplayFields": [
                  "Change_effective_as_of__c",
                  "STEP6__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_CHANGE_PROCESSING",
            "Steps": [
              {
                "Name": "STEP7",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step7_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step7_failed"
                  }
                ],
                "DisplayFields": [
                  "Update_IRIS_processing__c",
                  "Confirm_DD_setup_with_R_S__c",
                  "STEP7__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_CHANGE_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP16",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step16_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step16_failed"
                  }
                ],
                "DisplayFields": [
                  "Confirm_DD_setup_with_agent__c",
                  "STEP16__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "MAJOR.CHANGES",
        "Flows": [
          {
            "Name": "AMS_OSCAR_APPLICATIONRECEIPT",
            "Steps": [
              {
                "Name": "STEP6",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "checkAccountHierarchy",
                    "ActionLabel": "AMS_OSCAR_Action6",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
                  }
                ],
                "DisplayFields": [
                  "Change_effective_as_of__c",
                  "Type_of_change__c",
                  "STEP6__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_ANTIMONEYLAUNDERING",
            "Steps": [
              {
                "Name": "STEP17",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "performAML",
                    "ActionLabel": "AMS_OSCAR_Action4",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_inProgress"
                  },
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_failed"
                  }
                ],
                "DisplayFields": [
                  "STEP17__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_PENALTY",
            "Steps": [
              {
                "Name": "STEP26",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "createSIDRALite",
                    "ActionLabel": "AMS_OSCAR_Action7",
                    "args": [
                      "oscarid"
                    ]
                  },
                  {
                    "FunctionName": "createCommissionerCase",
                    "ActionLabel": "AMS_OSCAR_Action8",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [],
                "DisplayFields": [
                  "Change_effective_as_of__c",
                  "Remove_STDs__c",
                  "Notify_Agent_Suspension__c",
                  "Notify_Agent_Termination__c",
                  "STEP26__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP27",
                "Required": [],
                "Actions": [],
                "Automations": [],
                "DisplayFields": [
                  "NOC_Received__c",
                  "Notify_Agent_Reactivation__c",
                  "Reinstate_STDs_Reactivation__c",
                  "STEP27__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP28",
                "Required": [],
                "Actions": [],
                "Automations": [],
                "DisplayFields": [
                  "Notify_Agent_Withdrawal__c",
                  "Reactivate_Ticketing_Authority__c",
                  "STEP28__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP29",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step29_succeeded"
                  }
                ],
                "DisplayFields": [
                  "Apply_Penalty_Fee__c",
                  "STEP29__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_AGENCYFEES",
            "Steps": [
              {
                "Name": "STEP8",
                "Required": [
                  "STEP6"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step8_succeeded"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step8_inProgress"
                  }
                ],
                "DisplayFields": [
                  "Billing_Document_Number__c",
                  "Send_invoice__c",
                  "STEP8__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP9",
                "Required": [
                  "STEP6"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "STEP9__c"
                ],
                "IsDependent": true
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_CHANGE_PROCESSING",
            "Steps": [
              {
                "Name": "STEP11",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "createIFAP",
                    "ActionLabel": "AMS_OSCAR_Action3",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step11_inProgress"
                  }
                ],
                "DisplayFields": [
                  "STEP11__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP12",
                "Required": [
                  "STEP8",
                  "STEP9"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step12_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step12_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step12_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Send_FS_request__c",
                  "STEP12__c"
                ],
                "IsDependent": true
              },
              {
                "Name": "STEP13",
                "Required": [
                  "STEP8",
                  "STEP9"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_failed"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_inProgress"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Send_inspection_request__c",
                  "STEP13__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP14",
                "Required": [
                  "STEP8",
                  "STEP9"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_succeeded"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_inProgress"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_failed"
                  }
                ],
                "DisplayFields": [
                  "Send_agreement__c",
                  "STEP14__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_VALIDATION",
            "Steps": [
              {
                "Name": "STEP25",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step25_succeeded"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step25_inProgress"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step25_failed"
                  }
                ],
                "DisplayFields": [
                  "Validation_Status__c",
                  "Comments_validate__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APPROVAL",
            "Steps": [
              {
                "Name": "STEP2",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step2_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step2_failed"
                  }
                ],
                "DisplayFields": [
                  "RPM_Approval__c",
                  "Comments_approval__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_CHANGE_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP1",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_failed"
                  }
                ],
                "DisplayFields": [
                  "Update_DPC__c",
                  "Update_IRIS__c",
                  "Update_BSPLink_CASSLink__c",
                  "Update_Portal_Setup__c",
                  "Send_approval_letter__c",
                  "Welcome_pack__c",
                  "Off_site_storage__c",
                  "Welcome_call__c",
                  "Change_effective_as_of__c",
                  "STEP1__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_CHANGE_DISAPPROVAL",
            "Steps": [
              {
                "Name": "STEP3",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "createCorrectionCase",
                    "ActionLabel": "AMS_OSCAR_Action5",
                    "args": [
                      "agencyid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_failed"
                  }
                ],
                "DisplayFields": [
                  "Issue_disapproval_pack__c",
                  "Issue_credit_note_if_applicable__c",
                  "Release_FS_if_applicable__c",
                  "Roll_back_account_data__c",
                  "STEP3__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_CHANGE_REJECTION_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP18",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_rejection_notification_pack__c",
                  "STEP18__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_CHANGE_WITHDRAWAL",
            "Steps": [
              {
                "Name": "STEP4",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_failed"
                  }
                ],
                "DisplayFields": [
                  "Issue_Withdrawal_notification__c",
                  "Issue_credit_note_withdrawal__c",
                  "Release_FS_withdrawal__c",
                  "STEP4__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "DGR.DGA",
        "Flows": [
          {
            "Name": "AMS_OSCAR_APPLICATIONRECEIPT",
            "Steps": [
              {
                "Name": "STEP6",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
                  }
                ],
                "DisplayFields": [
                  "STEP6__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_CHANGE_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP16",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step16_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step16_failed"
                  }
                ],
                "DisplayFields": [
                  "Confirm_DGR_DGA__c",
                  "Change_effective_as_of__c",
                  "STEP16__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "NEW.BR.ABROAD",
        "Flows": [
          {
            "Name": "AMS_OSCAR_APPLICATIONRECEIPT",
            "Steps": [
              {
                "Name": "STEP6",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_failed"
                  }
                ],
                "DisplayFields": [
                  "Is_PCI_compliant__c",
                  "ANG_PCI_compliance_expiry_date__c",
                  "STEP6__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_MASTERDATA",
            "Steps": [
              {
                "Name": "STEP10",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "generateIataCode",
                    "ActionLabel": "AMS_OSCAR_Action1",
                    "args": [
                      "agencyid",
                      "accreditationid",
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step10_succeeded"
                  }
                ],
                "DisplayFields": [
                  "STEP10__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_ANTIMONEYLAUNDERING",
            "Steps": [
              {
                "Name": "STEP17",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "performAML",
                    "ActionLabel": "AMS_OSCAR_Action4",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_inProgress"
                  },
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_failed"
                  }
                ],
                "DisplayFields": [
                  "STEP17__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_AGENCYFEES",
            "Steps": [
              {
                "Name": "STEP8",
                "Required": [
                  "STEP6"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step8_succeeded"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step8_inProgress"
                  }
                ],
                "DisplayFields": [
                  "Billing_Document_Number__c",
                  "Send_invoice__c",
                  "Issue_billing_document__c",
                  "STEP8__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP9",
                "Required": [
                  "STEP6"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "STEP9__c"
                ],
                "IsDependent": true
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APPLICATIONPROCESSING",
            "Steps": [
              {
                "Name": "STEP11",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "createIFAP",
                    "ActionLabel": "AMS_OSCAR_Action3",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step11_inProgress"
                  }
                ],
                "DisplayFields": [
                  "STEP11__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP12",
                "Required": [
                  "STEP8",
                  "STEP9"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step12_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step12_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step12_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Bank_Guarantee_amount__c",
                  "Bank_Guarantee_Currency__c",
                  "Send_FS_request__c",
                  "STEP12__c"
                ],
                "IsDependent": true
              },
              {
                "Name": "STEP13",
                "Required": [
                  "STEP8",
                  "STEP9"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_failed"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_inProgress"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Send_inspection_request__c",
                  "STEP13__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP14",
                "Required": [
                  "STEP8",
                  "STEP9"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_succeeded"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_inProgress"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_failed"
                  }
                ],
                "DisplayFields": [
                  "Send_agreement__c",
                  "STEP14__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_VALIDATION",
            "Steps": [
              {
                "Name": "STEP15",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step15_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step15_failed"
                  }
                ],
                "DisplayFields": [
                  "Comments_validate__c",
                  "Validation_Status__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APPROVAL",
            "Steps": [
              {
                "Name": "STEP2",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step2_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step2_failed"
                  }
                ],
                "DisplayFields": [
                  "RPM_Approval__c",
                  "Comments_approval__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP1",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Update_DPC__c",
                  "Update_IRIS__c",
                  "Update_BSPLink_CASSLink__c",
                  "Update_Portal_Setup__c",
                  "Send_approval_letter__c",
                  "Welcome_pack__c",
                  "Off_site_storage__c",
                  "Welcome_call__c",
                  "Country_Specifics_Approval__c",
                  "Update_AIMS_Approval__c",
                  "Change_effective_as_of__c",
                  "STEP1__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_DISAPPROVAL",
            "Steps": [
              {
                "Name": "STEP3",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_disapproval_pack__c",
                  "Issue_credit_note_if_applicable__c",
                  "Release_FS_if_applicable__c",
                  "Country_Specifics_Disapproval__c",
                  "Update_AIMS_Disapproval__c",
                  "Close_IFAP_Disapproval__c",
                  "Cancel_Inspection_Requests_Disapproval__c",
                  "STEP3__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_REJECTION_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP18",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_rejection_notification_pack__c",
                  "Country_Specifics_Rejection__c",
                  "Update_AIMS_Rejection__c",
                  "Close_IFAP_Rejection__c",
                  "Cancel_Inspection_Requests_Rejection__c",
                  "STEP18__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_REJECTION_WITHDRAWAL",
            "Steps": [
              {
                "Name": "STEP4",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_Withdrawal_notification__c",
                  "Issue_credit_note_withdrawal__c",
                  "Release_FS_withdrawal__c",
                  "STEP4__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_RECONSIDERATION",
            "Steps": [
              {
                "Name": "STEP5",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "STEP5__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "NEW.TIDS.1.0",
        "Flows": [
          {
            "Name": "AMS_OSCAR_APPLICATIONRECEIPT",
            "Steps": [
              {
                "Name": "STEP6",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_failed"
                  }
                ],
                "DisplayFields": [
                  "STEP6__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_MASTERDATA",
            "Steps": [
              {
                "Name": "STEP10",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "generateIataCode",
                    "ActionLabel": "AMS_OSCAR_Action1",
                    "args": [
                      "agencyid",
                      "accreditationid",
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step10_succeeded"
                  }
                ],
                "DisplayFields": [
                  "STEP10__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_AGENCYFEES",
            "Steps": [
              {
                "Name": "STEP8",
                "Required": [
                  "STEP6"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step8_succeeded"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step8_inProgress"
                  }
                ],
                "DisplayFields": [
                  "Billing_Document_Number__c",
                  "Send_invoice__c",
                  "Issue_billing_document__c",
                  "STEP8__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP9",
                "Required": [
                  "STEP6"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "STEP9__c"
                ],
                "IsDependent": true
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP1",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_succeeded",
                    "ChangeCode": {
                      "Name": "FIN",
                      "ReasonCode": "91",
                      "MemoText": "New application - TIDS finalized",
                      "ReasonDesc": "ACCREDITED–MEETS–STANDARDS",
                      "Status": "9"
                    }
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Update_Portal_Setup__c",
                  "Send_approval_letter__c",
                  "Change_effective_as_of__c",
                  "STEP1__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_DISAPPROVAL",
            "Steps": [
              {
                "Name": "STEP3",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_succeeded",
                    "ChangeCode": {
                      "Name": "DIS",
                      "ReasonCode": "12",
                      "MemoText": "New application - TIDS disapproved",
                      "ReasonDesc": "APPLICATION DISAPPROVED",
                      "Status": "1"
                    }
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_disapproval_pack__c",
                  "Issue_credit_note_if_applicable__c",
                  "STEP3__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_REJECTION_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP18",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_rejection_notification_pack__c",
                  "STEP18__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_REJECTION_WITHDRAWAL",
            "Steps": [
              {
                "Name": "STEP4",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_succeeded",
                    "ChangeCode": {
                      "Name": "NWD",
                      "ReasonCode": "11",
                      "MemoText": "New application - TIDS withdrawn",
                      "ReasonDesc": "APPLICATION WITHDRAWN",
                      "Status": "1"
                    }
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_Withdrawal_notification__c",
                  "Issue_credit_note_withdrawal__c",
                  "STEP4__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_RECONSIDERATION",
            "Steps": [
              {
                "Name": "STEP5",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_succeeded",
                    "ChangeCode": {
                      "Name": "REC",
                      "ReasonCode": "22",
                      "MemoText": "New application - TIDS reconsidered",
                      "ReasonDesc": "APPLICATION BEING RECONSIDERED",
                      "Status": "2"
                    }
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "STEP5__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "NEW.MSO.1.0",
        "Flows": [
          {
            "Name": "AMS_OSCAR_CODEASSIGNMENT",
            "Steps": [
              {
                "Name": "STEP10",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "generateIataCode",
                    "ActionLabel": "AMS_OSCAR_Action1",
                    "args": [
                      "agencyid",
                      "accreditationid",
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step10_succeeded",
                    "ChangeCode": {
                      "Name": "FIN",
                      "ReasonCode": "91",
                      "MemoText": "New application - MSO finalized",
                      "ReasonDesc": "ACCREDITED–MEETS–STANDARDS",
                      "Status": "9"
                    }
                  }
                ],
                "DisplayFields": [
                  "Change_effective_as_of__c",
                  "STEP10__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "NEW.GSA.1.0",
        "Flows": [
          {
            "Name": "AMS_OSCAR_CODEASSIGNMENT",
            "Steps": [
              {
                "Name": "STEP10",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "generateIataCode",
                    "ActionLabel": "AMS_OSCAR_Action1",
                    "args": [
                      "agencyid",
                      "accreditationid",
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step10_succeeded",
                    "ChangeCode": {
                      "Name": "FIN",
                      "ReasonCode": "91",
                      "MemoText": "New application - GSA finalized",
                      "ReasonDesc": "ACCREDITED–MEETS–STANDARDS",
                      "Status": "9"
                    }
                  }
                ],
                "DisplayFields": [
                  "Change_effective_as_of__c",
                  "BSPLink_participation__c",
                  "STEP10__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "NEW.GSA.1.0.BSP",
        "Flows": [
          {
            "Name": "AMS_OSCAR_APPLICATIONRECEIPT",
            "Steps": [
              {
                "Name": "STEP6",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_failed"
                  }
                ],
                "DisplayFields": [
                  "BSPLink_participation__c",
                  "STEP6__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_MASTERDATA",
            "Steps": [
              {
                "Name": "STEP10",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "generateIataCode",
                    "ActionLabel": "AMS_OSCAR_Action1",
                    "args": [
                      "agencyid",
                      "accreditationid",
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step10_succeeded"
                  }
                ],
                "DisplayFields": [
                  "STEP10__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APPLICATIONPROCESSING",
            "Steps": [
              {
                "Name": "STEP14",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_succeeded"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_inProgress"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_failed"
                  }
                ],
                "DisplayFields": [
                  "Send_agreement__c",
                  "STEP14__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP1",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_succeeded",
                    "ChangeCode": {
                      "Name": "FIN",
                      "ReasonCode": "91",
                      "MemoText": "New application - GSA finalized",
                      "ReasonDesc": "ACCREDITED–MEETS–STANDARDS",
                      "Status": "9"
                    }
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Update_Portal_Setup__c",
                  "Send_approval_letter__c",
                  "Change_effective_as_of__c",
                  "STEP1__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_DISAPPROVAL",
            "Steps": [
              {
                "Name": "STEP3",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_succeeded",
                    "ChangeCode": {
                      "Name": "DIS",
                      "ReasonCode": "12",
                      "MemoText": "New application - GSA disapproved",
                      "ReasonDesc": "APPLICATION DISAPPROVED",
                      "Status": "1"
                    }
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_disapproval_pack__c",
                  "Issue_credit_note_if_applicable__c",
                  "STEP3__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_REJECTION_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP18",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_rejection_notification_pack__c",
                  "STEP18__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_REJECTION_WITHDRAWAL",
            "Steps": [
              {
                "Name": "STEP4",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_succeeded",
                    "ChangeCode": {
                      "Name": "NWD",
                      "ReasonCode": "11",
                      "MemoText": "New application - GSA withdrawn",
                      "ReasonDesc": "APPLICATION WITHDRAWN",
                      "Status": "1"
                    }
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_Withdrawal_notification__c",
                  "Issue_credit_note_withdrawal__c",
                  "STEP4__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_RECONSIDERATION",
            "Steps": [
              {
                "Name": "STEP5",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_succeeded",
                    "ChangeCode": {
                      "Name": "REC",
                      "ReasonCode": "22",
                      "MemoText": "New application - GSA reconsidered",
                      "ReasonDesc": "APPLICATION BEING RECONSIDERED",
                      "Status": "2"
                    }
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "STEP5__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "NEW.GSSA.1.0",
        "Flows": [
          {
            "Name": "AMS_OSCAR_APPLICATIONRECEIPT",
            "Steps": [
              {
                "Name": "STEP6",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_failed"
                  }
                ],
                "DisplayFields": [
                  "STEP6__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_MASTERDATA",
            "Steps": [
              {
                "Name": "STEP10",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "generateIataCode",
                    "ActionLabel": "AMS_OSCAR_Action1",
                    "args": [
                      "agencyid",
                      "accreditationid",
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step10_succeeded"
                  }
                ],
                "DisplayFields": [
                  "STEP10__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APPLICATIONPROCESSING",
            "Steps": [
              {
                "Name": "STEP14",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_succeeded"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_inProgress"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_failed"
                  }
                ],
                "DisplayFields": [
                  "Send_agreement__c",
                  "STEP14__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP1",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_succeeded",
                    "ChangeCode": {
                      "Name": "FIN",
                      "ReasonCode": "91",
                      "MemoText": "New application - GSSA finalized",
                      "ReasonDesc": "ACCREDITED–MEETS–STANDARDS",
                      "Status": "9"
                    }
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Update_Portal_Setup__c",
                  "Send_approval_letter__c",
                  "Change_effective_as_of__c",
                  "STEP1__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_DISAPPROVAL",
            "Steps": [
              {
                "Name": "STEP3",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_succeeded",
                    "ChangeCode": {
                      "Name": "DIS",
                      "ReasonCode": "12",
                      "MemoText": "New application - GSSA disapproved",
                      "ReasonDesc": "APPLICATION DISAPPROVED",
                      "Status": "1"
                    }
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_disapproval_pack__c",
                  "Issue_credit_note_if_applicable__c",
                  "STEP3__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_REJECTION_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP18",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_rejection_notification_pack__c",
                  "STEP18__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_REJECTION_WITHDRAWAL",
            "Steps": [
              {
                "Name": "STEP4",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_succeeded",
                    "ChangeCode": {
                      "Name": "NWD",
                      "ReasonCode": "11",
                      "MemoText": "New application - GSSA withdrawn",
                      "ReasonDesc": "APPLICATION WITHDRAWN",
                      "Status": "1"
                    }
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_Withdrawal_notification__c",
                  "Issue_credit_note_withdrawal__c",
                  "STEP4__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_RECONSIDERATION",
            "Steps": [
              {
                "Name": "STEP5",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_succeeded",
                    "ChangeCode": {
                      "Name": "REC",
                      "ReasonCode": "22",
                      "MemoText": "New application - GSSA reconsidered",
                      "ReasonDesc": "APPLICATION BEING RECONSIDERED",
                      "Status": "2"
                    }
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "STEP5__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "NEW.AHA.1.0",
        "Flows": [
          {
            "Name": "AMS_OSCAR_CODEASSIGNMENT",
            "Steps": [
              {
                "Name": "STEP10",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "generateIataCode",
                    "ActionLabel": "AMS_OSCAR_Action1",
                    "args": [
                      "agencyid",
                      "accreditationid",
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step10_succeeded",
                    "ChangeCode": {
                      "Name": "FIN",
                      "ReasonCode": "91",
                      "MemoText": "New application - AHA finalized",
                      "ReasonDesc": "ACCREDITED–MEETS–STANDARDS",
                      "Status": "9"
                    }
                  }
                ],
                "DisplayFields": [
                  "Change_effective_as_of__c",
                  "BSPLink_participation__c",
                  "STEP10__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "NEW.AHA.1.0.BSP",
        "Flows": [
          {
            "Name": "AMS_OSCAR_APPLICATIONRECEIPT",
            "Steps": [
              {
                "Name": "STEP6",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_failed"
                  }
                ],
                "DisplayFields": [
                  "BSPLink_participation__c",
                  "STEP6__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_MASTERDATA",
            "Steps": [
              {
                "Name": "STEP10",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "generateIataCode",
                    "ActionLabel": "AMS_OSCAR_Action1",
                    "args": [
                      "agencyid",
                      "accreditationid",
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step10_succeeded"
                  }
                ],
                "DisplayFields": [
                  "STEP10__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APPLICATIONPROCESSING",
            "Steps": [
              {
                "Name": "STEP14",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_succeeded"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_inProgress"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_failed"
                  }
                ],
                "DisplayFields": [
                  "Send_agreement__c",
                  "STEP14__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP1",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_succeeded",
                    "ChangeCode": {
                      "Name": "FIN",
                      "ReasonCode": "91",
                      "MemoText": "New application - AHA finalized",
                      "ReasonDesc": "ACCREDITED–MEETS–STANDARDS",
                      "Status": "9"
                    }
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Update_Portal_Setup__c",
                  "Send_approval_letter__c",
                  "Change_effective_as_of__c",
                  "STEP1__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_DISAPPROVAL",
            "Steps": [
              {
                "Name": "STEP3",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_succeeded",
                    "ChangeCode": {
                      "Name": "DIS",
                      "ReasonCode": "12",
                      "MemoText": "New application - AHA disapproved",
                      "ReasonDesc": "APPLICATION DISAPPROVED",
                      "Status": "1"
                    }
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_disapproval_pack__c",
                  "Issue_credit_note_if_applicable__c",
                  "STEP3__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_REJECTION_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP18",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_rejection_notification_pack__c",
                  "STEP18__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_REJECTION_WITHDRAWAL",
            "Steps": [
              {
                "Name": "STEP4",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_succeeded",
                    "ChangeCode": {
                      "Name": "NWD",
                      "ReasonCode": "11",
                      "MemoText": "New application - AHA withdrawn",
                      "ReasonDesc": "APPLICATION WITHDRAWN",
                      "Status": "1"
                    }
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_Withdrawal_notification__c",
                  "Issue_credit_note_withdrawal__c",
                  "STEP4__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_RECONSIDERATION",
            "Steps": [
              {
                "Name": "STEP5",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_succeeded",
                    "ChangeCode": {
                      "Name": "REC",
                      "ReasonCode": "22",
                      "MemoText": "New application - AHA reconsidered",
                      "ReasonDesc": "APPLICATION BEING RECONSIDERED",
                      "Status": "2"
                    }
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "STEP5__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "NEW.SA.1.0",
        "Flows": [
          {
            "Name": "AMS_OSCAR_APPLICATIONRECEIPT",
            "Steps": [
              {
                "Name": "STEP6",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_failed"
                  }
                ],
                "DisplayFields": [
                  "STEP6__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_MASTERDATA",
            "Steps": [
              {
                "Name": "STEP10",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "generateIataCode",
                    "ActionLabel": "AMS_OSCAR_Action1",
                    "args": [
                      "agencyid",
                      "accreditationid",
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step10_succeeded"
                  }
                ],
                "DisplayFields": [
                  "STEP10__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_AGENCYFEES",
            "Steps": [
              {
                "Name": "STEP8",
                "Required": [
                  "STEP6"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step8_succeeded"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step8_inProgress"
                  }
                ],
                "DisplayFields": [
                  "Billing_Document_Number__c",
                  "Send_invoice__c",
                  "Issue_billing_document__c",
                  "STEP8__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP9",
                "Required": [
                  "STEP6"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "STEP9__c"
                ],
                "IsDependent": true
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APPLICATIONPROCESSING",
            "Steps": [
              {
                "Name": "STEP11",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "createIFAP",
                    "ActionLabel": "AMS_OSCAR_Action3",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step11_inProgress"
                  }
                ],
                "DisplayFields": [
                  "STEP11__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP12",
                "Required": [
                  "STEP8",
                  "STEP9"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step12_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step12_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step12_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Bank_Guarantee_amount__c",
                  "Bank_Guarantee_Currency__c",
                  "Send_FS_request__c",
                  "STEP12__c"
                ],
                "IsDependent": true
              },
              {
                "Name": "STEP13",
                "Required": [
                  "STEP8",
                  "STEP9"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_failed"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_inProgress"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Send_inspection_request__c",
                  "STEP13__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP14",
                "Required": [
                  "STEP8",
                  "STEP9"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_succeeded"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_inProgress"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_failed"
                  }
                ],
                "DisplayFields": [
                  "Send_agreement__c",
                  "STEP14__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_VALIDATION",
            "Steps": [
              {
                "Name": "STEP15",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step15_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step15_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step15_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Comments_validate__c",
                  "Validation_Status__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APPROVAL",
            "Steps": [
              {
                "Name": "STEP2",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step2_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step2_failed"
                  }
                ],
                "DisplayFields": [
                  "RPM_Approval__c",
                  "Comments_approval__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP1",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Update_DPC__c",
                  "Update_IRIS__c",
                  "Update_BSPLink_CASSLink__c",
                  "Update_Portal_Setup__c",
                  "Send_approval_letter__c",
                  "Welcome_pack__c",
                  "Off_site_storage__c",
                  "Welcome_call__c",
                  "Change_effective_as_of__c",
                  "STEP1__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_DISAPPROVAL",
            "Steps": [
              {
                "Name": "STEP3",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_disapproval_pack__c",
                  "Issue_credit_note_if_applicable__c",
                  "Release_FS_if_applicable__c",
                  "STEP3__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_REJECTION_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP18",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_rejection_notification_pack__c",
                  "STEP18__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_REJECTION_WITHDRAWAL",
            "Steps": [
              {
                "Name": "STEP4",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_Withdrawal_notification__c",
                  "Issue_credit_note_withdrawal__c",
                  "Release_FS_withdrawal__c",
                  "STEP4__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_RECONSIDERATION",
            "Steps": [
              {
                "Name": "STEP5",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "STEP5__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "CORRECTION.1.0",
        "Flows": [
          {
            "Name": "AMS_PERFORM_CORRECTION",
            "Steps": [
              {
                "Name": "STEP6",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "checkAccountHierarchyCorrection",
                    "ActionLabel": "AMS_OSCAR_Action6_Corr",
                    "args": ["oscarid"]
                  }
				],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_failed"
                  }
                ],
                "DisplayFields": [
                  "AMS_Correction_change_code__c",
                  "STEP6__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "CERTIFICATION.1.0",
        "Flows": [
          {
            "Name": "AMS_OSCAR_APPLICATIONRECEIPT",
            "Steps": [
              {
                "Name": "STEP6",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_failed"
                  }
                ],
                "DisplayFields": [
                  "STEP6__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "VR.1.0",
        "Flows": [
          {
            "Name": "AMS_OSCAR_APPLICATIONRECEIPT",
            "Steps": [
              {
                "Name": "STEP6",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "checkAccountHierarchy",
                    "ActionLabel": "AMS_OSCAR_Action6",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_failed"
                  }
                ],
                "DisplayFields": [
                  "Form_Effective_Date__c",
                  "Financial_Security_expiry_date__c",
                  "STEP6__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_PROCESSSUSPENSION",
            "Steps": [
              {
                "Name": "STEP30",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "deactivateBSPLink",
                    "ActionLabel": "AMS_OSCAR_Action9",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step30_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step30_failed"
                  }
                ],
                "DisplayFields": [
                  "Suspend_in_BSPLink_CASSLink__c",
                  "STEP30__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_PROCESSTERMINATION",
            "Steps": [
              {
                "Name": "STEP31",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "createFSReleaseCase",
                    "ActionLabel": "AMS_OSCAR_Action10",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step31_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step31_failed"
                  }
                ],
                "DisplayFields": [
                  "Release_FS_if_applicable__c",
                  "STEP31__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_PROCESSWITHDRAWAL",
            "Steps": [
              {
                "Name": "STEP32",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "reactivateBSPLink",
                    "ActionLabel": "AMS_OSCAR_Action11",
                    "args": [
                      "oscarid"
                    ]
                  },
                  {
                    "FunctionName": "undoDeactivationBSPLink",
                    "ActionLabel": "AMS_OSCAR_Action13",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step32_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step32_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step32_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Reactivate_Agent_in_BSPlink_CASSlink__c",
                  "STEP32__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "VR.1.0.CA",
        "Flows": [
          {
            "Name": "AMS_OSCAR_APPLICATIONRECEIPT",
            "Steps": [
              {
                "Name": "STEP6",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_failed"
                  }
                ],
                "DisplayFields": [
                  "Change_effective_as_of__c",
                  "STEP6__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_PROCESSTERMINATION",
            "Steps": [
              {
                "Name": "STEP31",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step31_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step31_failed"
                  }
                ],
                "DisplayFields": [
                  "STEP31__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_PROCESSWITHDRAWAL",
            "Steps": [
              {
                "Name": "STEP32",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step32_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step32_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step32_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "STEP32__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "CER.1.0",
        "Flows": [
          {
            "Name": "AMS_OSCAR_CERTIFICATE",
            "Steps": [
              {
                "Name": "STEP33",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "generateCertificates",
                    "ActionLabel": "AMS_OSCAR_Action12",
                    "args": [
                      "oscarid",
                      "agencyid"
                    ]
                  }
                ],
                "Automations": [],
                "DisplayFields": [
                  "Confirm_Payment_if_applicable__c",
                  "Send_Confirmation__c",
                  "STEP33__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "ANG.NEW.HE.LITE.1.0",
        "Flows": [
          {
            "Name": "AMS_OSCAR_APPLICATIONRECEIPT",
            "Steps": [
              {
                "Name": "STEP6",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_failed"
                  }
                ],
                "DisplayFields": [
                  "Is_PCI_compliant__c",
                  "ANG_PCI_compliance_expiry_date__c",
                  "STEP6__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_MASTERDATA",
            "Steps": [
              {
                "Name": "STEP10",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "generateIataCode",
                    "ActionLabel": "AMS_OSCAR_Action1",
                    "args": [
                      "agencyid",
                      "accreditationid",
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step10_succeeded"
                  }
                ],
                "DisplayFields": [
                  "STEP10__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_ANTIMONEYLAUNDERING",
            "Steps": [
              {
                "Name": "STEP17",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "performAML",
                    "ActionLabel": "AMS_OSCAR_Action4",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_inProgress"
                  },
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_failed"
                  }
                ],
                "DisplayFields": [
                  "STEP17__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_AGENCYFEES",
            "Steps": [
              {
                "Name": "STEP8",
                "Required": [
                  "STEP6"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step8_succeeded"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step8_inProgress"
                  }
                ],
                "DisplayFields": [
                  "Billing_Document_Number__c",
                  "Send_invoice__c",
                  "STEP8__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP9",
                "Required": [
                  "STEP6"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "STEP9__c"
                ],
                "IsDependent": true
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APPLICATIONPROCESSING",
            "Steps": [
              {
                "Name": "STEP34",
                "Required": [],
                "Actions": [],
                "Automations": [],
                "DisplayFields": [
                  "Is_using_credit_card__c",
                  "Requested_Bank_Guarantee_amount__c",
                  "Requested_Bank_Guarantee_currency__c",
                  "Send_FS_request__c",
                  "STEP34__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP35",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "createFSObject",
                    "ActionLabel": "AMS_OSCAR_Action14",
                    "args": [
                      "agencyid",
                      "accountNameFromOscar"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step35_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step35_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step35_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Received_Bank_Guarantee_amount__c",
                  "Received_Bank_Guarantee_currency__c",
                  "STEP35__c"
                ],
                "IsDependent": true
              },
              {
                "Name": "STEP13",
                "Required": [
                  "STEP8",
                  "STEP9"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_failed"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_inProgress"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Send_inspection_request__c",
                  "STEP13__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP14",
                "Required": [
                  "STEP8",
                  "STEP9"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_succeeded"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_inProgress"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_failed"
                  }
                ],
                "DisplayFields": [
                  "Send_agreement__c",
                  "STEP14__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_VALIDATION",
            "Steps": [
              {
                "Name": "STEP15",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step15_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step15_failed"
                  }
                ],
                "DisplayFields": [
                  "Comments_validate__c",
                  "Validation_Status__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APPROVAL",
            "Steps": [
              {
                "Name": "STEP2",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step2_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step2_failed"
                  }
                ],
                "DisplayFields": [
                  "RPM_Approval__c",
                  "Comments_approval__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP37",
                "Required": [],
                "Actions": [],
                "Automations": [],
                "DisplayFields": [
                  "Update_BSPLink__c",
                  "Create_Agency_Authorization__c",
                  "STEP37__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP1",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Update_DPC__c",
                  "Update_IRIS__c",
                  "Update_Portal_Setup__c",
                  "Send_approval_letter__c",
                  "Welcome_pack__c",
                  "Off_site_storage__c",
                  "Welcome_call__c",
                  "Country_Specifics_Approval__c",
                  "STEP1__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_DISAPPROVAL",
            "Steps": [
              {
                "Name": "STEP3",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_disapproval_pack__c",
                  "Issue_credit_note_if_applicable__c",
                  "Release_FS_if_applicable__c",
                  "Country_Specifics_Disapproval__c",
                  "Close_IFAP_Disapproval__c",
                  "Cancel_Inspection_Requests_Disapproval__c",
                  "STEP3__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_REJECTION_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP18",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_rejection_notification_pack__c",
                  "Country_Specifics_Rejection__c",
                  "Close_IFAP_Rejection__c",
                  "Cancel_Inspection_Requests_Rejection__c",
                  "STEP18__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_REJECTION_WITHDRAWAL",
            "Steps": [
              {
                "Name": "STEP4",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_Withdrawal_notification__c",
                  "Issue_credit_note_withdrawal__c",
                  "Release_FS_withdrawal__c",
                  "STEP4__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_RECONSIDERATION",
            "Steps": [
              {
                "Name": "STEP5",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "STEP5__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "ANG.NEW.HE.STANDARD.1.0",
        "Flows": [
          {
            "Name": "AMS_OSCAR_APPLICATIONRECEIPT",
            "Steps": [
              {
                "Name": "STEP6",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_failed"
                  }
                ],
                "DisplayFields": [
                  "Is_PCI_compliant__c",
                  "ANG_PCI_compliance_expiry_date__c",
                  "ANG_Change_Entity_Location__c",
                  "STEP6__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_MASTERDATA",
            "Steps": [
              {
                "Name": "STEP10",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "generateIataCode",
                    "ActionLabel": "AMS_OSCAR_Action1",
                    "args": [
                      "agencyid",
                      "accreditationid",
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step10_succeeded"
                  }
                ],
                "DisplayFields": [
                  "STEP10__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_ANTIMONEYLAUNDERING",
            "Steps": [
              {
                "Name": "STEP17",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "performAML",
                    "ActionLabel": "AMS_OSCAR_Action4",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_inProgress"
                  },
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_failed"
                  }
                ],
                "DisplayFields": [
                  "STEP17__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_AGENCYFEES",
            "Steps": [
              {
                "Name": "STEP8",
                "Required": [
                  "STEP6"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step8_succeeded"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step8_inProgress"
                  }
                ],
                "DisplayFields": [
                  "Billing_Document_Number__c",
                  "Send_invoice__c",
                  "STEP8__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP9",
                "Required": [
                  "STEP6"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "STEP9__c"
                ],
                "IsDependent": true
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APPLICATIONPROCESSING",
            "Steps": [
              {
                "Name": "STEP11",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "createIFAP",
                    "ActionLabel": "AMS_OSCAR_Action3",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step11_inProgress"
                  }
                ],
                "DisplayFields": [
                  "STEP11__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP34",
                "Required": [],
                "Actions": [],
                "Automations": [],
                "DisplayFields": [
                  "Requested_Bank_Guarantee_amount__c",
                  "Requested_Bank_Guarantee_currency__c",
                  "Send_FS_request__c",
                  "STEP34__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP35",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "createFSObject",
                    "ActionLabel": "AMS_OSCAR_Action14",
                    "args": [
                      "agencyid",
                      "accountNameFromOscar"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step35_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step35_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step35_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Received_Bank_Guarantee_amount__c",
                  "Received_Bank_Guarantee_currency__c",
                  "STEP35__c"
                ],
                "IsDependent": true
              },
              {
                "Name": "STEP13",
                "Required": [
                  "STEP8",
                  "STEP9"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_failed"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_inProgress"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Send_inspection_request__c",
                  "STEP13__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP14",
                "Required": [
                  "STEP8",
                  "STEP9"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_succeeded"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_inProgress"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_failed"
                  }
                ],
                "DisplayFields": [
                  "Send_agreement__c",
                  "STEP14__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_VALIDATION",
            "Steps": [
              {
                "Name": "STEP15",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step15_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step15_failed"
                  }
                ],
                "DisplayFields": [
                  "Comments_validate__c",
                  "Validation_Status__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APPROVAL",
            "Steps": [
              {
                "Name": "STEP2",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "forecast",
                    "ActionLabel": "AMS_OSCAR_Action16",
                    "args": [
                      "oscarid"
                    ]
                  }],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step2_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step2_failed"
                  }
                ],
                "DisplayFields": [
                  "RPM_Approval__c",
                  "Comments_approval__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP36",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "createRiskEvent",
                    "ActionLabel": "AMS_OSCAR_Action15",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step36_succeeded"
                  }
                ],
                "DisplayFields": [
                  "STEP36__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP37",
                "Required": [],
                "Actions": [],
                "Automations": [],
                "DisplayFields": [
                  "Update_BSPLink__c",
                  "Create_Agency_Authorization__c",
                  "STEP37__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP1",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Update_DPC__c",
                  "Update_IRIS__c",
                  "Update_Portal_Setup__c",
                  "Send_approval_letter__c",
                  "Welcome_pack__c",
                  "Off_site_storage__c",
                  "Welcome_call__c",
                  "Country_Specifics_Approval__c",
                  "STEP1__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_DISAPPROVAL",
            "Steps": [
              {
                "Name": "STEP3",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_disapproval_pack__c",
                  "Issue_credit_note_if_applicable__c",
                  "Release_FS_if_applicable__c",
                  "Country_Specifics_Disapproval__c",
                  "Close_IFAP_Disapproval__c",
                  "Cancel_Inspection_Requests_Disapproval__c",
                  "STEP3__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_REJECTION_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP18",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_rejection_notification_pack__c",
                  "Country_Specifics_Rejection__c",
                  "Close_IFAP_Rejection__c",
                  "Cancel_Inspection_Requests_Rejection__c",
                  "STEP18__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_REJECTION_WITHDRAWAL",
            "Steps": [
              {
                "Name": "STEP4",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_Withdrawal_notification__c",
                  "Issue_credit_note_withdrawal__c",
                  "Release_FS_withdrawal__c",
                  "STEP4__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_RECONSIDERATION",
            "Steps": [
              {
                "Name": "STEP5",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "STEP5__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "ANG.NEW.AE.1.0",
        "Flows": [
          {
            "Name": "AMS_OSCAR_APPLICATIONRECEIPT",
            "Steps": [
              {
                "Name": "STEP6",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_failed"
                  }
                ],
                "DisplayFields": [
                  "Is_PCI_compliant__c",
                  "ANG_PCI_compliance_expiry_date__c",
                  "STEP6__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_MASTERDATA",
            "Steps": [
              {
                "Name": "STEP10",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "generateIataCode",
                    "ActionLabel": "AMS_OSCAR_Action1",
                    "args": [
                      "agencyid",
                      "accreditationid",
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step10_succeeded"
                  }
                ],
                "DisplayFields": [
                  "STEP10__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_ANTIMONEYLAUNDERING",
            "Steps": [
              {
                "Name": "STEP17",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "performAML",
                    "ActionLabel": "AMS_OSCAR_Action4",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_inProgress"
                  },
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_failed"
                  }
                ],
                "DisplayFields": [
                  "STEP17__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_AGENCYFEES",
            "Steps": [
              {
                "Name": "STEP8",
                "Required": [
                  "STEP6"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step8_succeeded"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step8_inProgress"
                  }
                ],
                "DisplayFields": [
                  "Billing_Document_Number__c",
                  "Send_invoice__c",
                  "STEP8__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP9",
                "Required": [
                  "STEP6"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "STEP9__c"
                ],
                "IsDependent": true
              }
            ]
          },
          {
          "Name": "AMS_OSCAR_APPLICATIONPROCESSING",
          "Steps": [
            {
                    "Name": "STEP13",
                    "Required": [
                      "STEP8",
                      "STEP9"
                    ],
                    "Actions": [],
                    "Automations": [
                      {
                        "Status": "Passed",
                        "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_succeeded"
                      },
                      {
                        "Status": "Failed",
                        "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_failed"
                      },
                      {
                        "Status": "In Progress",
                        "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_inProgress"
                      },
                      {
                        "Status": "Not Applicable",
                        "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step13_notApplicable"
                      }
                    ],
                    "DisplayFields": [
                      "Send_inspection_request__c",
                      "STEP13__c"
                    ],
                    "IsDependent": false
                  }
            ]
          },
          {
            "Name": "AMS_OSCAR_VALIDATION",
            "Steps": [
              {
                "Name": "STEP15",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step15_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step15_failed"
                  }
                ],
                "DisplayFields": [
                  "Comments_validate__c",
                  "Validation_Status__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APPROVAL",
            "Steps": [
              {
                "Name": "STEP2",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step2_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step2_failed"
                  }
                ],
                "DisplayFields": [
                  "RPM_Approval__c",
                  "Comments_approval__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP37",
                "Required": [],
                "Actions": [],
                "Automations": [],
                "DisplayFields": [
                  "Update_BSPLink__c",
                  "Create_Agency_Authorization__c",
                  "STEP37__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP1",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Update_DPC__c",
                  "Update_IRIS__c",
                  "Update_Portal_Setup__c",
                  "Send_approval_letter__c",
                  "Welcome_pack__c",
                  "Welcome_call__c",
                  "Country_Specifics_Approval__c",
                  "STEP1__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_DISAPPROVAL",
            "Steps": [
              {
                "Name": "STEP3",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_disapproval_pack__c",
                  "Issue_credit_note_if_applicable__c",
                  "Country_Specifics_Disapproval__c",
                  "STEP3__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_REJECTION_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP18",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_rejection_notification_pack__c",
                  "Country_Specifics_Rejection__c",
                  "STEP18__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_REJECTION_WITHDRAWAL",
            "Steps": [
              {
                "Name": "STEP4",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_Withdrawal_notification__c",
                  "Issue_credit_note_withdrawal__c",
                  "STEP4__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APP_RECONSIDERATION",
            "Steps": [
              {
                "Name": "STEP5",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step5_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "STEP5__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
       {
        "Name": "ANG.MAJOR.CHANGES.1.0",
        "Flows": [
          {
            "Name": "AMS_OSCAR_APPLICATIONRECEIPT",
            "Steps": [
              {
                "Name": "STEP6",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "ANG_checkAccountHierarchy",
                    "ActionLabel": "AMS_OSCAR_Action6",
                    "args": [
                      "oscarid"
                    ]
                  },
                  {
                    "FunctionName": "SIDRALiteAction",
                    "ActionLabel": "AMS_OSCAR_Action7",
                    "args": [
                      "oscarid", "6"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_failed"
                  }
                ],
                "DisplayFields": [
                  "ANG_Type_of_change_hidden__c",
                  "Change_effective_as_of__c",
                  "STEP6__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_ANTIMONEYLAUNDERING",
            "Steps": [
              {
                "Name": "STEP17",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "performAML",
                    "ActionLabel": "AMS_OSCAR_Action4",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_inProgress"
                  },
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_failed"
                  }
                ],
                "DisplayFields": [
                  "STEP17__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_PENALTY",
            "Steps": [
              {
                "Name": "STEP26",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "SIDRALiteAction",
                    "ActionLabel": "AMS_OSCAR_Action7",
                    "args": [
                      "oscarid", "26"
                    ]
                  },
                  {
                    "FunctionName": "createCommissionerCase",
                    "ActionLabel": "AMS_OSCAR_Action8",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [],
                "DisplayFields": [
                  "Suspend_Agency__c",
                  "Remove_STDs__c",
                  "Notify_Agent_Suspension__c",
                  "Terminate_Agency__c",
                  "Notify_Agent_Termination__c",
                  "STEP26__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP27",
                "Required": [],
                "Actions": [],
                "Automations": [],
                "DisplayFields": [
                  "NOC_Received__c",
                  "Notify_Agent_Reactivation__c",
                  "Reinstate_STDs_Reactivation__c",
                  "STEP27__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP28",
                "Required": [],
                "Actions": [],
                "Automations": [],
                "DisplayFields": [
                  "Notify_Agent_Withdrawal__c",
                  "Reactivate_Ticketing_Authority__c",
                  "STEP28__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP29",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step29_succeeded"
                  }
                ],
                "DisplayFields": [
                  "Apply_Penalty_Fee__c",
                  "STEP29__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_AGENCYFEES",
            "Steps": [
              {
                "Name": "STEP8",
                "Required": [
                  "STEP6"
                ],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step8_succeeded"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step8_inProgress"
                  }
                ],
                "DisplayFields": [
                  "Billing_Document_Number__c",
                  "Send_invoice__c",
                  "STEP8__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP9",
                "Required": [
                  "STEP6"
                ],
                "Actions": [
          {
            "FunctionName": "SIDRALiteAction",
            "ActionLabel": "AMS_OSCAR_Action7",
            "args": [
              "oscarid", "9"
            ]
          }
        ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step9_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "STEP9__c"
                ],
                "IsDependent": true
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_CHANGE_PROCESSING",
            "Steps": [
              {
                "Name": "STEP11",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "createIFAP",
                    "ActionLabel": "AMS_OSCAR_Action3",
                    "args": [
                      "oscarid"
                    ]
                  },
				  {
                    "FunctionName": "SIDRALiteAction",
                    "ActionLabel": "AMS_OSCAR_Action7",
                    "args": [
                      "oscarid", "11"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step11_inProgress"
                  }
                ],
                "DisplayFields": [
                  "ANG_FA_Opt_out__c",
                  "STEP11__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP34",
                "Required": [],
                "Actions": [],
                "Automations": [],
                "DisplayFields": [
                  "Is_using_credit_card__c",
                  "Requested_Bank_Guarantee_amount__c",
                  "Requested_Bank_Guarantee_currency__c",
                  "Send_FS_request__c",
                  "STEP34__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP35",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "createFSObject",
                    "ActionLabel": "AMS_OSCAR_Action14",
                    "args": [
                      "agencyid",
                      "accountNameFromOscar"
                    ]
                  },
          {
                    "FunctionName": "SIDRALiteAction",
                    "ActionLabel": "AMS_OSCAR_Action7",
                    "args": [
                      "oscarid", "35"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step35_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step35_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step35_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Received_Bank_Guarantee_amount__c",
                  "Received_Bank_Guarantee_currency__c",
                  "STEP35__c"
                ],
                "IsDependent": true
              },
              {
                "Name": "STEP14",
                "Required": [
                  "STEP8",
                  "STEP9"
                ],
                "Actions": [
          {
            "FunctionName": "SIDRALiteAction",
            "ActionLabel": "AMS_OSCAR_Action7",
            "args": [
              "oscarid", "14"
            ]
          }
        ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_succeeded"
                  },
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_inProgress"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step14_failed"
                  }
                ],
                "DisplayFields": [
                  "Send_agreement__c",
                  "STEP14__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_VALIDATION",
            "Steps": [
              {
                "Name": "STEP15",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step15_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step15_failed"
                  }
                ],
                "DisplayFields": [
                  "Validation_Status__c",
                  "Comments_validate__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APPROVAL",
            "Steps": [
              {
                "Name": "STEP2",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "forecast",
                    "ActionLabel": "AMS_OSCAR_Action16",
                    "args": [
                      "oscarid"
                    ]
                  },
          {
                    "FunctionName": "SIDRALiteAction",
                    "ActionLabel": "AMS_OSCAR_Action7",
                    "args": [
                      "oscarid", "RPM"
                    ]
                  }],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step2_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step2_failed"
                  }
                ],
                "DisplayFields": [
                  "RPM_Approval__c",
                  "Comments_approval__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "ANG_OSCAR_CHANGE_APPROVAL_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP36",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "createRiskEvent",
                    "ActionLabel": "AMS_OSCAR_Action15",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step36_succeeded"
                  }
                ],
                "DisplayFields": [
                  "STEP36__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP1",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_failed"
                  }
                ],
                "DisplayFields": [
                  "Update_DPC__c",
                  "Update_IRIS__c",
                  "Update_BSPLink__c",
                  "Update_Portal_Setup__c",
                  "Release_previous_FS_if_applicable__c",
                  "Send_approval_letter__c",
                  "Welcome_pack__c",
                  "Off_site_storage__c",
                  "Welcome_call__c",
                  "Effective_date__c",
                  "STEP1__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "ANG_OSCAR_CHANGE_DISAPPROVAL_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP3",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step3_failed"
                  }
                ],
                "DisplayFields": [
                  "Issue_disapproval_pack__c",
                  "Issue_credit_note_if_applicable__c",
                  "Release_FS_if_applicable__c",
                  "STEP3__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "ANG_OSCAR_CHANGE_REJECTION_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP18",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step18_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Issue_rejection_notification_pack__c",
                  "STEP18__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "ANG_OSCAR_CHANGE_WITHDRAWAL_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP4",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step4_failed"
                  }
                ],
                "DisplayFields": [
                  "Issue_Withdrawal_notification__c",
                  "Issue_credit_note_withdrawal__c",
                  "Release_FS_withdrawal__c",
                  "STEP4__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "NGCORRECTION.1.0",
        "Flows": [
          {
            "Name": "AMS_PERFORM_CORRECTION",
            "Steps": [
              {
                "Name": "STEP6",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "ANG_checkAccountHierarchy",
                    "ActionLabel": "AMS_OSCAR_Action6",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_failed"
                  }
                ],
                "DisplayFields": [
                  "Is_PCI_compliant__c",
                  "ANG_PCI_compliance_expiry_date__c",
                  "ANG_Type_of_change_hidden__c",
                  "STEP6__c",
                  "AMS_Correction_change_code__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "IEP.MODEL.A.ACCOUNT.SETUP",
        "Flows": [
          {
            "Name": "AMS_OSCAR_APPLICATIONRECEIPT",
            "Steps": [
              {
                "Name": "STEP6",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_failed"
                  }
                ],
                "DisplayFields": [
                "New_docs_Received__c",
                  "STEP6__c"                  
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_ANTIMONEYLAUNDERING",
            "Steps": [
              {
                "Name": "STEP17",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "performAML",
                    "ActionLabel": "AMS_OSCAR_Action4",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_inProgress"
                  },
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_failed"
                  }
                ],
                "DisplayFields": [
                  "STEP17__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "IEP.MODEL.B.ACCOUNT.SETUP",
        "Flows": [
          {
            "Name": "AMS_OSCAR_APPLICATIONRECEIPT",
            "Steps": [
              {
                "Name": "STEP6",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_failed"
                  }
                ],
                "DisplayFields": [
                "New_docs_Received__c",
                "ANG_Share_documentation_with_vendor__c",
                  "STEP6__c"                  
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_ANTIMONEYLAUNDERING",
            "Steps": [
              {
                "Name": "STEP17",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "performAML",
                    "ActionLabel": "AMS_OSCAR_Action4",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_inProgress"
                  },
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_failed"
                  }
                ],
                "DisplayFields": [
                  "STEP17__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "IEP.BANK.ACCOUNT.SETUP",
        "Flows": [
          {
            "Name": "AMS_OSCAR_APPLICATIONRECEIPT",
            "Steps": [
              {
                "Name": "STEP6",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_failed"
                  }
                ],
                "DisplayFields": [
                "New_docs_Received__c",
                  "STEP6__c"                  
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_ANTIMONEYLAUNDERING",
            "Steps": [
              {
                "Name": "STEP17",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "performAML",
                    "ActionLabel": "AMS_OSCAR_Action4",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_inProgress"
                  },
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step17_failed"
                  }
                ],
                "DisplayFields": [
                  "STEP17__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_SETUP_PROCESSING",
            "Steps": [
              {
                "Name": "STEP41",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step41_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step41_failed"
                  }
                ],
                "DisplayFields": [
                  "Update_IRIS_processing__c",
                  "STEP41__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "ANG.FOPMANAGEMENT.1.0",
        "Flows": [
          {
            "Name": "ANG_RESTRICT_FOP",
            "Steps": [
              {
                "Name": "STEP38",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step38_succeeded"
                  }
                ],
                "DisplayFields": [
                  "ANG_Restrict_Cash__c",
                  "ANG_Restrict_Credit_Card__c",
                  "STEP38__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "ANG_RESTORE_FOP",
            "Steps": [
              {
                "Name": "STEP39",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step39_succeeded"
                  }
                ],
                "DisplayFields": [
                  "ANG_Restore_Cash__c",
                  "ANG_Restore_Credit_Card__c",
                  "STEP39__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "ANG_PCI_COMPLIANT",
            "Steps": [
              {
                "Name": "STEP40",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "ANG_checkAccountHierarchy",
                    "ActionLabel": "AMS_OSCAR_Action6",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [],
                "DisplayFields": [
                  "Is_PCI_compliant__c",
                  "ANG_PCI_compliance_expiry_date__c",
                  "ANG_Sanity_checks__c",
                  "STEP40__c"
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
    {
    "Name": "PCI.COMPLIANT.1.0",
    "Flows": [
      {
      "Name": "AMS_OSCAR_APPLICATIONRECEIPT",
      "Steps": [
        {
        "Name": "STEP6",
        "Required": [],
        "Actions": [],
        "Automations": [
          {
          "Status": "Passed",
          "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
          },
          {
          "Status": "Failed",
          "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_failed"
          }
        ],
        "DisplayFields": [
          "Is_PCI_compliant__c",
          "ANG_PCI_compliance_expiry_date__c",
          "STEP6__c"
        ],
        "IsDependent": false
        }
      ]
      }
    ]
    },
    {
        "Name": "ANG.FS.OPTINOUT",
        "Flows": [
          {
            "Name": "AMS_OSCAR_APPLICATIONPROCESSING",
            "Steps": [
              {
                "Name": "STEP11",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "createIFAP",
                    "ActionLabel": "AMS_OSCAR_Action3",
                    "args": [
                      "oscarid"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "In Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step11_inProgress"
                  }
                ],
                "DisplayFields": [
                  "STEP11__c"
                ],
                "IsDependent": false
              },
        {
                "Name": "STEP34",
                "Required": [],
                "Actions": [],
                "Automations": [],
                "DisplayFields": [
                  "Requested_Bank_Guarantee_amount__c",
                  "Requested_Bank_Guarantee_currency__c",
                  "Send_FS_request__c",
                  "STEP34__c"
                ],
                "IsDependent": false
              },
        {
                "Name": "STEP35",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "createFSObject",
                    "ActionLabel": "AMS_OSCAR_Action14",
                    "args": [
                      "agencyid",
                      "accountNameFromOscar"
                    ]
                  }
                ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step35_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step35_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step35_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "Received_Bank_Guarantee_amount__c",
                  "Received_Bank_Guarantee_currency__c",
                  "STEP35__c"
                ],
                "IsDependent": true
              }
            ]
          },
                {
            "Name": "AMS_OSCAR_APP_FINALIZATION",
            "Steps": [
              {
                "Name": "STEP1",
                "Required": [],
                "Actions": [  
        {
                    "FunctionName": "forecast",
                    "ActionLabel": "AMS_OSCAR_Action16",
                    "args": [
                      "oscarid"
                    ]
          }
        ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step1_failed"
                  }
                ],
                "DisplayFields": [
                  "STEP1__c"
                ],
                "IsDependent": false
              }
            ]
          }
      
      ]
      },
      {
        "Name": "ANG.ANNUAL.REVALIDATION",
        "Flows": [
          {
            "Name": "ANG_NON_COMPLIANCE",
            "Steps": [
              {
                "Name": "STEP43",
                "Required": [],
                "Actions": [],
                "Automations": [],
                "DisplayFields": [
                  "ANG_Administrative_non_compliance_date__c",
                  "STEP43__c"
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP44",
                "Required": [],
                "Actions": [
                  {
                    "FunctionName": "SIDRALiteAction",
                    "ActionLabel": "AMS_OSCAR_Action7",
                    "args": [
                      "oscarid", "44"
                    ]
                  }
                ],
                "Automations": [],
                "DisplayFields": [
                  "STEP44__c"
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_APPLICATIONRECEIPT",
            "Steps": [
              {
                "Name": "STEP6",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step6_failed"
                  }
                ],
                "DisplayFields": [
                "Documentation_remarks__c",
                "New_docs_Received__c",
                  "STEP6__c"                  
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      },
      {
        "Name": "ANG.GDI.1.0",
        "Flows": [
          {
            "Name": "AMS_OSCAR_GDI_fees",
            "Steps": [
              {
                "Name": "STEP46",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step46_passed"
                  },
                  {
                    "Status": "in Progress",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step46_inProgress"
                  }
                ],
                "DisplayFields": [
                  "STEP46__c"                  
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP47",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step47_passed"
                  }
                ],
                "DisplayFields": [
                  "Billing_Document_Number__c",
                  "Send_invoice__c",
                  "STEP47__c"                  
                ],
                "IsDependent": false
              },
              {
                "Name": "STEP48",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step48_passed"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step48_failed"
                  },
                  {
                    "Status": "Not Applicable",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step48_notApplicable"
                  }
                ],
                "DisplayFields": [
                  "STEP48__c"                  
                ],
                "IsDependent": false
              }
            ]
          },

          {
            "Name": "AMS_OSCAR_GDI_ENDORSEMENT",
            "Steps": [
              {
                "Name": "STEP49",
                "Required": [],
                "Actions": [],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step49_passed"
                  }
                ],
                "DisplayFields": [
                  "Endorsement_Requested__c",
                  "STEP49__c"                  
                ],
                "IsDependent": false
              }
            ]
          },
          {
            "Name": "AMS_OSCAR_GDI_FINANCIAL_SECURITY",
            "Steps": [
              {
                "Name": "STEP50",
                "Required": [],
                "Actions": [
                  {
                      "FunctionName": "openFS",
                      "ActionLabel": "AMS_OSCAR_Action20",
                      "args": [
                        "oscarid"
                      ]
                }
              ],
                "Automations": [
                  {
                    "Status": "Passed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step50_passed"
                  },
                  {
                    "Status": "Failed",
                    "ClassName": "AMS_OSCAR_Automation.AMS_OSCAR_Step50_failed"
                  }
                ],
                "DisplayFields": [
                  "Financial_Security_Received__c",
                  "STEP50__c"                  
                ],
                "IsDependent": false
              }
            ]
          }
        ]
      }     
    ]
  }
}
