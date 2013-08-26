module.exports = (grunt) ->
  grunt.initConfig {

    compass:
      dist:
        options:
          sassDir: "sass"
          cssDir: "."
          specify: "number-polyfill.scss"
          environment: "production"
          debugInfo: false

    coffee:
      build:
        expand: true
        flatten: true
        cwd: '.'
        src: ['number-polyfill.coffee']
        dest: '.'
        ext: '.js'
        options:
          bare: true

    uglify:
      dist:
        files:
          'number-polyfill.min.js': 'number-polyfill.js'
  }

  grunt.loadNpmTasks 'grunt-contrib-compass'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-coffee'

  grunt.registerTask 'default', ['coffee', 'uglify', 'compass']
