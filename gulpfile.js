var gulp = require('gulp');

var stylus = require('gulp-stylus');
var autoprefixer = require('gulp-autoprefixer');
var minify = require('gulp-minify-css');

var coffee = require('gulp-coffee');
var uglify = require('gulp-uglify');
var rjs = require('gulp-requirejs');
var concat = require('gulp-concat');

var jade = require('gulp-jade');
var wrap = require('gulp-wrap-amd');

var exec = require('gulp-exec');

var rmrf = require('gulp-rimraf');
var nodemon = require('gulp-nodemon');
var watch = require('gulp-watch');
var plumber = require('gulp-plumber');
var livereload = require('gulp-livereload');
var server = require('tiny-lr')();

var autoprefixerParams = [
    'last 3 versions',
    'safari > 5',
    'ie > 9',
    'opera > 12'
];

gulp.task('stylus', function() {
    return gulp.src(['src/styl/styles.styl'])
        .pipe(plumber())
        .pipe(stylus())
        .pipe(autoprefixer.apply(null, autoprefixerParams))
        .pipe(minify())
        .pipe(livereload(server))
        .pipe(gulp.dest('public/css'));
});

gulp.task('coffee', function() {
    return gulp.src(['src/coffee/*.coffee'])
        .pipe(plumber())
        .pipe(coffee({ bare: true }))
        .pipe(gulp.dest('public/js'));
});

gulp.task('copy-vendor', function() {
    return gulp.src(['src/coffee/vendor/**/*'])
        .pipe(gulp.dest('public/js/vendor'));
});

gulp.task('jade', function() {
    return gulp.src([
            'views/carousel.jade', 'views/error.jade', 'views/spinner.jade'
        ])
        .pipe(jade({ client: true }))
        .pipe(wrap({ deps: ['runtime'], params: ['jade'] }))
        .pipe(livereload(server))
        .pipe(gulp.dest('public/views'));
});

gulp.task('nodemon', function() {
    return nodemon({
        restartable: 'rs',
        verbose: true,
        execMap: { js: 'node --harmony' },
        watch: ['app'],
        env: { NODE_ENV: 'development' },
        script: 'app/server.js'
    });
});

gulp.task('watch', function() {
    watch({ glob: 'src/styl/*.styl' }, function() {
        gulp.start('stylus');
    });
    watch({ glob: 'src/coffee/*.coffee' }, function() {
        gulp.start('coffee');
    });
    watch({ glob: 'views/*.jade' }, function() {
        gulp.start('jade')
    });
});

gulp.task('clean', function() {
    return gulp.src(
        ['public/js/**/*', 'public/css/**/*', 'public/views'],
        { read: false }
        ).pipe(rmrf());
});

gulp.task('default', ['clean', 'copy-vendor'], function() {
    server.listen(35729);

    gulp.start('watch', 'nodemon');
});

/*
    Build tasks
 */

gulp.task('build-js', function() {
    gulp.src(['src/coffee/*.coffee'])
        .pipe(coffee({ bare: true }))
        .pipe(gulp.dest('src/js'));

    return gulp.src(['src/coffee/vendor/**/*'])
        .pipe(gulp.dest('src/js/vendor'));
});

gulp.task('build-tpl', function() {
    return gulp.src([
            'views/carousel.jade', 'views/error.jade', 'views/spinner.jade'
        ])
        .pipe(jade({ client: true }))
        .pipe(wrap({ deps: ['runtime'], params: ['jade'] }))
        .pipe(gulp.dest('src/views'));
});

gulp.task('build', ['clean', 'stylus', 'build-js', 'build-tpl'], function() {
    return rjs({
        baseUrl: 'src/js/',
        mainConfigFile: 'src/js/main.js',
        name: 'vendor/almond/almond',
        include: ['main'],
        insertRequire: ['main'],
        out: 'main.js',
        wrap: true
    })
    .pipe(uglify())
    .pipe(exec('rm -r src/js src/views'))
    .pipe(gulp.dest('public/js'));
});
