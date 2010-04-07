$:.unshift File.dirname(__FILE__) + "/../lib/"
$:.unshift File.dirname(__FILE__) + "/../../rdf-spec/lib/"

require 'rdf'
require 'rdf/spec/enumerable'
require 'rdf/talis'
require 'rdf/ntriples'

describe RDF::Talis::Repository do
  context "A Talis RDF Repository" do
  
    before :all do
      @statements = RDF::Repository.load('http://datagraph.org/jhacker/foaf.nt')
    end

    before :each do
      @url  = ENV['talis-store'] || 'bhuga-dev1'
      @user = ENV['talis-user'] || 'bhuga'
      @pass = ENV['talis-pass']
      @repository = RDF::Talis::Repository.new(@url)
      @enumerable = RDF::Talis::Repository.new(@url)
      puts @repository.inspect
    end
   
    after :each do
      #TODO: Anything you need to clean up a test goes here.
      #@repository.clear
    end

    # @see lib/rdf/spec/repository.rb in RDF-spec
    it_should_behave_like RDF_Enumerable
  end

end

