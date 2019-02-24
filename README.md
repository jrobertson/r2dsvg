# Viewing coloured shapes using the experimental r2dsvg gem

## Installation

Follow the [instructions](http://www.jamesrobertson.eu/snippets/2019/feb/24/create-a-desktop-application-using-the-ruby2d-gem.html#installation) on how to install the ruby2d gem and then `gem install r2dsvg`.

## Example

    require 'r2dsvg'

    s=<<EOF
    <svg width="300" height="200">
      <rect width="50" height="50" style="z-index:6" />
      <rect width="80" height="70" style="fill:red;z-index:4 " />
    </svg>
    EOF

    R2dSvg.new s

The above example creates 2 rectangles which are overlapping each other. Here's a screenshot of the above example:

![Screenshot of the Ruby program r2dsvg](http://www.jamesrobertson.eu/r/images/2019/feb/24/r2dsvg.jpg)

Notes:

* This gem is experimental
* Only rectangles are rendered at the moment
* The z-index is a non-standard SVG attribute
* This gem relies upon the ruby2d libraries which are themself experiemental.

## Resources

* r2dsvg https://rubygems.org/gems/r2dsvg

gem r2dsvg svg program application ruby2d svgle gtk graphics
