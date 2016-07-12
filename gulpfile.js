'use strict';

const gulp       = require('gulp');
const browserify = require('browserify');
const source     = require('vinyl-source-stream');
const babel      = require('gulp-babel');
const uglify     = require('gulp-uglify');

function build_index(is_debug) {
    return  browserify({
                entries: './pubsrc/index.js',
                transform: 'riotify',
                debug:     is_debug
            }).bundle()
            .pipe(source('index.js') )
            .pipe(gulp.dest('./public/js/') );
}

gulp.task('build-index', () => build_index(true)  );
gulp.task('build',       ['build-index']);

gulp.task('build-dist-index', () => build_index(false) );
gulp.task('build-dist', ['build-dist-index'], () => {
    gulp.src('./public/js/*.js')
        .pipe(babel({ presets: ['es2015'] }) )
        .pipe(uglify() )
        .pipe(gulp.dest('./public/js/') );
});
