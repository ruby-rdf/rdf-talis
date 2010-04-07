require 'rdf'
require 'enumerator'
require 'rest_client'
require 'addressable/uri'
require 'json'

module RDF::SPARQL
  class Repository < ::RDF::Repository

    ##
    # Enumerates each RDF statement in this repository.
    #
    # @yield  [statement]
    # @yieldparam [RDF::Statement] statement
    # @return [Enumerator]
    # @see    http://www.openrdf.org/doc/sesame2/system/ch08.html#d0e304
    def each(&block)
      construct("CONSTRUCT { ?s ?p ?o } WHERE { ?s ?p ?o }", &block)
    end

    def has_subject?(subject)
      ask "ASK { #{RDF::NTriples.serialize(subject)} ?p ?o }"
    end

    def has_predicate?(predicate)
      ask "ASK { ?s #{RDF::NTriples.serialize(predicate)} ?o }"
    end

    def has_object?(object)
      ask "ASK { ?s ?p #{RDF::NTriples.serialize(object)}}"
    end

    def each_subject(&block)
      return ::Enumerable::Enumerator.new(self,:each_subject) unless block_given?
      select("SELECT DISTINCT ?s WHERE { ?s ?p ?o }", &block)
    end

    def each_predicate(&block)
      return ::Enumerable::Enumerator.new(self,:each_object) unless block_given?
      select("SELECT DISTINCT ?p WHERE { ?s ?p ?o }", &block)
    end

    def each_object(&block)
      return ::Enumerable::Enumerator.new(self,:each_object) unless block_given?
      select("SELECT DISTINCT ?o WHERE { ?s ?p ?o }", &block)
    end

    def has_triple?(array)
      subject   = RDF::NTriples.serialize(array[0])  
      predicate = RDF::NTriples.serialize(array[1])  
      object    = RDF::NTriples.serialize(array[2])
      ask "ASK { #{subject} #{predicate} #{object} }"
    end

    def has_statement?(statement)
      has_triple?(statement.to_triple)
    end

    def count
      select("SELECT COUNT(*) WHERE { ?s ?p ?o }").first.first.value.to_i
    end
    alias_method :size, :count
    alias_method :length, :count
    
    def empty?
      count == 0
    end

    def select
      raise NotImplementedError
    end

    def construct
      raise NotImplementedError
    end

    def ask
      raise NotImplementedError
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
