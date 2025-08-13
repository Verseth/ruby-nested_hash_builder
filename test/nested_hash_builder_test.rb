# frozen_string_literal: true

require 'test_helper'

class NestedHashBuilderTest < Minitest::Test
  should 'have a version' do
    refute_nil ::NestedHashBuilder::VERSION
  end

  context 'build' do
    should 'build a hash with base values' do
      base_hash = {
        name:  'Ruby',
        price: :priceless,
      }

      hash = NestedHashBuilder.call(base: base_hash) do |h|
        h.description = "Programmer's best friend"
        h.key! :type, :dynamic
      end

      expected = {
        name:        'Ruby',
        price:       :priceless,
        description: "Programmer's best friend",
        type:        :dynamic,
      }
      assert_equal expected, hash
    end

    should 'build a simple hash' do
      hash = ::NestedHashBuilder.call do |h|
        h.name 'Ruby'
        h.price :priceless
        h.description = "Programmer's best friend"
        h.key! :type, :dynamic
      end

      expected = {
        name:        'Ruby',
        price:       :priceless,
        description: "Programmer's best friend",
        type:        :dynamic,
      }
      assert_equal expected, hash
    end

    should 'build a nested hash' do
      hash = ::NestedHashBuilder.call do |h|
        h.name 'Ruby'
        h.price :priceless
        h.description = "Programmer's best friend"
        h.features do
          h.typing = :dynamic
          h.metaprogramming true
          h.hash! :syntax do
            h.type :pythonic
          end
        end
      end

      expected = {
        name:        'Ruby',
        price:       :priceless,
        description: "Programmer's best friend",
        features:    {
          typing:          :dynamic,
          metaprogramming: true,
          syntax:          {
            type: :pythonic,
          },
        },
      }
      assert_equal expected, hash
    end

    should 'build a nested hash with symbolize false' do
      hash = ::NestedHashBuilder.call(symbolize: false) do |h|
        h.name 'Ruby'
        h.price :priceless
        h.description = "Programmer's best friend"
        h.features do
          h.typing = :dynamic
          h.metaprogramming true
          h.hash! 'syntax' do
            h.type :pythonic
          end
        end
      end

      expected = {
        'name'        => 'Ruby',
        'price'       => :priceless,
        'description' => "Programmer's best friend",
        'features'    => {
          'typing'          => :dynamic,
          'metaprogramming' => true,
          'syntax'          => {
            'type' => :pythonic,
          },
        },
      }
      assert_equal expected, hash
    end

    should 'build with a nested array' do
      hash = ::NestedHashBuilder.call do |h|
        h.name 'Ruby'
        h.price :priceless
        h.description = "Programmer's best friend"
        h.ary! :features do |a|
          a << h.entry! do |e|
            e.name :dynamic
          end
          a << h.entry! do |e|
            e.name :object_oriented
          end
        end
      end

      expected = {
        name:        'Ruby',
        price:       :priceless,
        description: "Programmer's best friend",
        features:    [
          { name: :dynamic },
          { name: :object_oriented },
        ],
      }
      assert_equal expected, hash
    end

    should 'build with local_dig!' do
      hash = ::NestedHashBuilder.call do |h|
        h.client do
          h.first_name 'Patrick'
          h.last_name 'Stewart'
          h.full_name "#{h.local_dig!(:first_name)} #{h.local_dig!(:last_name)}"
        end
      end

      expected = {
        client: {
          first_name: 'Patrick',
          last_name:  'Stewart',
          full_name:  'Patrick Stewart',
        },
      }
      assert_equal expected, hash
    end

    should 'build with dig!' do
      hash = ::NestedHashBuilder.call do |h|
        h.client do
          h.first_name 'Patrick'
          h.last_name 'Stewart'
          h.full_name "#{h.dig!(:client, :first_name)} #{h.dig!(:client, :last_name)}"
        end
      end

      expected = {
        client: {
          first_name: 'Patrick',
          last_name:  'Stewart',
          full_name:  'Patrick Stewart',
        },
      }
      assert_equal expected, hash
    end

    should 'build with key?' do
      hash = ::NestedHashBuilder.call do |h|
        h.client do
          h.first_name 'Patrick'
          h.last_name 'Stewart'
          h.actor = true
          h.famous = true
          h.celebrity = true if h.key?(:client, :actor) && h.key?(:client, :famous)
        end
      end

      expected = {
        client: {
          first_name: 'Patrick',
          last_name:  'Stewart',
          actor:      true,
          famous:     true,
          celebrity:  true,
        },
      }
      assert_equal expected, hash

      hash = ::NestedHashBuilder.call do |h|
        h.client do
          h.first_name 'Patrick'
          h.last_name 'Stewart'
          h.actor = true
          h.celebrity = true if h.key?(:client, :actor) && h.key?(:client, :famous)
        end
      end

      expected = {
        client: {
          first_name: 'Patrick',
          last_name:  'Stewart',
          actor:      true,
        },
      }
      assert_equal expected, hash
    end

    should 'build with local_key?' do
      hash = ::NestedHashBuilder.call do |h|
        h.client do
          h.first_name 'Patrick'
          h.last_name 'Stewart'
          h.actor = true
          h.famous = true
          h.celebrity = true if h.local_key?(:actor) && h.local_key?(:famous)
        end
      end

      expected = {
        client: {
          first_name: 'Patrick',
          last_name:  'Stewart',
          actor:      true,
          famous:     true,
          celebrity:  true,
        },
      }
      assert_equal expected, hash

      hash = ::NestedHashBuilder.call do |h|
        h.client do
          h.first_name 'Patrick'
          h.last_name 'Stewart'
          h.actor = true
          h.celebrity = true if h.local_key?(:actor) && h.local_key?(:famous)
        end
      end

      expected = {
        client: {
          first_name: 'Patrick',
          last_name:  'Stewart',
          actor:      true,
        },
      }
      assert_equal expected, hash
    end
  end
end
