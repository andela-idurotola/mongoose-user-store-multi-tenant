_ = require 'underscore'

coffeeRename = (destBase, destPath) ->
  destPath = destPath.replace 'src/',''
  destBase + destPath.replace /\.coffee$/, '.js'

module.exports = (grunt) ->

  filterGrunt = ->
    gruntFiles = require("matchdep").filterDev("grunt-*")
    _.reject gruntFiles, (x) -> x is 'grunt-cli'

  filterGrunt().forEach grunt.loadNpmTasks

  grunt.initConfig
    coffee:
      compile:
        options:
          sourceMap: true

        files: grunt.file.expandMapping(['src/**/*.coffee'], 'lib/', {rename: coffeeRename })
 
    shell:
      options:
        stdout: true
      npm_install:
        command: "npm install"

    env:
      dev:
        NODE_ENV: "development"
      test:
        NODE_ENV: "test"

    codo:
      options:
        undocumented: true
        private: true
        analytics: false
      src: ['src/**/*.coffee']

    mochaTest:
      test:
        options:
          reporter: 'spec'
          require: 'coffee-script/register'
        src: ['test/**/*-tests.coffee']

    release:
      options: {}
      
    mochacov:
      options:
        coveralls:
          repoToken: "n8StkG9ERyAYs2w2OlN3yk384bfB6HDHu"
        require: ['coffee-script/register','should']
      all: ['test/**/*-tests.coffee']

    watch:
      scripts:
        files: ['src/**/*.coffee']
        tasks: ['build']
        options:
          livereload: false

      tests:
        files: ['test/**/*.coffee']
        tasks: ['build']
        options:
          livereload: false


  grunt.registerTask "install", [
    "shell:npm_install"
  ]

  grunt.registerTask "build", [
    'env:dev'
    'codo'
    'coffee'
    'test'
  ]

  grunt.registerTask "test", [
    'env:test'
    'mochaTest:test'
  ]

  grunt.registerTask "testandcoverage", [
    'env:test'
    'mochaTest:test'
    'mochacov'
  ]


  grunt.registerTask 'deploy', [
    'build'
    'release'
  ]

  grunt.registerTask 'default', ['build', 'watch']
