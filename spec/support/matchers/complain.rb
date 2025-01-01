# frozen_string_literal: true

require 'stringio'

module BuildYourOwn
  module RubyCoreLibrary
    module RSpec
      module Matchers
        # Provides the implementation for `complain`.
        class Complain
          def initialize(expected_message, **options)
            @expected_message = expected_message
            @options = options
            @actual_message = nil
          end

          def matches?(given_proc, negative_expectation=false)
            @given_proc = given_proc
            return false unless Proc === given_proc

            saved_err = $stderr
            verbose = $VERBOSE
            stderr = StringIO.new

            $stderr = stderr
            $VERBOSE = @options.key?(:verbose) ? @options[:verbose] : false

            begin
              given_proc.call
            ensure
              $VERBOSE = verbose
              $stderr = saved_err
            end

            @actual_message = stderr.string

            values_match?(@expected_message, @actual_message)
          end

          def does_not_match?(given_proc)
            !matches?(given_proc, :negative_expectation) && Proc === given_proc
          end

          def supports_block_expectations?
            true
          end

          def supports_value_expectations?
            false
          end

          def expects_call_stack_jump?
            true
          end

          # @return [String]
          def failure_message
            if @expected_message.nil?
              ["Expected a warning", "but received none"]
            elsif @expected_message.kind_of? Regexp
              ["Expected warning to match: #{@expected_message.inspect}", "but got: #{@actual_message.chomp.inspect}"]
            else
              ["Expected warning: #{@expected_message.inspect}", "but got: #{@actual_message.chomp.inspect}"]
            end
          end

          # @return [String]
          def failure_message_when_negated
            if @expected_message.nil?
              ["Unexpected warning: ", @actual_message.chomp.inspect]
            elsif @expected_message.kind_of? Regexp
              ["Expected warning not to match: #{@expected_message.inspect}", "but got: #{@actual_message.chomp.inspect}"]
            else
              ["Expected warning: #{@expected_message.inspect}", "but got: #{@actual_message.chomp.inspect}"]
            end
          end

          # @return [String]
          def description
            "emit warning #{@expected_message.inspect}"
          end

          private

          def values_match?(expected_message, actual_message)
            unless expected_message.nil?
              case expected_message
              when Regexp
                return false unless actual_message =~ expected_message
              else
                return false unless actual_message == expected_message
              end
            end

            !actual_message.empty?
          end
        end
      end
    end
  end
end

module RSpec
  module Matchers
    def complain(message=nil, **options)
      BuildYourOwn::RubyCoreLibrary::RSpec::Matchers::Complain.new(message, **options)
    end
  end
end
