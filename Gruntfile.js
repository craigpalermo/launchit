module.exports = function(grunt) {
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-jade');
    grunt.loadNpmTasks('grunt-contrib-stylus');
    grunt.loadNpmTasks('grunt-shell');

    grunt.initConfig({
        shell: {
            runserver: {
                command: 'python launchit/manage.py runserver 0.0.0.0:8000 &'
            }
        },
        watch: {
            livereload: {
                files: ['app/static/css/*',
                        'app/static/js/*',
                        'app/static/partials/*',
                        'app/templates/*',
                        'app/coffee/*',
                        'app/stylus/*'
                       ],
                options: { livereload: true },
            },
            coffee: {
                files: ['app/coffee/**/*.coffee'],
                tasks: ['coffee:compile']
            },
            jade: {
                files: ['app/jade/**/*.jade'],
                tasks: ['jade:compile']
            },
            stylus: {
                files: ['app/stylus/**/*.styl'],
                tasks: ['stylus:compile']
            }
        },
        coffee: {
            compile: {
                options: {
                    join: true
                },
                files: [{
                    'app/static/js/app.js': ['app/coffee/app.coffee'],
                },{
                    expand: true,
                    cwd: "app/coffee/controllers/",
                    src: ['**/*.coffee'],
                    dest: 'app/static/js',
                    ext: '.js'
                }]
            }
        },
        jade: {
            compile: {
                files: [{
                    expand: true,
                    cwd: "app/jade/partials/",
                    src: ['**/*.jade'],
                    dest: 'app/static/views',
                    ext: '.html'
                },{
                    expand: true,
                    cwd: "app/jade/",
                    src: ['index.jade'],
                    dest: 'app/templates',
                    ext: '.html'
                }]
            }
        },
        stylus: {
            compile: {
                files: [{
                    expand: true,
                    cwd: "app/stylus/",
                    src: ['**/*.styl'],
                    dest: 'app/static/css',
                    ext: '.css'
                }]
            }
        }
    });

    grunt.registerTask('server', ['shell:runserver', 'watch'])
};
