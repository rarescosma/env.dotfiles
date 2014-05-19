module.exports = function (grunt) {
    var originalRunAllTargets = grunt.task.runAllTargets;
    grunt.task.runAllTargets = function(taskname, args) {

        var targets = grunt.config.getRaw(taskname) || {},
            excluded;

        function isValidMultiTaskTarget(name) {
            return !/^_|^options$/.test(name);
        }

        excluded = targets._exclude;
        if (typeof excluded === 'undefined') {
            originalRunAllTargets(taskname, args);
        } else {
            if ('string' === typeof excluded) {
                excluded = [excluded];
            }

            excluded.map(function(name) {
                if (! isValidMultiTaskTarget(name)) {
                   throw new Error('Invalid exclude target "' + name + '" specified.');
                }
            });

            excluded.push('_exclude');

            Object.keys(targets).map(function(name) {
                if (-1 === excluded.indexOf(name)) {
                    grunt.task.run([taskname, name].concat(args || []).join(':'));
                }
            });
        }
    };
};