require 'telescope'

local mlib = require 'mlib'
local turbo = require 'mlib_turbo'

-- {{{ Helpers
local function fuzzyEqual( x, y, delta )
	return math.abs( x - y ) <= ( delta or .00001 )
end
make_assertion( 'fuzzyEqual', 'values are approximately equal', fuzzyEqual )
make_assertion( 'multipleFuzzyEqual', 'multiple values are approximately equal', function( t1, t2 )
	for i = 1, #t1 do
		if not fuzzyEqual( t1[i], t2[i] ) then return false end
	end
	return true
end )
make_assertion( 'errorIs', 'error checking', function( f, message, magic )
	magic = magic or false
	local p, e = pcall( f )
	if not magic then
		message = message:gsub( '([%.%^%$%%%-%*%+])', '%%%1' ):gsub( '%[(.-)%]', '%%[%1%%]' ):gsub( '%((.-)%)', '%%(%1%%)' )
	end
	return not p and not not e:find( message )
end )
-- }}}
-- {{{ line
context( 'line', function()
	before( function()
		mlib.compatibilityMode = false
	end )
	-- {{{ line.getSlope
	context( 'getSlope', function()
		context( 'mlib', function()
			test( 'Gives the slope of a line given 4 numbers', function()
				assert_fuzzyEqual( mlib.line.getSlope( 0, 0, 1, 1 ), 1 )
				assert_fuzzyEqual( mlib.line.getSlope( 0, 1, 1, 0 ), -1 )
				assert_fuzzyEqual( mlib.line.getSlope{ 0, 0, 1, 1 }, 1 )
			end )
			test( 'Gives the slope of a line given a table and 2 numbers', function()
				assert_fuzzyEqual( mlib.line.getSlope( { 0, 0 }, 1, 1 ), 1 )
				assert_fuzzyEqual( mlib.line.getSlope( 0, 1, { 1, 0 } ), -1 )
				-- 3rd argument is skipped
				assert_fuzzyEqual( mlib.line.getSlope( { 0, 0, 5 }, { 1, 1 } ), 1 )
				-- When a table with > 2 values and another are given, arguments are skipped
				assert_fuzzyEqual( mlib.line.getSlope( { 0, 0, 1, 10 }, { 1, 1 } ), 1 )
				-- This is also acceptable
				assert_fuzzyEqual( mlib.line.getSlope( { 0 }, 0, 1, 1 ), 1 )
			end )
			test( 'Gives the slope of a line given 2 tables', function()
				assert_fuzzyEqual( mlib.line.getSlope( { 0, 0 }, { 1, 1 } ), 1 )
				assert_fuzzyEqual( mlib.line.getSlope( { 0, 1 }, { 1, 0 } ), -1 )
			end )
			test( 'Returns false if the line is vertical given 4 points', function()
				assert_false( mlib.line.getSlope( 0, 0, 0, 1 ) )
				assert_false( mlib.line.getSlope( 50, 30, 50, 20 ) )
			end )
			test( 'Returns false if the line is vertical given 2 tables', function()
				assert_false( mlib.line.getSlope( { 0, 0 }, { 0, 1 } ) )
				assert_false( mlib.line.getSlope( { 50, 30 }, { 50, 20 } ) )
			end )
			test( 'Errors if the given input is incorrect', function()
				assert_errorIs( function() mlib.line.getSlope( '1', 0, 0, 0 ) end,
					'MLib: line.getSlope: point 1: expected a number, got string'
				)
				assert_errorIs( function() mlib.line.getSlope( 1, 1 ) end,
					'MLib: line.getSlope: point 3: expected a number, got nil'
				)
			end )
			test( 'Error handling', function()
				mlib.compatibilityMode = true
				assert_errorIs( function() mlib.line.getSlope( { 0, 0 }, 1, 1 ) end,
					'MLib: line.getSlope: point 1: in compatibility mode expected a number, got table'
				)
				assert_errorIs( function() mlib.line.getSlope( 0, 0, { 1, 1 } ) end,
					'MLib: line.getSlope: point 3: in compatibility mode expected a number, got table'
				)
				assert_errorIs( function() mlib.line.getSlope( { 0, 0, 1, 1 } ) end,
					'MLib: line.getSlope: point 1: in compatibility mode expected a number, got table'
				)
				assert_errorIs( function() mlib.line.getSlope( 0, '0', 1, 1 ) end,
					'MLib: line.getSlope: point 2: in compatibility mode expected a number, got string'
				)
			end )
		end )
		context( 'turbo', function()
			test( 'Gives the slope of a line given 4 numbers', function()
				assert_fuzzyEqual( turbo.line.getSlope( 0, 0, 1, 1 ), 1 )
				assert_fuzzyEqual( turbo.line.getSlope( 0, 1, 1, 0 ), -1 )
				assert_false( turbo.line.getSlope( 0, 0, 0, 1 ) )
			end )
		end )
	end ) -- }}}
	-- {{{ line.getPerpendicularSlope
	context( 'getPerpendicularSlope', function()
		context( 'mlib', function()
			test( 'Gives the perpendicular slope of a line with the formats of line.getSlope', function()
				assert_fuzzyEqual( mlib.line.getPerpendicularSlope( 0, 0, 1, 1 ), -1 )
				assert_fuzzyEqual( mlib.line.getPerpendicularSlope( { 0, 0 }, 1, 1 ), -1 )
				assert_fuzzyEqual( mlib.line.getPerpendicularSlope( { 0, 0 }, { 1, 1 } ), -1 )
				assert_errorIs( function() mlib.line.getPerpendicularSlope( '1', 0, 0, 0 ) end,
					'MLib: line.getPerpendicularSlope: point 1: expected a number, got string'
				)
			end )
			test( '0 if the line is vertical', function()
				assert_fuzzyEqual( mlib.line.getPerpendicularSlope( 0, 0, 0, 1 ), 0 )
				assert_fuzzyEqual( mlib.line.getPerpendicularSlope( 50, 30, 50, 20 ), 0 )
			end )
			test( 'False if the line is horizontal', function()
				assert_false( mlib.line.getPerpendicularSlope( 0, 1, 1, 1 ) )
				assert_false( mlib.line.getPerpendicularSlope( 30, 50, 20, 50 ) )
			end )
			test( 'Errors if compatibilityMode is not changed', function()
				mlib.compatibilityMode = true
				assert_errorIs( function() mlib.line.getPerpendicularSlope( { 0, 0 }, 1, 1 ) end,
					'MLib: line.getPerpendicularSlope: arg 1: in compatibility mode expected a number, got table'
				)
				assert_errorIs( function() mlib.line.getPerpendicularSlope( 0, 0, 1, 1 ) end,
					'MLib: line.getPerpendicularSlope: arg 2: in compatibility mode expected nil, got number'
				)
			end )
		end )
		context( 'turbo', function()
			test( 'Gives the perpendicular slope of a line given the slope', function()
				assert_fuzzyEqual( turbo.line.getPerpendicularSlope( 1 ), -1 )
			end )
		end )
	end )
	-- }}}
	-- {{{ line.getIntercept
	context( 'getIntercept', function()
		context( 'mlib', function()
			test( 'Gets the y-intercept of a line given turbo format', function()
				assert_fuzzyEqual( mlib.line.getIntercept( 1, 0, 0 ), 0 )
				assert_fuzzyEqual( mlib.line.getIntercept( 2, 1, 4 ), 2 )
			end )
			test( 'Gets the y-intercept of a line with formats of line.getSlope', function()
				assert_fuzzyEqual( mlib.line.getIntercept( 0, 0, 1, 1 ), 0 )
				assert_fuzzyEqual( mlib.line.getIntercept( { 0, 0 }, 1, 1 ), 0 )
				assert_fuzzyEqual( mlib.line.getIntercept( 0, 0, { 1, 1 } ), 0 )
				assert_fuzzyEqual( mlib.line.getIntercept( { 0, 0 }, { 1, 1 } ), 0 )
				assert_errorIs( function() mlib.line.getIntercept( { '1', 2 }, 1, 1 ) end,
					'MLib: line.getIntercept: point 1: expected a number, got string'
				)
			end )
			test( 'Errors if compatibilityMode is true', function()
				mlib.compatibilityMode = true
				assert_errorIs( function() mlib.line.getIntercept( { 0, 0 }, 1, 1 ) end,
					'MLib: line.getIntercept: arg 1: in compatibility mode expected a number or boolean, got table'
				)
				assert_errorIs( function() mlib.line.getIntercept( 0, 0, { 1, 1 } ) end,
					'MLib: line.getIntercept: arg 3: in compatibility mode expected a number, got table'
				)
				assert_errorIs( function() mlib.line.getIntercept( { 1, 0, 0 } ) end,
					'MLib: line.getIntercept: arg 1: in compatibility mode expected a number or boolean, got table'
				)
			end )
		end )
		context( 'turbo', function()
			test( 'Gets the y-intercept of a line given the slope and a point', function()
				assert_fuzzyEqual( turbo.line.getIntercept( 1, 0, 0 ), 0 )
			end )
		end )
	end )
	-- }}}
	-- {{{ line.getLineIntersection
	context( 'getLineIntersection', function()
		context( 'mlib', function()
			test( 'Gives the intersection of two lines given 4 points', function()
				assert_multipleFuzzyEqual( { mlib.line.getLineIntersection( { 1, 0, 0 }, { -1, 0, 2 } ) }, { 1, 1 } )
				assert_multipleFuzzyEqual( { mlib.line.getLineIntersection( { 1, 0, 0 }, { 0, 2, 2, 0 } ) }, { 1, 1 } )
				assert_multipleFuzzyEqual( { mlib.line.getLineIntersection( { 0, 0, 2, 2 }, { -1, 0, 2 } ) }, { 1, 1 } )
				assert_multipleFuzzyEqual( { mlib.line.getLineIntersection( { 0, 0, 2, 2 }, { 0, 2, 2, 0 } ) }, { 1, 1 } )
			end )
			test( 'Handles vertical lines', function()
				assert_multipleFuzzyEqual( { mlib.line.getLineIntersection( { 0, 0, 0, 2 }, { -1, 1, 1, 1 } ) }, { 0, 1 } )
				assert_multipleFuzzyEqual( { mlib.line.getLineIntersection( { -1, 1, 1, 1}, { 0, 0, 0, 2 } ) }, { 0, 1 } )
				assert_true( mlib.line.getLineIntersection( { 0, 0, 0, 2 }, { 0, 1, 0, 3 } ) )
				assert_false( mlib.line.getLineIntersection( { 0, 0, 0, 2 }, { 1, 1, 1, 3 } ) )
			end )
			test( 'Errors if compatibilityMode is true', function()
				mlib.compatibilityMode = true
				-- arg 1
				assert_errorIs( function() mlib.line.getLineIntersection( { 0, 0, 2, 2 }, { 0, 2, 2, 0 } ) end,
					'MLib: line.getLineIntersection: arg 1: in compatibility mode expected a table with a length of 3, got a table with a length of 4'
				)
				assert_errorIs( function() mlib.line.getLineIntersection( { { 0, 0 }, 2, 2 }, { 0, 2, 2, 0 } ) end,
					'MLib: line.getLineIntersection: arg 1: in compatibility mode expected a table with [1], [2], and [3] to all be numbers, got table, number, number'
				)
				assert_errorIs( function() mlib.line.getLineIntersection( { 0, 0, { 2, 2 } }, { 0, 2, 2, 0 } ) end,
					'MLib: line.getLineIntersection: arg 1: in compatibility mode expected a table with [1], [2], and [3] to all be numbers, got number, number, table'
				)
				assert_errorIs( function() mlib.line.getLineIntersection( { 0, 0, 2, 2 }, { 0, 2, 2, 0 } ) end,
					'MLib: line.getLineIntersection: arg 1: in compatibility mode expected a table with a length of 3, got a table with a length of 4'
				)

				-- arg 2
				assert_errorIs( function() mlib.line.getLineIntersection( { 0, 0, 2 }, { 0, 2, 2, 0 } ) end,
					'MLib: line.getLineIntersection: arg 2: in compatibility mode expected a table with a length of 3, got a table with a length of 4'
				)
				assert_errorIs( function() mlib.line.getLineIntersection( { 0, 0, 2 }, { { 0, 2 }, 2, 0 } ) end,
					'MLib: line.getLineIntersection: arg 2: in compatibility mode expected a table with [1], [2], and [3] to all be numbers, got table, number, number'
				)
				assert_errorIs( function() mlib.line.getLineIntersection( { 0, 0, 2 }, { 0, 2, { 2, 0 } } ) end,
					'MLib: line.getLineIntersection: arg 2: in compatibility mode expected a table with [1], [2], and [3] to all be numbers, got number, number, table'
				)
				assert_errorIs( function() mlib.line.getLineIntersection( { 0, 0, 2 }, { 0, 2, 2, 0 } ) end,
					'MLib: line.getLineIntersection: arg 2: in compatibility mode expected a table with a length of 3, got a table with a length of 4'
				)
			end )
		end )
		context( 'turbo', function()
			test( 'Gives the intersection of two lines given slope and intercept', function()
				assert_multipleFuzzyEqual( { turbo.line.getLineIntersection( { 1, 0, 0 }, { -1, 0, 2 } ) }, { 1, 1 } )
			end )
		end )
	end )
	-- }}}
end )
-- }}}
-- {{{ segment
context( 'segment', function()
	before( function()
		mlib.compatibilityMode = false
	end )
	-- {{{ segment.getMidpoint
	context( 'getMidpoint', function()
		context( 'mlib', function()
			test( 'Gives the midpoint of two points with formats of line.getSlope', function()
				assert_multipleFuzzyEqual( { mlib.segment.getMidpoint( 0, 0, 2, 2 ) }, { 1, 1 } )
				assert_multipleFuzzyEqual( { mlib.segment.getMidpoint( { 0, 0 }, { 2, 2 } ) }, { 1, 1 } )
				assert_multipleFuzzyEqual( { mlib.segment.getMidpoint( { 0, 0 }, 2, 2 ) }, { 1, 1 } )
				assert_multipleFuzzyEqual( { mlib.segment.getMidpoint( 0, 0, { 2, 2 } ) }, { 1, 1 } )
				assert_errorIs( function() mlib.segment.getMidpoint( 0, 0, '2', 2 ) end,
					'MLib: segment.getMidpoint: point 3: expected a number, got string'
				)
			end )
			test( 'Errors if compatibilityMode is true', function()
				mlib.compatibilityMode = true
				assert_errorIs( function() mlib.segment.getMidpoint( { 0, 0 }, 2, 2 ) end,
					'MLib: segment.getMidpoint: point 1: in compatibility mode expected a number, got table'
				)
				assert_errorIs( function() mlib.segment.getMidpoint( { 0, 0, 2, 2 } ) end,
					'MLib: segment.getMidpoint: point 1: in compatibility mode expected a number, got table'
				)
			end )
		end )
		context( 'turbo', function()
			test( 'Gives the midpoint of two points given two points', function()
				assert_multipleFuzzyEqual( { turbo.segment.getMidpoint( 0, 0, 2, 2 ) }, { 1, 1 } )
			end )
		end )
	end )
	-- }}}
	-- {{{ segment.getLength
	context( 'getLength', function()
		context( 'mlib', function()
			test( 'Gets the distance between two points with formats of line.getSlope', function()
				assert_fuzzyEqual( mlib.segment.getLength( 0, 0, 1, 1 ), math.sqrt( 2 ) )
				assert_fuzzyEqual( mlib.segment.getLength( { 0, 0 }, { 1, 1 } ), math.sqrt( 2 ) )
				assert_fuzzyEqual( mlib.segment.getLength( { 0, 0 }, 1, 1 ), math.sqrt( 2 ) )
				assert_fuzzyEqual( mlib.segment.getLength( 0, 0, { 1, 1 } ), math.sqrt( 2 ) )
				assert_errorIs( function() mlib.segment.getLength( 0, '0', 1, 1 ) end,
					'MLib: segment.getLength: point 2: expected a number, got string'
				)
			end )
			test( 'Errors if compatibilityMode is true', function()
				mlib.compatibilityMode = true
				assert_errorIs( function() mlib.segment.getLength( { 0, 0 }, 1, 1 ) end,
					'MLib: segment.getLength: point 1: in compatibility mode expected a number, got table'
				)
				assert_errorIs( function() mlib.segment.getLength( { 0, 0, 1, 1 } ) end,
					'MLib: segment.getLength: point 1: in compatibility mode expected a number, got table'
				)
			end )
		end )
		context( 'turbo', function()
			test( 'Gets the distance between two points given two points', function()
				assert_fuzzyEqual( turbo.segment.getLength( 0, 0, 1, 1 ), math.sqrt( 2 ) )
			end )
		end )
	end )
	-- }}}
end )
-- }}}
