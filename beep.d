module beep;

import std.format : format;

enum equal;
enum unequal;
enum less;
enum greater;
enum nan;

final class ExpectException : Exception {
	pure nothrow @safe this(string msg,
								  string file = __FILE__,
								  size_t line = __LINE__,
								  Throwable nextInChain = null) {
		super("Expectation failed: " ~ msg, file, line, nextInChain);
	}
}

T1 expect(OP, T1, T2)(lazy T1 lhs, lazy T2 rhs, string msg = "", string file = __FILE__, size_t line = __LINE__)
if(is(OP == equal) && __traits(compiles, lhs == rhs)) {
	if(!(lhs == rhs))
		throw new ExpectException(
			"`%s` is expected, got `%s`".format(rhs, lhs),
			file,
			line,
		);

	return lhs;
}

@("expect!equal")
unittest {
	1.expect!equal(1);
	"Hi!".expect!equal("Hi!");

	struct S {
		int* ptr;
	}

	S(null).expect!equal(S(null));
}

@("expect!equal checks can be chained")
unittest {
	1.expect!equal(1)
		.expect!equal(1)
		.expect!equal(1);
}

T1 expect(OP, T1, T2)(lazy T1 lhs, lazy T2 rhs, string msg = "", string file = __FILE__, size_t line = __LINE__)
if(is(OP == less) && __traits(compiles, lhs < rhs)) {
	if(!(lhs < rhs))
		throw new ExpectException(
			"value less than `%s` is expected, got`%s`".format(rhs, lhs),
			file,
			line,
		);

	return lhs;
}

@("expect!less")
unittest {
	1.expect!less(2);
	1.expect!less(1.00001);
}

@("expect!less checks can be chained")
unittest {
	1.expect!less(2)
		.expect!less(3)
		.expect!less(4)
		.expect!less(5)
		.expect!less(6);
}

T1 expect(OP, T1, T2)(lazy T1 lhs, lazy T2 rhs, string msg = "", string file = __FILE__, size_t line = __LINE__)
if(is(OP == greater) && __traits(compiles, lhs > rhs)) {
	if(!(lhs > rhs))
		throw new ExpectException(
			"value greater than `%s` is expected, got `%s`".format(rhs, lhs),
			file,
			line,
		);

	return lhs;
}

@("expect!greater")
unittest {
	1.expect!greater(0);
	1.001.expect!greater(1);
}

@("expect!greater checks can be chained")
unittest {
	1.expect!greater(0)
		.expect!greater(-1)
		.expect!greater(-2)
		.expect!greater(-3)
		.expect!greater(-4)
		.expect!greater(-5);
}

T1 expect(OP, T1)(lazy T1 lhs, string msg = "", string file = __FILE__, size_t line = __LINE__)
if(is(OP == nan) && __traits(compiles, {import std.math : isNaN; lhs.isNaN;})) {
	import std.math : isNaN;
	if(!lhs.isNaN)
		throw new ExpectException(
			"NaN is expected, got `%s`".format(lhs),
			file,
			line,
		);

	return lhs;
}

@("expect!nan")
unittest {
	float.init.expect!nan;
	real.nan.expect!nan;
}

@("expect!nan checks can be chained")
unittest {
	real.nan.expect!nan
		.expect!nan
		.expect!nan
		.expect!nan;
}