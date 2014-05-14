module.exports = function(grunt) {
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-jade');
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
                        'app/coffee/*'
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
            }
        },
        coffee: {
            compile: {
                options: {
                    join: true
                },
                files: {
                    'app/static/js/source.js': ['app/coffee/**/*.coffee']
                }
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
        }
    });

    grunt.registerTask('server', ['shell:runserver', 'watch'])
};
