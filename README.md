# Talis Platform storage adapter for RDF.rb

This gem allows you to use the Talis platform as a backend for RDF.rb.

This currently works read-write, but is awaiting some features in other modules
before gem install works.  Ping me if you want it NOW.

Synopsis:

    require 'rdf/talis'

    repo = RDF::Talis::Repository.new('bhuga-dev1')
    puts RDF::Writer.for(:ntriples).dump repo


Or on your own repo (take care):

    repo = RDF::Talis::Repository.new('store-name', :user => user, :pass => pass)
    repo.clear

    # Talis stores only have a scheduled job to clear them, not a command, so wait until it finishes
    while repo.count > 0 do sleep 10 end

    repo.load 'http://datagraph.org/jhacker/foaf.nt'
    repo.count
    #=> 12
    # 10 triples, 2 Talis etags

## Installation

The recommended method of installation is via RubyGems.

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
