# frozen_string_literal: true

# Base models available for all installations
chat_models = [
  { provider: :openrouter, model: 'claude-haiku-4-5' },
  { provider: :bedrock, model: 'claude-3-5-haiku' },
  { provider: :deepseek, model: 'deepseek-chat' },
  { provider: :gemini, model: 'gemini-2.5-flash' },
  { provider: :gpustack, model: 'qwen3' },
  { provider: :mistral, model: 'mistral-small-latest' },
  { provider: :ollama, model: 'qwen3' },
  { provider: :openai, model: 'gpt-4.1-nano' },
  { provider: :openrouter, model: 'claude-haiku-4-5' },
  { provider: :perplexity, model: 'sonar' },
  { provider: :vertexai, model: 'gemini-2.5-flash' },
  { provider: :xai, model: 'grok-3-mini' }
]

# Only include Red Candle models if the gem is available
begin
  require 'candle'
  chat_models << { provider: :red_candle, model: 'TheBloke/Mistral-7B-Instruct-v0.2-GGUF' }
rescue LoadError
  # Red Candle not available - don't include its models
end

CHAT_MODELS = chat_models.freeze

PDF_MODELS = [
  { provider: :anthropic, model: 'claude-haiku-4-5' },
  { provider: :bedrock, model: 'claude-3-7-sonnet' },
  { provider: :gemini, model: 'gemini-2.5-flash' },
  { provider: :openai, model: 'gpt-4.1-nano' },
  { provider: :openrouter, model: 'gemini-2.5-flash' },
  { provider: :vertexai, model: 'gemini-2.5-flash' }
].freeze

VISION_MODELS = [
  { provider: :anthropic, model: 'claude-haiku-4-5' },
  { provider: :bedrock, model: 'claude-sonnet-4-5' },
  { provider: :gemini, model: 'gemini-2.5-flash' },
  { provider: :mistral, model: 'pixtral-12b-latest' },
  { provider: :ollama, model: 'granite3.2-vision' },
  { provider: :openai, model: 'gpt-4.1-nano' },
  { provider: :openrouter, model: 'claude-haiku-4-5' },
  { provider: :vertexai, model: 'gemini-2.5-flash' }
].freeze

VIDEO_MODELS = [
  { provider: :gemini, model: 'gemini-2.5-flash' },
  { provider: :vertexai, model: 'gemini-2.5-flash' }
].freeze

AUDIO_MODELS = [
  { provider: :openai, model: 'gpt-4o-mini-audio-preview' },
  { provider: :gemini, model: 'gemini-2.5-flash' }
].freeze

EMBEDDING_MODELS = [
  { provider: :gemini, model: 'text-embedding-004' },
  { provider: :openai, model: 'text-embedding-3-small' },
  { provider: :mistral, model: 'mistral-embed' },
  { provider: :vertexai, model: 'text-embedding-004' }
].freeze

IMAGE_CHAT_MODELS = [
  # TODO: Update image-to-image specs to work with gemini-2.5-flash-image
  #  { provider: :gemini, model: 'gemini-2.5-flash-image' },
  { provider: :openai, model: 'gpt-5' }
].freeze

CACHING_MODELS = [
  { provider: :anthropic, model: 'claude-3-5-haiku-20241022' },
  { provider: :bedrock, model: 'anthropic.claude-3-5-haiku-20241022-v1:0' }
].freeze

CACHED_MODELS = [
  { provider: :gemini, model: 'gemini-2.5-flash' },
  { provider: :openai, model: 'gpt-4.1-nano' }
].freeze

TRANSCRIPTION_MODELS = [
  { provider: :openai, model: 'whisper-1' },
  { provider: :openai, model: 'gpt-4o-transcribe-diarize' },
  { provider: :gemini, model: 'gemini-2.5-flash' },
  { provider: :vertexai, model: 'gemini-2.5-flash' }
].freeze
