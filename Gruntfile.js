'use strict';

var userhome = require('userhome');
var path = require('path');
var hash = require('es-hash');

var choicesZshPlugins = require('./choices/zsh_plugins');
var choicesProvision = require('./choices/provision');
var choicesPhpExtensions = require('./choices/php_extensions');

function copyConfigChoicesAsBooleans(config, choices, from, to) {
    config[to] = config[to] || {};
    choices.forEach(function(choice) {
        config[to][choice.value] =
            config.choices[from].indexOf(choice.value) > -1;
    });
}

function copyConfigChoicesAsString(config, choices, from, to) {
    var values = [];
    config.choices[from] = config.choices[from] || [];
    choices.forEach(function(choice) {
        if(config.choices[from].indexOf(choice.value) > -1) {
            values.push(choice.value);
        }
    });
    config[to] = config[to] || {};
    config[to][from] = values.join(' ');
}

module.exports = function(grunt) {

    grunt.initConfig({

        // -- Bump -------------------------------------------------------------

        bump: {

            options: {
                commit: true,
                commitFiles: ['package.json'],
                commitMessage: 'Release v%VERSION%',
                createTag: true,
                files: ['package.json'],
                push: false,
                pushTo: 'origin',
                tagMessage: '',
                tagName: 'v%VERSION%'
            }

        },

        // -- Config -----------------------------------------------------------

        config: {
            _exclude: 'provision',

            paths: {
                home: userhome(),
                dotfiles: userhome('.dotfiles'),
                zsh_syntax_plugin: userhome('.dotfiles/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting'),
                oh_my_zsh: userhome('.dotfiles/.oh-my-zsh'),
                provision_script: userhome('.dotfiles/provision')
            },

            links: {
                template: {
                    src: userhome('.dotfiles'),
                    files: ['.gitconfig', '.gitignore_global', '.zshrc', '.zlogin', '.npmrc']
                },
                direct: {
                    src: path.resolve(__dirname) + '/templates',
                    dest: userhome('.dotfiles'),
                    files: ['.env', '.aliases', '.navigation']
                },
                env: {
                    src: path.resolve(__dirname) + '/templates',
                    files:['.rvmrc']
                }
            }
        },

        // -- Prompt -----------------------------------------------------------

        prompt: {
            _exclude: 'provision',

            git: {
                options: {
                    questions: [
                        {
                            config: 'config.git.name',
                            default: 'Rares Cosma',
                            message: 'Which Git name would you like to use?'
                        },
                        {
                            config: 'config.git.email',
                            default: 'office@rarescosma.com',
                            message: 'Which Git email would you like to use?'
                        },
                    ]
                }
            },

            zsh: {
                options: {
                    questions: [
                        {
                            config: 'config.zsh.theme_oh_my_zsh',
                            default: 'ric',
                            message: 'Which Oh My Zsh theme would you like to use?'
                        },
                        {
                            choices: choicesZshPlugins,
                            config: 'config.choices.zsh_plugins',
                            message: 'Which Oh My Zsh plugins would you like to use?',
                            type: 'checkbox'
                        },
                    ]
                }
            },

            provision: {
                options: {
                    questions: [
                        {
                            choices: choicesProvision,
                            config: 'config.choices.provision',
                            message: 'Which system components would you like to provision?',
                            type: 'checkbox'
                        },
                        {
                            choices: choicesPhpExtensions,
                            config: 'config.choices.php_extensions',
                            message: 'Which PHP extensions would you like to install?',
                            type: 'checkbox',
                            when: function(answers) {
                                return answers['config.choices.provision'].indexOf('lemp') > -1;
                            }
                        },
                        {
                            choices: [
                                { name: 'Xfce4', value: 'xfce' },
                                { name: 'Mate', value: 'mate' }
                            ],
                            config: 'config.gui',
                            message: 'Which window manager would you like to install?',
                            type: 'list',
                            when: function(answers) {
                                return answers['config.choices.provision'].indexOf('gui') > -1;
                            }
                        },
                        {
                            config: 'config.zsh.theme_oh_my_zsh',
                            default: 'ric',
                            message: 'Which Oh My Zsh theme would you like to use?',
                            when: function(answers) {
                                return answers['config.choices.provision'].indexOf('env') > -1 &&
                                'undefined' === typeof answers['config.zsh.theme_oh_my_zsh'];
                            }
                        }
                    ]
                }
            }
        },

        // -- Clean ------------------------------------------------------------

        clean: {
            all: {
                options: {
                    force: true
                },
                src: [
                    '<%= config.paths.dotfiles %>',
                    '<%= config.paths.home %>/.gitconfig',
                    '<%= config.paths.home %>/.gitignore_global',
                    '<%= config.paths.home %>/.zshrc',
                    '<%= config.paths.home %>/.zlogin',
                    '<%= config.paths.home %>/.z'
                ]
            }
        },

        // -- Templates --------------------------------------------------------

        template: {
            _exclude: 'provision',

            git: {
                options: {
                    data: '<%= config %>'
                },
                files: {
                    '<%= config.paths.dotfiles %>/.gitconfig': ['templates/.gitconfig'],
                    '<%= config.paths.dotfiles %>/.gitignore_global': ['templates/.gitignore_global']
                }
            },

            zsh: {
                options: {
                    data: function() {
                        var config = grunt.config.data.config;
                        copyConfigChoicesAsString(config, choicesZshPlugins, 'zsh_plugins', 'zsh');
                        return config;
                    }
                },
                files: {
                    '<%= config.paths.dotfiles %>/.zshrc': ['templates/.zshrc'],
                    '<%= config.paths.dotfiles %>/.zlogin': ['templates/.zlogin'],
                    '<%= config.paths.dotfiles %>/.npmrc': ['templates/.npmrc']
                }
            },

            provision: {
                options: {
                    data: function() {
                        var config = grunt.config.data.config;
                        copyConfigChoicesAsBooleans(config, choicesProvision, 'provision', 'provision');
                        copyConfigChoicesAsString(config, choicesPhpExtensions, 'php_extensions', 'lemp');
                        return config;
                    }
                },
                files: {
                    '<%= config.paths.provision_script %>': [
                        'provision/00.alpha',
                        'provision/01.lemp',
                        'provision/02.gui',
                        'provision/04.python',
                        'provision/99.omega'
                    ]
                }
            }
        },

        // -- Git --------------------------------------------------------------

        gitclone: {
            oh_my_zsh: {
                options: {
                    directory: '<%= config.paths.oh_my_zsh %>',
                    repository: 'https://github.com/rarescosma/oh-my-zsh.git'
                }
            },

            zsh_syntax_highlighting: {
                options: {
                    directory: '<%= config.paths.zsh_syntax_plugin %>',
                    repository: 'https://github.com/zsh-users/zsh-syntax-highlighting.git'
                }
            }
        },

        // -- Exec -------------------------------------------------------------

        shell: {
            _exclude: 'provision',

            z: {
                command: 'touch <%= config.paths.home %>/.z'
            },

            provision: {
                command: 'chmod +x <%= config.paths.provision_script %> && <%= config.paths.provision_script %>',
                options: {
                    stdout: true
                }
            },
        }
    });

    // -- Symbolic links -------------------------------------------------------
    grunt.registerTask('symlinkProxy', function(category){
        var config = grunt.config.data.config;
        if('object' !== typeof config.links[category]) {
            return false;
        }

        var links = config.links[category], options, h, dest;

        links.files.forEach(function(l) {
            dest = links.dest || config.paths.home;
            options = {
                dest: dest + '/' + l,
                relativeSrc: links.src + '/' + l
            };
            h = hash(options);

            grunt.config('symlink.' + h, options);
            grunt.task.run('symlink:' + h);
        });
    });

    grunt.loadTasks('tasks');
    grunt.loadNpmTasks('grunt-bump');
    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-git');
    grunt.loadNpmTasks('grunt-prompt');
    grunt.loadNpmTasks('grunt-shell');
    grunt.loadNpmTasks('grunt-symlink');
    grunt.loadNpmTasks('grunt-template');

    grunt.registerTask('sym', ['symlinkProxy:template', 'symlinkProxy:direct', 'symlinkProxy:env']);

    grunt.registerTask('default', [
        'prompt',
        'clean',
        'template',
        'gitclone',
        'shell',
        'sym'
    ]);

    grunt.registerTask('provision', ['prompt:provision', 'template:provision', 'shell:provision'])  ;
};