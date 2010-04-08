module RDF
  module Talis
    class Changeset < RDF::Vocabulary('http://purl.org/vocab/changeset/schema#')
      property :removal
      property :addition
      property :creatorName
      property :createdDate
      property :subjectOfChange
      property :changeReason
      property :ChangeSet
      property :precedingChangeSet
    end

    class Bigfoot < RDF::Vocabulary('http://schemas.talis.com/2006/bigfoot/configuration#')
      property :jobType
      property :ResetDataJob
      property :startTime
      property :JobRequest

    end
  end
end
