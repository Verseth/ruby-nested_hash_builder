# typed: true
# frozen_string_literal: true

require 'sorbet-runtime'
require_relative 'nested_hash_builder/version'

# A module that provides a simple DSL
# for defining complex, nested Hashes.
#
#     hash = NestedHashBuilder.call do |h|
#       h.price 10
#       h.client do
#         h.first_name 'Patrick'
#         h.last_name = 'Stewart' # setter syntax is optional
#         h.full_name = "#{h.local_dig!(:first_name)} #{h.local_dig!(:last_name)}"
#       end
#       h.inexistent = :i_wont_be_there if h.dig!(:price) == 15
#     end
#
#     p hash
#     #=> {:price=>10, :client=>{:first_name=>"Patrick", :last_name=>"Stewart", :full_name=>"Patrick Stewart"}}
#
module NestedHashBuilder
  class << self
    #: (?base: Hash[untyped, untyped], ?symbolize: bool) { (Proxy) -> void } -> Hash[untyped, untyped]
    def call(base: {}, symbolize: true, &block)
      block.call(proxy = Proxy.new(base: base, symbolize: symbolize))
      proxy.to_h
    end

    alias build call
  end

  # Object that is the receiver of all
  # the building methods.
  class Proxy
    #: (?base: Hash[untyped, untyped], ?symbolize: bool) -> void
    def initialize(base: {}, symbolize: true)
      @hash = base.dup
      @symbolize = symbolize
      @current_parent = @hash
    end

    # Creates an array.
    #
    #: (Symbol | String) { (Array[untyped]) -> void } -> void
    def ary!(name, &block)
      array = []
      block.call(array)
      key! name, array
    end

    alias array! ary!

    # Add a key with the specified value to the hash.
    # Creates a nested hash if a block is passed.
    #
    #: (String | Symbol, ?top) ?{ -> void } -> void
    def key!(name, value = nil, &block)
      name = name.to_s.delete_suffix('=')
      name = name.to_sym if @symbolize

      return hash!(name, &block) if block

      @current_parent[name] = value
      @hash
    end

    #: { (Proxy) -> void } -> Hash[untyped, untyped]
    def entry!(&block)
      p = Proxy.new(symbolize: @symbolize)
      block.call(p)
      p.to_h
    end

    # Creates a nested hash.
    #
    #: (String | Symbol) -> void
    def hash!(name)
      previous_parent = @current_parent
      @current_parent = (@current_parent[name] ||= {})
      yield
      @current_parent = previous_parent
    end

    # Gets a value of a particular key.
    #
    #     HashBuilder.call do |h|
    #       h.price 10
    #       h.client do
    #         h.first_name 'Patrick'
    #         h.last_name 'Stewart'
    #         h.full_name "#{h.dig!(:client, :first_name)} #{h.dig!(:client, :last_name)}"
    #         h.card do
    #           h.number '4242424242424242'
    #           h.expiry_date = Time.now
    #         end
    #       end
    #       h.price_copy = h.dig!(:price) #=> 10
    #       h.card_copy = h.dig!(:client, :card, :number) #=> '4242424242424242'
    #     end
    #
    #: (*Symbol | String) -> untyped
    def dig!(*names)
      @hash.dig(*names)
    end

    # Checks if a given key is defined.
    #
    #     HashBuilder.call do |h|
    #       h.price 10
    #       h.client do
    #         h.name 'Patrick Stewart'
    #         h.card do
    #           h.number '4242424242424242'
    #           h.expiry_date = Time.now
    #         end
    #       end
    #       h.price_present = h.key?(:price) #=> true
    #       h.card_present = h.key?(:client, :card) #=> true
    #     end
    #
    # @param names [Array<Symbol>]
    #: (*Symbol | String) -> bool
    def key?(*names)
      !T.unsafe(self).dig!(*names).nil?
    end

    # Gets a value of a particular key in the current context.
    #
    #     HashBuilder.call do |h|
    #       h.price 10
    #       h.client do
    #         h.first_name 'Patrick'
    #         h.last_name 'Stewart'
    #         h.full_name "#{h.local_dig!(:first_name)} #{h.local_dig!(:last_name)}"
    #       end
    #     end
    #
    #: (*Symbol | String) -> untyped
    def local_dig!(*names)
      @current_parent.dig(*names)
    end

    # Checks if a given key is defined in the local context.
    #
    #     HashBuilder.call do |h|
    #       h.price 10
    #       h.client do
    #         h.name 'Patrick Stewart'
    #         h.surname 'Stewart' if h.local_key?(:name) # true
    #       end
    #     end
    #
    #: (*Symbol | String) -> bool
    def local_key?(*names)
      !T.unsafe(self).local_dig!(*names).nil?
    end

    #: -> Hash[Symbol | String, untyped]
    def to_h
      @hash
    end

    private

    def builder_method?(name)
      !name.end_with?('?') && !name.end_with?('!')
    end

    def method_missing(method_name, *args, &block)
      super unless builder_method?(method_name)

      key!(method_name, args.first, &block)
    end

    def respond_to_missing?(method_name, *_args)
      return false if builder_method?(method_name)

      true
    end
  end
end
