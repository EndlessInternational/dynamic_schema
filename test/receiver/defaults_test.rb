require_relative '../test_helper'

module Receiver
  module Defaults

    class ObjectDefaultTest < Minitest::Test
      include TestHelper

      def test_assigns_object_default_when_set
        schema = {
          message: {
            type: Object,
            default: { role: :default },
            schema: {
              role: { type: Symbol },
              text: { type: String }
            }
          }
        }

        receiver = build_receiver( schema: schema )
        receiver.message { text 'text' }

        result = receiver.to_h
        assert_equal :default, result[ :message ][ :role ]
        assert_equal 'text', result[ :message ][ :text ]
      end

      def test_attributes_override_object_default
        schema = {
          message: {
            type: Object,
            default: { role: :default },
            schema: {
              role: { type: Symbol },
              text: { type: String }
            }
          }
        }

        receiver = build_receiver( schema: schema )
        receiver.message( { role: :system, text: 'text' } )

        result = receiver.to_h
        assert_equal :system, result[ :message ][ :role ]
        assert_equal 'text', result[ :message ][ :text ]
      end

      def test_block_overrides_object_default
        schema = {
          message: {
            type: Object,
            default: { role: :default },
            schema: {
              role: { type: Symbol },
              text: { type: String }
            }
          }
        }

        receiver = build_receiver( schema: schema )
        receiver.message do
          role :system
          text 'text'
        end

        result = receiver.to_h
        assert_equal :system, result[ :message ][ :role ]
        assert_equal 'text', result[ :message ][ :text ]
      end

      def test_explicit_set_replaces_default
        schema = {
          message: {
            type: Object,
            default: { role: :default },
            schema: {
              role: { type: Symbol },
              text: { type: String }
            }
          }
        }

        receiver = build_receiver( schema: schema )
        receiver.message { role :user }
        receiver.message { text 'text' }

        result = receiver.to_h
        assert_equal :user, result[ :message ][ :role ]
        assert_equal 'text', result[ :message ][ :text ]
      end

      def test_defaults_disabled_does_not_assign
        schema = {
          message: {
            type: Object,
            default: { role: :default },
            schema: {
              role: { type: Symbol },
              text: { type: String }
            }
          }
        }

        receiver = build_receiver( schema: schema, defaults: false )
        receiver.message { text 'text' }

        result = receiver.to_h
        assert_nil result[ :message ][ :role ]
        assert_equal 'text', result[ :message ][ :text ]
      end
    end

    class MemberDefaultTest < Minitest::Test
      include TestHelper

      def test_member_default_not_assigned_without_parent_reference
        schema = {
          message: {
            type: Object,
            schema: {
              role: { type: Symbol, default: :system },
              text: { type: String }
            }
          }
        }

        receiver = build_receiver( schema: schema )
        result = receiver.to_h

        assert_nil result[ :message ]
      end

      def test_member_default_assigned_when_parent_referenced
        schema = {
          message: {
            type: Object,
            schema: {
              role: { type: Symbol, default: :system },
              text: { type: String }
            }
          }
        }

        receiver = build_receiver( schema: schema )
        receiver.message { text 'text' }

        result = receiver.to_h
        assert_equal :system, result[ :message ][ :role ]
        assert_equal 'text', result[ :message ][ :text ]
      end

      def test_member_default_disabled
        schema = {
          message: {
            type: Object,
            schema: {
              role: { type: Symbol, default: :system },
              text: { type: String }
            }
          }
        }

        receiver = build_receiver( schema: schema, defaults: false )
        receiver.message { text 'text' }

        result = receiver.to_h
        assert_nil result[ :message ][ :role ]
        assert_equal 'text', result[ :message ][ :text ]
      end
    end

    class EmptyObjectDefaultTest < Minitest::Test
      include TestHelper

      def test_empty_default_triggers_member_defaults
        schema = {
          message: {
            type: Object,
            default: {},
            schema: {
              role: { type: Symbol, default: :system },
              text: { type: String }
            }
          }
        }

        receiver = build_receiver( schema: schema )
        result = receiver.to_h

        refute_nil result[ :message ]
        assert_equal :system, result[ :message ][ :role ]
      end

      def test_empty_default_member_set_in_block
        schema = {
          message: {
            type: Object,
            default: {},
            schema: {
              role: { type: Symbol, default: :system },
              text: { type: String }
            }
          }
        }

        receiver = build_receiver( schema: schema )
        receiver.message { text 'text' }

        result = receiver.to_h
        assert_equal :system, result[ :message ][ :role ]
        assert_equal 'text', result[ :message ][ :text ]
      end

      def test_empty_default_disabled
        schema = {
          message: {
            type: Object,
            default: {},
            schema: {
              role: { type: Symbol, default: :system },
              text: { type: String }
            }
          }
        }

        receiver = build_receiver( schema: schema, defaults: false )
        result = receiver.to_h

        assert_nil result[ :message ]
      end
    end

    class ValueDefaultTest < Minitest::Test
      include TestHelper

      def test_value_default_assigned
        schema = {
          version: { type: String, default: '1.0' }
        }

        receiver = build_receiver( schema: schema )
        result = receiver.to_h

        assert_equal '1.0', result[ :version ]
      end

      def test_value_default_overridden
        schema = {
          version: { type: String, default: '1.0' }
        }

        receiver = build_receiver( schema: schema )
        receiver.version '2.0'
        result = receiver.to_h

        assert_equal '2.0', result[ :version ]
      end

      def test_value_default_disabled
        schema = {
          version: { type: String, default: '1.0' }
        }

        receiver = build_receiver( schema: schema, defaults: false )
        result = receiver.to_h

        assert_nil result[ :version ]
      end
    end

  end

end
