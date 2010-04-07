require 'rdf'
require 'enumerator'
require 'rest_client'
require 'addressable/uri'
require 'json'

module RDF::Talis
  class Repository < ::RDF::Repository

    def initialize(store, options = {})
      @store    = store
      @settings = options.dup
      @url      = Addressable::URI.parse("http://api.talis.com/stores/#{@store}/services/sparql").normalize.to_str
    end

    ##
    # Enumerates each RDF statement in this repository.
    #
    # @yield  [statement]
    # @yieldparam [RDF::Statement] statement
    # @return [Enumerator]
    # @see    http://www.openrdf.org/doc/sesame2/system/ch08.html#d0e304
    def each(&block)
      query = "CONSTRUCT { ?s ?p ?o } WHERE { ?s ?p ?o }"
      response = RestClient.post @url, {:query => query}, :accept => 'text/plain'
      puts response.inspect
      reader = RDF::NTriples::Reader.new(response.body)
      reader.each_statement(&block)
    end

    def has_subject?(subject)
      query = "ASK { #{RDF::NTriples.serialize(subject)} ?p ?o }"
      response = RestClient.post @url, {:query => query}, :accept => 'application/sparql-results+json'
      JSON.parse(response.body)["boolean"]
    end

    def each_subject
      return ::Enumerable::Enumerator.new(self,:each_subject) unless block_given?
      query = "SELECT DISTINCT ?s WHERE { ?s ?p ?o }"
      response = RestClient.post @url, {:query => query}, :accept => 'application/sparql-results+json'
      JSON.parse(response.body)["results"]["bindings"].map do |binding|
        result = case binding["s"]["type"]
          when "uri"
            RDF::URI(binding["s"]["value"])
        end 
        yield result
      end
    end


    # @see RDF::Mutable#insert_statement
    def insert_statement(statement)
      raise NotImplementedError
    end

    # @see RDF::Mutable#delete_statement
    def delete_statement(statement)
      raise NotImplementedError
    end

  end
end
