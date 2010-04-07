# Talis Platform storage adapter for RDF.rb

This gem allows you to use the Talis platform as a backend for RDF.rb.

This is currently read-only.

Synopsis:

    require 'rdf/talis'

    repo = RDF::Talis::Repository.new('bhuga-dev1')
    repo.each_statement do | statement |
      puts statement.inspect
    end


## Installation

The recommended method of installation is via RubyGems

    $ sudo gem install rdf-talis

## Resources

 * <http://rdf.rubyforge.org> - RDF.rb's home page

### Support

Please post questions or feedback to the [W3C-ruby-rdf mailing list][].

### Author
 * Ben Lavender | <blavender@gmail.com> | <http://github.com/bhuga> | <http://bhuga.net> | <http://blog.datagraph.org>

### 'License'

This is free and unemcumbered software released into the public domain.  For
more information, see the accompanying UNLICENSE file.

If you're unfamiliar with public domain, that means it's perfectly fine to
start with this skeleton and code away, later relicensing as you see fit.


[W3C-ruby-rdf mailing list]:        http://lists.w3.org/Archives/Public/public-rdf-ruby/
