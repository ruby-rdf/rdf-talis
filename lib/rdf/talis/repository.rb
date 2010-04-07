require 'rdf'
require 'rdf/sparql'
require 'enumerator'
require 'rest_client'
require 'addressable/uri'
require 'json'

module RDF::Talis
  class Repository < ::RDF::SPARQL::Repository

    def initialize(store, options = {})
      @store    = store
      @settings = options.dup
      @url      = Addressable::URI.parse("http://api.talis.com/stores/#{@store}/services/sparql").normalize.to_str
    end

    def ask(query)
      response = RestClient.post @url, {:query => query}, :accept => 'application/sparql-results+json'
      JSON.parse(response.body)["boolean"]
    end

    def construct(query, &block)
      response = RestClient.post @url, {:query => query}, :accept => 'text/plain'
      reader = RDF::NTriples::Reader.new(response.body)
      reader.each_statement(&block)
    end

    def select(query, &block)
      response = RestClient.post @url, {:query => query}, :accept => 'application/sparql-results+json'
      results = []
      JSON.parse(response.body)["results"]["bindings"].each do |binding|
        #puts binding.inspect
        bindings = []
        binding.each do | name, value |
          result = case value["type"]
            when "uri"
              RDF::URI(value["value"])
            when "literal"
              RDF::Literal(value["value"])
            when "typed-literal"
              RDF::Literal(value["value"])
          end 
          bindings << result
        end
        results << bindings
      end
      case block_given?
        when true
          results.each do |result| yield *result end
        when false
          return results
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
