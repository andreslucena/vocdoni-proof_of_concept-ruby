
require_relative "vendor/dvote-protobuf/metadata/process_pb.rb"

require "base64"
require "debug"
require "faraday"
require "json"

module Vocdoni
  class Account 
    attr_reader :data
  
    def initialize(data)
      @data = data
    end
  
    def register!
      request = post!
      if request.status == 200
        puts request.response_body
      else
        debugger
      end
    end
  
    private
  
    def post!
      Faraday.post(uri, payload, headers)
    end
  
    def uri
      "https://api-dev.vocdoni.net/v2/accounts"
    end
  
    def payload
      {
        txPayload: Base64.encode64(Dvote::Types::V1::ProcessMetadata.encode(data)),
        metadata: Base64.encode64(data.to_json) 
      }.to_json
    end
  
    def headers
      { "Content-Type" => "application/json", "Accept" => "application/json" }
    end
  end
end

option1 = Dvote::Types::V1::ProcessMetadata::Question::VoteOption.new(
  title: {default: "Yes"}
)
option2 = Dvote::Types::V1::ProcessMetadata::Question::VoteOption.new(
  title: {default: "No"}
)
question1 = Dvote::Types::V1::ProcessMetadata::Question.new(
  title: { default: "Do you like binary questions?" },
  choices: [ option1, option2 ]
) 
process = Dvote::Types::V1::ProcessMetadata.new(
  title: { default: "Proof of concept from Ruby" },
  description: {default: "Just testing :D"},
  media: { header: "https://placekitten.com/800/600"},
  questions: [question1]
)

Vocdoni::Account.new(process).register!

