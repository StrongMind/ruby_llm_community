# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubyLLM::Tool do
  describe RubyLLM::Parameter do
      describe '#initialize' do
        it 'accepts an items hash for array params' do
          param = described_class.new(:tags, type: 'array', items: { type: 'string' })

          expect(param.type).to eq('array')
          expect(param.items).to eq(type: 'string')
        end

        it 'accepts a properties hash for object params' do
          param = described_class.new(
            :contact,
            type: 'object',
            properties: {
              name: { type: 'string' },
              age: { type: 'integer' }
            }
          )

          expect(param.type).to eq('object')
          expect(param.properties).to eq(
            name: { type: 'string' },
            age: { type: 'integer' }
          )
        end

        it 'recursively normalizes nested arrays' do
          param = described_class.new(
            :matrix,
            type: 'array',
            items: { type: 'array', items: { type: 'integer' } }
          )

          expect(param.items).to eq(
            type: 'array',
            items: { type: 'integer' }
          )
        end

        it 'recognizes shorthand object definition inside items:' do
          param = described_class.new(
            :records,
            type: 'array',
            items: {
              id: { type: 'integer', desc: 'ID' },
              name: { type: 'string', desc: 'Name' }
            }
          )

          expect(param.items).to eq(
            type: 'object',
            properties: {
              id: { type: 'integer', description: 'ID' },
              name: { type: 'string', description: 'Name' }
            }
          )
        end

        it 'defaults items and properties to nil when not provided' do
          param = described_class.new(:name, type: 'string', desc: 'A name')

          expect(param.items).to be_nil
          expect(param.properties).to be_nil
        end

        it 'preserves existing Parameter behavior for scalar types' do
          param = described_class.new(:name, type: 'string', desc: 'A name', required: false)

          expect(param.name).to eq(:name)
          expect(param.type).to eq('string')
          expect(param.description).to eq('A name')
          expect(param.required).to be(false)
        end
      end

      describe '#to_schema' do
        it 'compacts nil values' do
          param = described_class.new(:tag, type: 'string')

          expect(param.to_schema).to eq(type: 'string')
        end

        it 'includes items when present' do
          param = described_class.new(:tags, type: 'array', items: { type: 'string' })

          expect(param.to_schema).to eq(
            type: 'array',
            items: { type: 'string' }
          )
        end

        it 'includes properties when present' do
          param = described_class.new(
            :contact,
            type: 'object',
            properties: { name: { type: 'string' } }
          )

          expect(param.to_schema).to eq(
            type: 'object',
            properties: { name: { type: 'string' } }
          )
        end
      end

      describe '.serialize_schema' do
        it 'returns a compacted hash for a scalar schema' do
          result = described_class.serialize_schema(type: 'string', description: 'A name')

          expect(result).to eq(type: 'string', description: 'A name')
        end

        it 'recursively serializes items' do
          result = described_class.serialize_schema(
            type: 'array',
            items: { type: 'integer' }
          )

          expect(result).to eq(
            type: 'array',
            items: { type: 'integer' }
          )
        end

        it 'recursively serializes properties' do
          result = described_class.serialize_schema(
            type: 'object',
            properties: {
              name: { type: 'string' },
              age: { type: 'integer' }
            }
          )

          expect(result).to eq(
            type: 'object',
            properties: {
              name: { type: 'string' },
              age: { type: 'integer' }
            }
          )
        end

        it 'applies a type mapper when provided' do
          result = described_class.serialize_schema(
            type: 'array',
            items: { type: 'integer' }
          ) { |type| type.to_s.upcase }

          expect(result).to eq(
            type: 'ARRAY',
            items: { type: 'INTEGER' }
          )
        end
      end
    end

    describe RubyLLM::Tool::SchemaDefinition, '.from_parameters' do
      it 'respects explicit array items on a param' do
        tool_class = Class.new(RubyLLM::Tool) do
          description 'Test tool'
          param :scores, type: 'array', items: { type: 'integer' }
        end

        schema = described_class.from_parameters(tool_class.parameters).json_schema

        expect(schema.dig('properties', 'scores', 'items')).to eq('type' => 'integer')
      end

      it 'respects nested array items (array-of-arrays)' do
        tool_class = Class.new(RubyLLM::Tool) do
          description 'Test tool'
          param :grid, type: 'array', items: { type: 'array', items: { type: 'integer' } }
        end

        schema = described_class.from_parameters(tool_class.parameters).json_schema

        expect(schema.dig('properties', 'grid', 'items')).to eq(
          'type' => 'array',
          'items' => { 'type' => 'integer' }
        )
      end

      it 'respects shorthand object items (array-of-objects)' do
        tool_class = Class.new(RubyLLM::Tool) do
          description 'Test tool'
          param :records, type: 'array', items: {
            id: { type: 'integer', desc: 'ID' },
            name: { type: 'string', desc: 'Name' }
          }
        end

        schema = described_class.from_parameters(tool_class.parameters).json_schema

        expect(schema.dig('properties', 'records', 'items')).to eq(
          'type' => 'object',
          'properties' => {
            'id' => { 'type' => 'integer', 'description' => 'ID' },
            'name' => { 'type' => 'string', 'description' => 'Name' }
          }
        )
      end

      it 'respects top-level object properties' do
        tool_class = Class.new(RubyLLM::Tool) do
          description 'Test tool'
          param :contact, type: 'object', properties: {
            name: { type: 'string', desc: 'Full name' },
            email: { type: 'string', desc: 'Email' }
          }
        end

        schema = described_class.from_parameters(tool_class.parameters).json_schema

        expect(schema.dig('properties', 'contact')).to include(
          'type' => 'object',
          'properties' => {
            'name' => { 'type' => 'string', 'description' => 'Full name' },
            'email' => { 'type' => 'string', 'description' => 'Email' }
          }
        )
      end

      it 'falls back to default string items when none specified for an array' do
        tool_class = Class.new(RubyLLM::Tool) do
          description 'Test tool'
          param :names, type: 'array'
        end

        schema = described_class.from_parameters(tool_class.parameters).json_schema

        expect(schema.dig('properties', 'names', 'items')).to eq('type' => 'string')
      end

      it 'emits strict-mode metadata for OpenAI compatibility' do
        tool_class = Class.new(RubyLLM::Tool) do
          description 'Test tool'
          param :name, type: 'string'
        end

        schema = described_class.from_parameters(tool_class.parameters).json_schema

        expect(schema).to include(
          'type' => 'object',
          'additionalProperties' => false,
          'strict' => true
        )
      end
    end

    describe 'end-to-end tool.params_schema output' do
      let(:tool_class) do
        Class.new(RubyLLM::Tool) do
          description 'Classification tool mirroring production shape'

          param :items,
                type: 'array',
                desc: 'Items to classify',
                items: { type: 'string' }

          param :column_values,
                type: 'array',
                desc: 'Array of arrays of indices',
                items: {
                  type: 'array',
                  items: { type: 'integer' }
                }
        end
      end

      it 'produces a valid JSON Schema with deeply nested arrays' do
        schema = tool_class.new.params_schema

        expect(schema.dig('properties', 'items')).to include(
          'type' => 'array',
          'items' => { 'type' => 'string' }
        )
        expect(schema.dig('properties', 'column_values')).to include(
          'type' => 'array',
          'items' => {
            'type' => 'array',
            'items' => { 'type' => 'integer' }
          }
        )
        expect(schema['required']).to match_array(%w[items column_values])
      end
  end
end
