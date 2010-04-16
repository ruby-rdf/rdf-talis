# Talis Platform storage adapter for RDF.rb

This gem allows you to use a [Talis platform](http://www.talis.com/platform/)
meta store as a backend for RDF.rb.

RDF.rb is only concerned with RDF, and Talis stores provide a wide range of
functionality beyond its scope.  The [Pho library][] has programmatic access to a
wider range of features, which this library will not attempt to cover on its
own.

Synopsis:

    require 'rdf'
    require 'rdf/talis'

    repo = RDF::Talis::Repository.new('bhuga-dev1')
    puts RDF::Writer.for(:ntriples).dump repo


Or on your own repo (take care):

    repo = RDF::Talis::Repository.new('store-name', :user => user, :pass => pass)

    repo.load 'http://datagraph.org/jhacker/foaf.nt'
    repo.count
    # => 10
    # 12 triples in Talis, but we're ignoring the etags (see below)

    subject = repo.first.subject
    subject_statements = repo.query(:subject => subject)
    subject_statements.size
    # => 7

    repo.delete(*subject_statements)
    repo.count
    # => 3

## Talis-specific notes

This RDF::Talis::Repositories work pretty much as any RDF::Repository does, with some things to note:

 * `#clear` uses a reset job.  This will not just remove all RDF, but also all
    of the other goodies associated with your Talis repo.  Use with care!
 * `#load` does not support contexts, which are done with private graphs at 
   different URLs with Talis stores.  
 * Talis stores insert an etag statement for each inserted subject.  These etags are 
   ignored by `RDF::Talis::Repository`: you only get out what you put in.  This means
   that you might not get quite the same graph back as with other tools.

As an example:
    
    repo.load 'http://datagraph.org/jhacker/foaf.nt'
    subject = repo.first.subject
    subject_statements = repo.query(:subject => subject)
    repo.delete(*subject_statements)
    repo.has_subject?(subject)
    # => false

Note, however, that an etag with the subject still exists in the repository (shown here as an NTriple):

    <http://datagraph.org/jhacker/#self> <http://schemas.talis.com/2005/dir/schema#etag> "1c219cb8-bfd9-4cb8-b717-3f9deb03b32a" .


## Installation

The recommended method of installation is via RubyGems.

    $ sudo gem install rdf-talis

## Resources

 * {RDF::Talis::Repository}
 * <http://rdf.rubyforge.org> - RDF.rb's home page
 * <http://rdf.rubyforge.org/RDF/Repository.html>
 * <http://rubyforge.org/projects/pho/>
 * <http://n2.talis.com/wiki/Main_Page>

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
[Pho library]:                      http://rubyforge.org/projects/pho/
