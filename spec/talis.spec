$:.unshift File.dirname(__FILE__) + "/../lib/"
$:.unshift File.dirname(__FILE__) + "/../../rdf-spec/lib/"

require 'rdf'
require 'rdf/spec/enumerable'
require 'rdf/spec/repository'
require 'rdf/talis'
require 'rdf/ntriples'

describe RDF::Talis::Repository do
  context "A Talis RDF Repository" do
  
    before :all do
    end

    before :each do
      @url  = ENV['talisstore'] || 'bhuga-dev1'
      @user = ENV['talisuser'] || 'bhuga'
      @pass = ENV['talispass']
      @repository = RDF::Talis::Repository.new(@url, :user => @user, :pass => @pass)
      @enumerable = @repository
    end
   
    after :each do
      #TODO: Anything you need to clean up a test goes here.
      @repository.delete_statements(@statements) unless @repository.empty?
    end

    # @see lib/rdf/spec/repository.rb in RDF-spec
    it_should_behave_like RDF_Repository
  end

end

