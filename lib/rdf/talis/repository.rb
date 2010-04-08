require 'rdf'
require 'rdf/talis/changeset'
require 'sparql/client/repository'
require 'addressable/uri'
require 'httpclient'
require 'rdf/raptor'
require 'curb'

module RDF::Talis
  class Repository < ::SPARQL::Client::Repository

    def initialize(store, options = {})
      @store    = store
      @settings = options.dup
      @url      = Addressable::URI.parse("http://api.talis.com/stores/#{@store}/services/sparql").to_str
      super(@url)
    end

    # @see RDF::Mutable#insert_statement
    def insert_statement(statement)
      changeset = RDF::Repository.new
      change = RDF::Node.new
      puts RDF::Statement.new(change, RDF.type, Changeset.ChangeSet)
      changeset.insert(RDF::Statement.new(change, RDF.type, Changeset.ChangeSet))
      changeset.insert(RDF::Statement.new(change, Changeset.changeReason, "Generated in rdf/talis/repository"))
      changeset.insert(RDF::Statement.new(change, Changeset.createdDate, Time.now))
      new_node = RDF::Node.new
      changeset.insert(RDF::Statement.new(change, Changeset.addition, new_node))
      changeset.insert(RDF::Statement.new(change, Changeset.subjectOfChange, statement.subject))
      changeset.insert(*reify(statement, new_node))

      update = RDF::Writer.for(:rdfxml).dump(changeset)

      puts update
      url = "http://api.talis.com/stores/#{@store}/meta"
      client = HTTPClient.new
      client.set_auth(url, @settings[:user], @settings[:pass]) if @settings[:user]
      client.post(url, update, 'Content-Type' => 'application/vnd.talis.changeset+xml')
    end

    # @see RDF::Mutable#delete_statement
    def delete_statement(statement)
      changeset = RDF::Repository.new
      change = RDF::Node.new
      puts RDF::Statement.new(change, RDF.type, Changeset.ChangeSet)
      changeset.insert(RDF::Statement.new(change, RDF.type, Changeset.ChangeSet))
      changeset.insert(RDF::Statement.new(change, Changeset.changeReason, "Generated in rdf/talis/repository"))
      changeset.insert(RDF::Statement.new(change, Changeset.createdDate, Time.now))
      new_node = RDF::Node.new
      changeset.insert(RDF::Statement.new(change, Changeset.removal, new_node))
      changeset.insert(RDF::Statement.new(change, Changeset.subjectOfChange, statement.subject))
      changeset.insert(*reify(statement, new_node))

      update = RDF::Writer.for(:rdfxml).dump(changeset)

      puts update
      url = "http://api.talis.com/stores/#{@store}/meta"
      client = HTTPClient.new
      client.set_auth(url, @settings[:user], @settings[:pass]) if @settings[:user]
      client.post(url, update, 'Content-Type' => 'application/vnd.talis.changeset+xml')
    end

    def clear
      job = RDF::Node.new
      request = RDF::Repository.new
      request << RDF::Statement.new(job, Bigfoot.jobType,   Bigfoot.ResetDataJob)
      request << RDF::Statement.new(job, Bigfoot.startTime, (Time.new + 60).utc.xmlschema)
      request << RDF::Statement.new(job, RDF::RDFS.label,   'Cleared from rdf/talis/repository')
      request << RDF::Statement.new(job, RDF.type,          Bigfoot.JobRequest)

      update = RDF::Writer.for(:rdfxml).dump(request)

      client = HTTPClient.new
      url = "http://api.talis.com/stores/#{@store}/jobs"
      client.set_auth(url, @settings[:user], @settings[:pass]) if @settings[:user]
      client.post(url, update, 'Content-Type' => 'application/rdf+xml')

    end

    def reify(statement,node)
      statements = []
      statements << RDF::Statement.new(node, RDF.type, RDF[:Statement])
      statements << RDF::Statement.new(node, RDF.subject, statement.subject)
      statements << RDF::Statement.new(node, RDF.predicate, statement.predicate)
      statements << RDF::Statement.new(node, RDF.object, statement.object)
      statements
    end

  end
end
