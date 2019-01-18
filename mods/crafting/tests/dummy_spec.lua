package.path = '../../?.lua;' .. -- tests root
			   '../?.lua;' .. -- mod root
			   package.path

require("crafting/tests/dummy")

describe("ItemStack", function()
	it("parses simple", function()
		local stack = ItemStack("default:stone")
		assert.equals("default:stone", stack:get_name())
		assert.equals(1,               stack:get_count())
	end)

	it("parses dual string", function()
		local stack = ItemStack("default:stone 11")
		assert.equals("default:stone", stack:get_name())
		assert.equals(11,              stack:get_count())
	end)

	it("copies", function()
		local stack1 = ItemStack("default:stone 11")
		local stack2 = ItemStack(stack1)

		assert.not_equals(stack1, stack2)
		assert.is_true(stack1:get_name() == stack2:get_name())
		assert.is_true(stack1:get_count() == stack2:get_count())

		stack2:set_count(3)

		assert.equals(11, stack1:get_count())
		assert.equals(3,  stack2:get_count())
		assert.is_true(stack1:get_count() ~= stack2:get_count())
	end)
end)
