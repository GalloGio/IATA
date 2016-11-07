module.exports = function(grunt) {
  var localConfig = grunt.file.readJSON('../../../config.json');
  var changeset = grunt.file.readJSON('changeset.json');

  // Project configuration.
  grunt.initConfig({
    //pkg: grunt.file.readJSON('package.json'),
    antretrieve: {
        options: {
          maxPoll: 5000,
          pollWaitMillis: 1000,
          apiVersion: 31.0
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

          pkg: changeset
        },

        projecttroisb: {
          options: {
            serverurl: localConfig.salesforce.troisb.serverurl || localConfig.salesforce._default_.serverurl,
            user: localConfig.salesforce.troisb.username || (localConfig.salesforce._default_.username + '.3b'),
            pass: localConfig.salesforce.troisb.password || localConfig.salesforce._default_.password,
            token: localConfig.salesforce.troisb.token || localConfig.salesforce._default_.token,
            retrieveTarget: '../../src'
            //existingPackage: true
          },

          pkg: changeset
        }
      },
      antdeploy:{
        options: {
          maxPoll: 5000,
          pollWaitMillis: 5000,
          apiVersion: 37.0
        },
        // specify one retrieve target 
        projecttroisb: {
          options: {
            serverurl: localConfig.salesforce.troisb.serverurl || localConfig.salesforce._default_.serverurl,
            user: localConfig.salesforce.troisb.username || (localConfig.salesforce._default_.username + '.3b'),
            pass: localConfig.salesforce.troisb.password || localConfig.salesforce._default_.password,
            token: localConfig.salesforce.troisb.token || localConfig.salesforce._default_.token,
            root: '../../src',

            runAllTests: false,
          },

          pkg: changeset
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