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
-- }}}
-- {{{ line
context( 'line', function()
	-- {{{ line.getSlope
	context( 'getSlope', function()
		context( 'mlib', function()
			test( 'Gives the slope of a line given 4 numbers', function()
				assert_fuzzyEqual( mlib.line.getSlope( 0, 0, 1, 1 ), 1 )
				assert_fuzzyEqual( mlib.line.getSlope( 0, 1, 1, 0 ), -1 )
			end )
			test( 'Gives the slope of a line given a table and 2 numbers', function()
				assert_fuzzyEqual( mlib.line.getSlope( { 0, 0 }, 1, 1 ), 1 )
				assert_fuzzyEqual( mlib.line.getSlope( 0, 1, { 1, 0 } ), -1 )
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
				assert_error( function() mlib.line.getSlope( '1', 0, 0, 0 ) end )
				assert_error( function() mlib.line.getSlope( 1, 1 ) end )
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
				assert_error( function() mlib.line.getPerpendicularSlope( '1', 0, 0, 0 ) end )
			end )
			test( '0 if the line is vertical', function()
				assert_fuzzyEqual( mlib.line.getPerpendicularSlope( 0, 0, 0, 1 ), 0 )
				assert_fuzzyEqual( mlib.line.getPerpendicularSlope( 50, 30, 50, 20 ), 0 )
			end )
			test( 'False if the line is horizontal', function()
				assert_false( mlib.line.getPerpendicularSlope( 0, 1, 1, 1 ) )
				assert_false( mlib.line.getPerpendicularSlope( 30, 50, 20, 50 ) )
			end )
		end )
		context( 'turbo', function()
			test( 'Gives the perpendicular slope of a line with the formats of line.getSlope', function()
				assert_fuzzyEqual( turbo.line.getPerpendicularSlope( 1 ), -1 )
			end )
		end )
	end )
	-- }}}
	-- {{{ line.getMidpoint
	context( 'getMidpoint', function()
		context( 'mlib', function()
			test( 'Gives the midpoint of two points with formats of line.getSlope', function()
				assert_multipleFuzzyEqual( { mlib.line.getMidpoint( 0, 0, 2, 2 ) }, { 1, 1 } )
				assert_multipleFuzzyEqual( { mlib.line.getMidpoint( { 0, 0 }, { 2, 2 } ) }, { 1, 1 } )
				assert_multipleFuzzyEqual( { mlib.line.getMidpoint( { 0, 0 }, 2, 2 ) }, { 1, 1 } )
				assert_multipleFuzzyEqual( { mlib.line.getMidpoint( 0, 0, { 2, 2 } ) }, { 1, 1 } )
				assert_error( function() mlib.line.getMidpoint( 0, 0, '2', 2 ) end )
			end )
		end )
		context( 'turbo', function()
			test( 'Gives the midpoint of two points with formats of line.getSlope', function()
				assert_multipleFuzzyEqual( { turbo.line.getMidpoint( 0, 0, 2, 2 ) }, { 1, 1 } )
			end )
		end )
	end )
	-- }}}
	-- {{{ line.getLength
	context( 'getLength', function()
		context( 'mlib', function()
			test( 'Gets the distance between two points with formats of line.getSlope', function()
				assert_fuzzyEqual( mlib.line.getLength( 0, 0, 1, 1 ), math.sqrt( 2 ) )
				assert_fuzzyEqual( mlib.line.getLength( { 0, 0 }, { 1, 1 } ), math.sqrt( 2 ) )
				assert_fuzzyEqual( mlib.line.getLength( { 0, 0 }, 1, 1 ), math.sqrt( 2 ) )
				assert_fuzzyEqual( mlib.line.getLength( 0, 0, { 1, 1 } ), math.sqrt( 2 ) )
				assert_error( function() mlib.line.getLength( 0, '0', 1, 1 ) end )
			end )
		end )
		context( 'turbo', function()
			test( 'Gets the distance between two points with formats of line.getSlope', function()
				assert_fuzzyEqual( turbo.line.getLength( 0, 0, 1, 1 ), math.sqrt( 2 ) )
			end )
		end )
	end )
	-- }}}
	-- {{{ line.getIntercept
	context( 'getIntercept', function()
		context( 'mlib', function()
			test( 'Gets the y-intercept of a line with formats of line.getSlope', function()
				assert_fuzzyEqual( mlib.line.getIntercept( 0, 0, 1, 1 ), 0 )
				assert_fuzzyEqual( mlib.line.getIntercept( { 0, 0 }, 1, 1 ), 0 )
				assert_fuzzyEqual( mlib.line.getIntercept( 0, 0, { 1, 1 } ), 0 )
				assert_fuzzyEqual( mlib.line.getIntercept( { 0, 0 }, { 1, 1 } ), 0 )
				assert_error( function() mlib.line.getIntercept( { '1', 2 }, 1, 1 ) end )
			end )
		end )
		context( 'turbo', function()
			test( 'Gets the y-intercept of a line with formats of line.getSlope', function()
				assert_fuzzyEqual( turbo.line.getIntercept( 1, 1, 1 ), 0 )
			end )
		end )
	end )
	-- }}}
	-- {{{ line.getLineIntersection
	context( 'getLineIntersection', function()
		context( 'mlib', function()
			test( 'Gives the intersection of two lines', function()
				assert_multipleFuzzyEqual( { mlib.line.getLineIntersection( { 0, 0, 2, 2 }, { 0, 2, 2, 0 } ) }, { 1, 1 } )
				assert_multipleFuzzyEqual( { mlib.line.getLineIntersection( { { 0, 0 }, 2, 2 }, { 0, 2, 2, 0 } ) }, { 1, 1 } )
			end )
		end )
		context( 'turbo', function()
			test( 'Gives the intersection of two lines', function()
				assert_multipleFuzzyEqual( { turbo.line.getLineIntersection( { 1, 0 }, { -1, 2 } ) }, { 1, 1 } )
			end )
		end )
	end )
	-- }}}
end )
-- }}}
