gulp      = require 'gulp'
gutil     = require 'gulp-util'
pkg       = require './package.json'
fs        = require 'fs'
header    = require 'gulp-header'
footer    = require 'gulp-footer'
livereload = require 'gulp-livereload'

coffee      = require 'gulp-coffee'
concat      = require 'gulp-concat'
coffeelint  = require 'gulp-coffeelint' # https://github.com/wearefractal/gulp-jshint
esformatter = require 'gulp-esformatter'
esdefault   = require './esformatter.json'
ngClassify  = require 'gulp-ng-classify'
rename      = require 'gulp-rename'
uglify      = require 'gulp-uglify'

gulp.task 'lint', () ->
  gulp
  .src ['src/*.coffee']
  .pipe coffeelint(pkg.coffeelintrc)
  .pipe coffeelint.reporter()

# Compile coffeescript to javascript.
# @see Options for the coffeelint http://www.coffeelint.org/#options
# @see Options for the compiler http://coffeescript.org/#usage
gulp.task 'build', () ->
  gulp
  .src ['src/*.coffee']
  .pipe ngClassify({ appName: pkg.name })
  .pipe coffee(
      bare: true
  ).on 'error', gutil.log
  .pipe concat "#{pkg.name}.js"
  .pipe header fs.readFileSync('src/main.prefix.js', 'utf-8'), { pkg: pkg }
  .pipe footer fs.readFileSync 'src/main.suffix.js', 'utf-8'
  .pipe esformatter esdefault
  .pipe gulp.dest './dist/'
  .pipe rename "#{pkg.name}.min.js"
  .pipe uglify()
  .pipe gulp.dest './dist/'

gulp.task 'default', ['lint', 'build']

