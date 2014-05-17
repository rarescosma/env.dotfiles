'use strict';

var userhome = require('userhome');

var choicesZshPlugins = require('./choices/zsh_plugins');
var choicesProvision = require('./choices/provision');
var choicesPhpExtensions = require('./choices/php_extensions');

function copyConfigChoicesAsBooleans(config, choices, from, to) {
    choices.forEach(function(choice) {
        config[to][choice.value] =
            config.choices[from].indexOf(choice.value) > -1;
    });
}

function copyConfigChoicesAsString(config, choices, from, to) {
    var values = [];
    choices.forEach(function(choice) {
        values.push(choice.value);
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
                push: true,
                pushTo: 'origin',
                tagMessage: '',
                tagName: 'v%VERSION%'
            }

        },

        // -- Config -----------------------------------------------------------

        config: {
            dotfiles: {
                path: userhome('.dotfiles')
            },

            git: {
                path_gitconfig: userhome('.dotfiles/.gitconfig'),
                path_gitconfig_system: userhome('.gitconfig'),
                path_gitignore: userhome('.dotfiles/.gitignore_global'),
                path_gitignore_system: userhome('.gitignore_global')
            },

            z: {
                path_z_system: userhome('.z')
            },

            zsh: {
                path_oh_my_zsh: userhome('.dotfiles/.oh-my-zsh'),
                path_plugin_syntax: userhome('.dotfiles/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting'),
                path_zshrc: userhome('.dotfiles/.zshrc'),
                path_zshrc_system: userhome('.zshrc')
            },

            provision: {
                script_path: userhome('.dotfiles/provision')
            },
        },

        // -- Prompt -----------------------------------------------------------

        prompt: {
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
                            choices: [
                                { name: 'Mate', value: 'mate' },
                                { name: 'Xfce4', value: 'xfce' }
                            ],
                            config: 'config.wm',
                            message: 'Which window manager would you like to install?',
                            type: 'list',
                            when: function(answers) {
                                return answers['config.choices.provision'].indexOf('wm') > -1;
                            }
                        },
                        {
                            choices: choicesPhpExtensions,
                            config: 'config.choices.php_extensions',
                            message: 'Which PHP extensions would you like to provision?',
                            type: 'checkbox',
                            when: function(answers) {
                                return answers['config.choices.provision'].indexOf('lemp') > -1;
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
                    userhome('.dotfiles'),
                    '<%= config.z.path_z_system %>',
                    '<%= config.zsh.path_zshrc_system %>'
                ]
            }
        },

        // -- Templates --------------------------------------------------------

        template: {
            git: {
                options: {
                    data: '<%= config %>'
                },
                files: {
                    '<%= config.git.path_gitconfig %>': ['templates/.gitconfig'],
                    '<%= config.git.path_gitignore %>': ['templates/.gitignore_global']
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
                    '<%= config.dotfiles.path %>/.zshrc': ['templates/.zshrc'],
                    '<%= config.dotfiles.path %>/.aliases': ['templates/.aliases'],
                    '<%= config.dotfiles.path %>/.navigation': ['templates/.navigation']
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
                files: { '<%= config.provision.script_path %>': [
                    'provision/00.bang',
                    'provision/01.gui',
                    'provision/02.lemp'
                ] }
            }
        },

        // -- Git --------------------------------------------------------------

        gitclone: {
            oh_my_zsh: {
                options: {
                    directory: '<%= config.zsh.path_oh_my_zsh %>',
                    repository: 'https://github.com/rarescosma/oh-my-zsh.git'
                }
            },

            zsh_syntax_highlighting: {
                options: {
                    directory: '<%= config.zsh.path_plugin_syntax %>',
                    repository: 'https://github.com/zsh-users/zsh-syntax-highlighting.git'
                }
            }
        },

        // -- Symbolic links ---------------------------------------------------

        symlink: {
            git_config: {
                dest: '<%= config.git.path_gitconfig_system %>',
                relativeSrc: '<%= config.git.path_gitconfig %>'
            },

            git_ignore: {
                dest: '<%= config.git.path_gitignore_system %>',
                relativeSrc: '<%= config.git.path_gitignore %>'
            },

            zsh: {
                dest: '<%= config.zsh.path_zshrc_system %>',
                relativeSrc: '<%= config.zsh.path_zshrc %>'
            }
        },

        // -- Exec -------------------------------------------------------------

        shell: {
            z: {
                command: 'touch <%= config.z.path_z_system %>'
            },

            zsh: {
                command: 'sudo apt-get --yes install zsh; chsh -s /bin/zsh'
            },

            provision: {
                command: 'cat <%= config.provision.script_path %> | bash -s stable',
                options: {
                    stdout: true
                }
            },
        }

    });

    grunt.loadNpmTasks('grunt-bump');
    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-git');
    grunt.loadNpmTasks('grunt-prompt');
    grunt.loadNpmTasks('grunt-shell');
    grunt.loadNpmTasks('grunt-symlink');
    grunt.loadNpmTasks('grunt-template');

    grunt.registerTask('default', ['prompt', 'clean', 'template', 'gitclone', 'shell', 'symlink']);
    grunt.registerTask('provision', ['prompt:provision', 'template:provision', 'shell:provision']);
};