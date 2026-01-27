require_relative '../../test_helper'

module Builder
  module Options

    class InArrayTest < Minitest::Test
      include TestHelper

      def test_accepts_value_in_array
        builder = build_schema do
          status String, in: [ 'pending', 'active', 'completed' ]
        end

        result = builder.build { status 'active' }
        assert_equal 'active', result[ :status ]
      end

      def test_raises_for_value_not_in_array
        builder = build_schema do
          status String, in: [ 'pending', 'active', 'completed' ]
        end

        assert_raises DynamicSchema::InOptionError do
          builder.build! { status 'invalid' }
        end
      end

      def test_symbol_in_array
        builder = build_schema do
          role Symbol, in: [ :admin, :user, :guest ]
        end

        result = builder.build { role :admin }
        assert_equal :admin, result[ :role ]
      end

      def test_coerces_string_to_symbol_and_validates
        builder = build_schema do
          role Symbol, in: [ :admin, :user, :guest ]
        end

        result = builder.build { role 'user' }
        assert_equal :user, result[ :role ]
      end
    end

    class InRangeTest < Minitest::Test
      include TestHelper

      def test_accepts_value_in_range
        builder = build_schema do
          temperature Float, in: 0..1
        end

        result = builder.build { temperature 0.5 }
        assert_equal 0.5, result[ :temperature ]
      end

      def test_accepts_boundary_values
        builder = build_schema do
          temperature Float, in: 0..1
        end

        result = builder.build { temperature 0 }
        assert_equal 0, result[ :temperature ]

        result = builder.build { temperature 1 }
        assert_equal 1, result[ :temperature ]
      end

      def test_raises_for_value_outside_range
        builder = build_schema do
          temperature Float, in: 0..1
        end

        assert_raises DynamicSchema::InOptionError do
          builder.build! { temperature 1.5 }
        end
      end

      def test_integer_range
        builder = build_schema do
          count Integer, in: 1..10
        end

        result = builder.build { count 5 }
        assert_equal 5, result[ :count ]

        assert_raises DynamicSchema::InOptionError do
          builder.build! { count 0 }
        end
      end
    end

    class InWithArrayTest < Minitest::Test
      include TestHelper

      def test_validates_each_array_element
        builder = build_schema do
          values Integer, array: true, in: 1..10
        end

        result = builder.build { values [ 1, 5, 10 ] }
        assert_equal [ 1, 5, 10 ], result[ :values ]
      end

      def test_raises_for_invalid_array_element
        builder = build_schema do
          values Integer, array: true, in: 1..10
        end

        assert_raises DynamicSchema::InOptionError do
          builder.build! { values [ 1, 11, 5 ] }
        end
      end

      def test_symbol_array_with_in
        builder = build_schema do
          roles Symbol, array: true, in: [ :admin, :user, :guest ]
        end

        result = builder.build { roles [ :admin, :user ] }
        assert_equal [ :admin, :user ], result[ :roles ]
      end
    end

  end
end
