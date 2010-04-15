require 'rdf'
require 'rdf/talis/changeset'
require 'sparql/client'
require 'addressable/uri'
require 'httpclient'
require 'rdf/raptor'
require 'enumerator'

module RDF::Talis
  class Repository < ::SPARQL::Client::Repository

    def initialize(store, options = {})
      @store    = store
      @settings = options.dup
      @url      = Addressable::URI.parse("http://api.talis.com/stores/#{@store}/services/sparql").to_str
      super(@url)
    end

    def writable?
      true
    end

    def each(&block)
      return ::Enumerable::Enumerator.new(self,:each) unless block_given?
      client.construct([:s, :p, :o]).
             where([:s, :p, :o]).
             filter("?p != <http://schemas.talis.com/2005/dir/schema#etag>").
             each_statement(&block)
    end

    def each_subject(&block)
      return ::Enumerable::Enumerator.new(self,:each_subject) unless block_given?
      client.select(:s, :distinct => true).
             where([:s, :p, :o]).
             filter("?p != <http://schemas.talis.com/2005/dir/schema#etag>").
             each { |solution| block.call(solution[:s]) }
    end

    def each_predicate(&block)
      return ::Enumerable::Enumerator.new(self,:each_predicate) unless block_given?
      client.select(:p, :distinct => true).
             where([:s, :p, :o]).
             filter("?p != <http://schemas.talis.com/2005/dir/schema#etag>").
             each { |solution| block.call(solution[:p]) }
    end

    def each_object(&block)
      return ::Enumerable::Enumerator.new(self,:each_object) unless block_given?
      client.select(:o, :distinct => true).
             where([:s, :p, :o]).
             filter("?p != <http://schemas.talis.com/2005/dir/schema#etag>").
             each { |solution| block.call(solution[:o]) }
    end

    def has_subject?(subject)
      client.ask.
             whether([subject, :p, :o]).
             filter("?p != <http://schemas.talis.com/2005/dir/schema#etag>").
             true?
    end

    def has_object?(object)
      client.ask.
             whether([:s, :p, object]).
             filter("?p != <http://schemas.talis.com/2005/dir/schema#etag>").
             true?
    end

    def count
      binding = client.query("SELECT COUNT(*) WHERE { ?s ?p ?o .
                              FILTER ( ?p != <http://schemas.talis.com/2005/dir/schema#etag>)
                              }").first.to_hash
      binding[binding.keys.first].value.to_i
    end
    alias_method :size, :count
    alias_method :length, :count

    def empty?
      client.ask.
             whether([:s, :p, :o]).
             filter("?p != <http://schemas.talis.com/2005/dir/schema#etag>").
             false?
    end

    def new_changeset(change)
      [RDF::Statement.new(change, RDF.type, Changeset.ChangeSet),
       RDF::Statement.new(change, Changeset.changeReason, "Generated in rdf/talis/repository"),
       RDF::Statement.new(change, Changeset.createdDate, Time.now)]
    end

    def changeset_statement(change, statement, operation)
      node = RDF::Node.new
      [RDF::Statement.new(change, operation, node),
       RDF::Statement.new(change, Changeset.subjectOfChange, statement.subject)] +
       statement.reified(:subject => node).to_a
    end

    # @see RDF::Mutable#insert_statement
    def insert_statement(statement)
      changeset = RDF::Repository.new
      change = RDF::Node.new
      changeset.insert(*new_changeset(change))
      changeset.insert(*changeset_statement(change, statement, Changeset.addition))

      update = RDF::Writer.for(:rdfxml).dump(changeset)

      post(:content => update) == 201
    end

    # @see RDF::Mutable#delete_statement
    def delete_statement(statement)
      changeset = RDF::Repository.new
      change = RDF::Node.new
      changeset.insert(*new_changeset(change))
      changeset.insert(*changeset_statement(change, statement, Changeset.removal))

      update = RDF::Writer.for(:rdfxml).dump(changeset)

      post(:content => update) == 201
    end

    def clear_statements
      job = RDF::Node.new
      request = RDF::Repository.new
      request << RDF::Statement.new(job, Bigfoot.jobType,   Bigfoot.ResetDataJob)
      request << RDF::Statement.new(job, Bigfoot.startTime, (Time.new + 60).utc.xmlschema)
      request << RDF::Statement.new(job, RDF::RDFS.label,   'Cleared from rdf/talis/repository')
      request << RDF::Statement.new(job, RDF.type,          Bigfoot.JobRequest)

      update = RDF::Writer.for(:rdfxml).dump(request)

      post(:path => 'jobs', :type => 'application/rdf+xml', :content => update) == 201
    end

    def post(opts)
      client = HTTPClient.new
      path = opts[:path] || "meta"
      type = opts[:type] || "application/vnd.talis.changeset+xml"

      client = HTTPClient.new
      url = "http://api.talis.com/stores/#{@store}/#{@path}"
      client.set_auth(url, @settings[:user], @settings[:pass]) if @settings[:user]
      client.post(url, opts[:update], 'Content-Type' => type).status
    end

  end
end
