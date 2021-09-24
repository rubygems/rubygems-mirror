= rubygems-mirror

https://github.com/rubygems/rubygems-mirror

{<img src="https://badge.fury.io/rb/rubygems-mirror.svg" alt="Gem Version" />}[http://badge.fury.io/rb/rubygems-mirror]

== DESCRIPTION:

This is an update to the old `gem mirror` command. It uses net/http/persistent
and threads to grab the mirror set a little faster than the original.
Eventually it will replace `gem mirror` completely. Right now the API is not
completely stable (it will change several times before release); however, I
will maintain stability in master.

== FEATURES/PROBLEMS:

* Fast mirroring
* Limited tests - just functional

== REQUIREMENTS:

* rubygems
* net/http/persistent
* builder
* webrick

== USAGE

* In a file at ~/.gem/.mirrorrc add a config that looks like the following:

    ---
    - from: http://rubygems.org
      to: /data/rubygems
      parallelism: 10
      retries: 3
      delete: false
      skiperror: true
      hashdir: false

* Either install the gem, then run `gem mirror`, or
* Clone then run `rake mirror:update`
* With the environment variable `RUBYGEMS_MIRROR_ONLY_LATEST=TRUE`,
  rubygems-mirror fetches only the latest release of each gem

=== Apache configuration for hashdir

When rubygem-mirror is configured with hashdir: true, additional configuration
for your web server will be required. Below are the Apache2 RewriteRules you may
need:

    RewriteEngine On

    # Rubygem's URLs are:
    # /gem/gems/foobar-1.0.0.gem
    RewriteCond %{REQUEST_URI} ^/gem/gems/([^/])([^/])([^/]*)
    RewriteCond %{DOCUMENT_ROOT}/gem/gems/$1/$1$2/ -d
    RewriteRule ^/gem/gems/([^/])([^/])([^/]*)?$ /gem/gems/$1/$1$2/$1$2$3 [L]

    # Rubygem's URLs are:
    # /gem/quick/Marshal.4.8/foobar-1.0.0.gemspec.rz
    RewriteCond %{REQUEST_URI} ^/gem/quick/([^/]+)/([^/])([^/])([^/]*)
    RewriteCond %{DOCUMENT_ROOT}/gem/quick/$1/$2/$2$3/ -d
    RewriteRule ^/gem/quick/([^/]+)/([^/])([^/])([^/]*)?$ /gem/quick/$1/$2/$2$3/$2$3$4 [L]


== INSTALL:

* gem install rubygems-mirror

== RESOURCES

* {Website}[https://rubygems.org/]
* {Documentation}[https://github.com/rubygems/rubygems-mirror/blob/master/README.rdoc]
* {Wiki}[https://wiki.github.com/rubygems/rubygems-mirror/]
* {Source Code}[https://github.com/rubygems/rubygems-mirror/]
* {Issues}[https://github.com/rubygems/rubygems-mirror/issues]

== LICENSE:

(The MIT License)

Copyright (c) 2010 James Tucker, The RubyGems Team

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
