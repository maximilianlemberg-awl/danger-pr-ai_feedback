# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)
require "json"

module Danger
  describe Danger::DangerAiFeedback do
    describe "with Dangerfile" do
      before do
        @dangerfile = testing_dangerfile
        @ai_feedback = @dangerfile.ai_feedback
      end

      it "should be a Danger plugin" do
        expect(@ai_feedback).to be_a Danger::Plugin
      end

      context "when required environment variables are missing" do
        it "fails when any required environment variable is missing" do
          allow(ENV).to receive(:[]).and_return(nil) # Simulate missing variables
          
          expect { @ai_feedback.analyze_pipeline }.to raise_error(RuntimeError, /Missing environment variables/)
        end
      end

      context "when no failed jobs exist" do
        before do
          allow(@ai_feedback).to receive(:api_get).and_return({ "id" => 123 }.to_json)
          allow(@ai_feedback).to receive(:api_get).and_return([].to_json) # No failed jobs
        end

        it "outputs a success message when no jobs failed" do
          expect(@ai_feedback).to receive(:message).with("✅ No failed jobs found!")
          @ai_feedback.analyze_pipeline
        end
      end

      context "when failed jobs exist" do
        let(:failed_jobs) do
          [
            { "id" => 1, "name" => "test-job", "status" => "failed" }
          ]
        end

        before do
          allow(@ai_feedback).to receive(:api_get).and_return({ "id" => 123 }.to_json)
          allow(@ai_feedback).to receive(:api_get).and_return(failed_jobs.to_json)
          allow(@ai_feedback).to receive(:api_get).and_return("Fake log line\nAnother log line")
          allow(@ai_feedback).to receive(:post_request).and_return({ "choices" => [{ "message" => { "content" => "Suggested Fix: Do X" } }] }.to_json)
        end

        it "fetches logs and sends them to OpenAI" do
          expect(@ai_feedback).to receive(:api_get).at_least(:once)
          expect(@ai_feedback).to receive(:post_request).at_least(:once)
          @ai_feedback.analyze_pipeline
        end

        it "fails with a message when failed jobs are found" do
          expect(@ai_feedback).to receive(:fail).with(/🚨 Failing Pipeline detected/)
          @ai_feedback.analyze_pipeline
        end
      end

      context "when OpenAI response is empty" do
        before do
          allow(@ai_feedback).to receive(:api_get).and_return({ "id" => 123 }.to_json)
          allow(@ai_feedback).to receive(:api_get).and_return([{ "id" => 1, "name" => "test-job", "status" => "failed" }].to_json)
          allow(@ai_feedback).to receive(:api_get).and_return("Fake log line")
          allow(@ai_feedback).to receive(:post_request).and_return("")
        end

        it "fails gracefully when OpenAI does not return a response" do
          expect(@ai_feedback).to receive(:fail).with(/No response from ChatGPT/)
          @ai_feedback.analyze_pipeline
        end
      end
    end
  end
end