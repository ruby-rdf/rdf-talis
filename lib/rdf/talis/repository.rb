require 'rdf'
require 'sparql/repository'
require 'addressable/uri'

module RDF::Talis
  class Repository < ::SPARQL::Repository

    def initialize(store, options = {})
      @store    = store
      @settings = options.dup
      @url      = Addressable::URI.parse("http://api.talis.com/stores/#{@store}/services/sparql").to_str
      super(@url)
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
