#Init gunt module
module.exports = (grunt) ->
    'use strict';

    #Init Configuration
    grunt.initConfig
        #Load the package file
        pkg : grunt.file.readJSON 'package.json'
        coffee:
            app:
                options :
                    sourceMap: true
                expand: true
                cwd: 'coffee'
                src: ['**/*.coffee']
                dest: 'js'
                ext: '.js'

        browserify:
            libs:
                src: ["backbone", "three", "jquery"]
                dest: "build/libs.js"


            dev:
                files:
                    "build/plane-test.js": ["src/plane-test.coffee"]
                options:
                    shim:
                        jquery:
                            path: 'vendor/jquery/dist/jquery.js'
                            exports: '$'
                        underscore:
                            path: 'vendor/underscore/underscore.js'
                            exports: '_'
                        backbone:
                            path: 'vendor/backbone/backbone.js'
                            exports: 'Backbone'
                            depends:
                                underscore: '_'
                        templates:
                            path: 'templates/**/*.html'
                            exports: null
                            depends:
                                underscore: '_'
                    browserifyOptions:
                        extensions: ['.coffee']
                        #commondir: false
                        basedir: "./src"
                    bundleOptions:
                        debug: true
                    # Exclude the libs here
                    exclude: ["backbone", "jquery", "underscore", "three", "backbone.marionette"]
                    preBundleCB: (b) ->
                        b.transform "coffeeify"
                        #b.transform "node-underscorify"
                        #b.transform "uglifyify"
                        #b.on 'remapify:files', () ->
                        #    console.log arguments[1]

                        b.plugin "remapify", [{
                            src: './**/*.*'
                            expose: 'src'
                            cwd : "src"
                        },{
                            src: './**/*.*'
                            expose: 'app'
                            cwd : "src/app"
                        },{
                            src: './**/*.*'
                            expose: 'mixins'
                            cwd : "src/app/mixins"
                        },{
                            src: './**/*.*'
                            expose: 'utils'
                            cwd: "src/app/utils"
                        },{
                            src: './**/*.*'
                            expose: 'modules'
                            cwd: "src/app/modules"
                        },{
                            src: './**/*.*'
                            expose: 'mixins'
                            cwd: "src/app/mixins"
                        },{
                            src: './**/*.*'
                            expose: 'vendor'
                            cwd: "src/vendor"
                        },{
                            src: './**/*.*'
                            expose: 'test'
                            cwd: "src/test"
                        },{
                            src: './**/*.*'
                            expose: 'templates'
                            cwd: "src/templates"
                        },{
                            src: './**/*.*'
                            expose: 'plugins'
                            cwd: "src/plugins"
                        },{
                            src: './**/*.*'
                            expose: 'shaders'
                            cwd: "src/shaders"
                        }]

        compass:
            app:
                options:
                    config: 'config.rb'
                ###
                options:
                    sassDir: 'css/sass'
                    cssDir: 'css'
                    imagesDir: 'img'
                    fontsDir: 'css/fonts'
                    httpPath: "/"
                    relativeAssets: true
                    boring: true
                    debugInfo: false
                    outputStyle: 'compressed'
                    enable_sourcemaps: true
                    sourcemap: true
                    raw: 'sass_options = {:preferred_syntax => :scss}\n'
                    require: []
                ###

        docco:
            debug:
                src : ['coffee/**/*.coffee']
                options :
                    output : "docs/"

        coffeelint:
            app : ['**/*.coffee']

        testem :
            main :
                files :
                    "testes.tap" : ["testem.json"]
        ###
        bless:
            ie:
                options: 
                    compress: true
                files:
                    # Target-specific file lists and/or options go here.
                    "css/screen.css":"css/split/screen.css"
        ###

        watch:
            #app:
            #    files: '**/*.coffee'
            #    tasks: ['coffee']
            browserify:
                files: ['src/**/*.coffee', 'src/**/*.js', 'src/**/*.html']
                tasks: ['browserify:dev']

            sass:
                files: ['**/*.scss']
                tasks: ['compass']

    #########################
    # Grunt modules include #
    #########################
    #-- Coffee Script
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    #-- Watch
    grunt.loadNpmTasks 'grunt-contrib-watch'
    #-- Docco
    grunt.loadNpmTasks 'grunt-docco'
    #-- Coffee Lint
    grunt.loadNpmTasks 'grunt-coffeelint'
    #-- Browserify
    grunt.loadNpmTasks('grunt-browserify');
    #-- Splitsuit (Css splitter for old IE)
    #grunt.loadNpmTasks 'grunt-splitsuit'
    #Developement Task
    grunt.registerTask 'dev', ['coffee', "compass", "testem"]

    #Preprod and Production task
    #grunt.registerTask 'prod', []

    #Run the default task
    grunt.registerTask 'default', ['dev']
    ###

    ###
