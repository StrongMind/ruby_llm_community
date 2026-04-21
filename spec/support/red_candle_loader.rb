# frozen_string_literal: true

# Handle Red Candle provider based on availability and environment
begin
  require 'candle'

  # Red Candle gem is installed
  unless ENV['RED_CANDLE_REAL_INFERENCE'] == 'true'
    # Use stubs (default when gem is installed); real inference runs unconfigured.
    require_relative 'red_candle_test_helper'
  end
rescue LoadError
  # Red Candle gem not installed - skip tests
  RSpec.configure do |config|
    config.before do |example|
      # Skip Red Candle provider tests when gem not installed
      test_description = example.full_description.to_s
      if example.metadata[:file_path]&.include?('providers/red_candle') ||
         example.metadata[:described_class]&.to_s&.include?('RedCandle') ||
         test_description.include?('red_candle/')
        skip 'Red Candle not installed (run: bundle config set --local with red_candle && bundle install)'
      end
    end
  end
end
