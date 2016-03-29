module.exports = function(grunt) {
  var localConfig = grunt.file.readJSON('../../../config.json');

  // Project configuration.
  grunt.initConfig({
    //pkg: grunt.file.readJSON('package.json'),
    antretrieve: {
        options: {
          maxPoll: 5000,
          pollWaitMillis: 1000,
        },
        // specify one retrieve target 
        iec: {
          options: {
            serverurl: localConfig.salesforce.iec.serverurl || localConfig.salesforce._default_.serverurl,
            user: localConfig.salesforce.iec.username || (localConfig.salesforce._default_.username + '.iec'),
            pass: localConfig.salesforce.iec.password || localConfig.salesforce._default_.password,
            token: localConfig.salesforce.iec.token || localConfig.salesforce._default_.token,
            retrieveTarget: 'build/iec'
          },

          pkg: {
            ApexClass: [
              'vfIECGAD',
              'BtchAirlinesStatistics',
              'vfIECGADAdvanced',
              'IECApplicationsManager',
              'vfIECSavedFilters',
              'vfIATAPassengersList',
              'vfIECGADResult',
              'vfIECGADMaps',
              'Test_SchdlGDPProdAccountSnapshotCleanup',
              'vfIECHomePage',
              'vfIECAppHeaderComponent',
              'IECConstants',
              'IECSubscriptionManager',
              'vfIECSubscriptionInfo',
              'IECPageController',
              'SchdlGDPProductsAccountSnapshotCleanup',
            ],
            CustomObject: [
              'GDP_Airlines_Statistic__c',
              'GDP_Products_Account_Snapshot__c',
            ],
            CustomField: [
              'IEC_Application_Filter__c.Product_Line__c',
              'GDP_Products_Account_View__c.Location_Type_Name__c',
              'GDP_Products_Account_View__c.Related_Accreditation_Class_Code__c',
              'GDP_Products_Account_View__c.Related_Accreditation_Class_Table__c',
              'GDP_Products_Account_Snapshot__c.Agency_Code__c',
            ],
            ApexComponent: [
              'IECSearchOptions',
              'IECAppHeader',
              'IECSubscriptionInfo',
            ],
            ApexPage: [
              'IECGAD',
              'IATAPassengersList',
              'IECGADAdvanced',
              'IECGADResult',
              'IECHomepage',
            ]
          }
        },

        projecttroisb: {
          options: {
            serverurl: localConfig.salesforce.troisb.serverurl || localConfig.salesforce._default_.serverurl,
            user: localConfig.salesforce.troisb.username || (localConfig.salesforce._default_.username + '.3b'),
            pass: localConfig.salesforce.troisb.password || localConfig.salesforce._default_.password,
            token: localConfig.salesforce.troisb.token || localConfig.salesforce._default_.token,
            retrieveTarget: 'build/3b',
            existingPackage: true
          }
        },

        preprod: {
          options: {
            serverurl: localConfig.salesforce.preprod.serverurl || localConfig.salesforce._default_.serverurl,
            user: localConfig.salesforce.preprod.username || (localConfig.salesforce._default_.username + '.preprod'),
            pass: localConfig.salesforce.preprod.password || localConfig.salesforce._default_.password,
            token: localConfig.salesforce.preprod.token || localConfig.salesforce._default_.token,
            retrieveTarget: 'build/preprod',
            existingPackage: true
          }
        }
      },
      antdeploy:{
        options: {
          maxPoll: 5000,
          pollWaitMillis: 5000
        },
        // specify one retrieve target 
        projecttroisb: {
          options: {
            serverurl: localConfig.salesforce.troisb.serverurl || localConfig.salesforce._default_.serverurl,
            user: localConfig.salesforce.troisb.username || (localConfig.salesforce._default_.username + '.3b'),
            pass: localConfig.salesforce.troisb.password || localConfig.salesforce._default_.password,
            token: localConfig.salesforce.troisb.token || localConfig.salesforce._default_.token,
            existingPackage: true,
            root: 'build/3b',

            runAllTests: false,
          }
        },
        preprod: {
          options: {
            serverurl: localConfig.salesforce.preprod.serverurl || localConfig.salesforce._default_.serverurl,
            user: localConfig.salesforce.preprod.username || (localConfig.salesforce._default_.username + '.preprod'),
            pass: localConfig.salesforce.preprod.password || localConfig.salesforce._default_.password,
            token: localConfig.salesforce.preprod.token || localConfig.salesforce._default_.token,
            existingPackage: true,
            root: 'build/preprod',

            runAllTests: false,
          }
        }
      }

  });




  // Load the plugin that provides the "uglify" task.
  grunt.loadNpmTasks('grunt-ant-sfdc');

  // Default task(s).
  grunt.registerTask('default', ['antretrieve', 'antdeploy']);

};