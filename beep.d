module beep;

import std.format : format;

enum equal;
enum unequal;
enum less;
enum greater;
enum nan;

final class ExpectException : Exception {
	pure nothrow @nogc @safe this(string msg,
								  string file = __FILE__,
								  size_t line = __LINE__,
								  Throwable nextInChain = null) {
		super(msg, file, line, nextInChain);
	}
}

auto expect(OP, T1, T2)(lazy T1 lhs, lazy T2 rhs, string msg = "", string file = __FILE__, size_t line = __LINE__)
if((is(OP == equal) || is(OP == unequal)) && __traits(compiles, lhs == rhs)) {
	if(lhs == rhs) {
		if(is(OP == unequal))
			throw new ExpectException(
				"`%s` is expected to not be equal to `%s`%s".format(lhs, rhs, msg.length ? " " ~ msg : ""),
				file,
				line,
			);
	} else {
		if(is(OP == equal))
			throw new ExpectException(
				"`%s` is expected to be equal to `%s`%s".format(lhs, rhs, msg.length ? " " ~ msg : ""),
				file,
				line,
			);
	}
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

@("expect!unequal")
unittest {
	1.expect!unequal(2);
	"Hello!".expect!unequal("Hi!");
}

auto expect(OP, T1, T2)(lazy T1 lhs, lazy T2 rhs, string msg = "", string file = __FILE__, size_t line = __LINE__)
if(is(OP == less) && __traits(compiles, lhs < rhs)) {
	if(!(lhs < rhs))
		throw new ExpectException(
			"`%s` is expected to be less than `%s`%s".format(lhs, rhs, msg.length ? " " ~ msg : ""),
			file,
			line,
		);
}

@("expect!less")
unittest {
	1.expect!less(2);
	1.expect!less(1.00001);
}

auto expect(OP, T1, T2)(lazy T1 lhs, lazy T2 rhs, string msg = "", string file = __FILE__, size_t line = __LINE__)
if(is(OP == greater) && __traits(compiles, lhs > rhs)) {
	if(!(lhs > rhs))
		throw new ExpectException(
			"`%s` is expected to be greater than `%s`%s".format(lhs, rhs, msg.length ? " " ~ msg : ""),
			file,
			line,
		);
}

@("expect!greater")
unittest {
	1.expect!greater(0);
	1.001.expect!greater(1);
}

auto expect(OP, T1)(lazy T1 lhs, string msg = "", string file = __FILE__, size_t line = __LINE__)
if(is(OP == nan) && __traits(compiles, {import std.math : isNaN; lhs.isNaN;})) {
	import std.math : isNaN;
	if(!lhs.isNaN)
		throw new ExpectException(
			"`%s` is expected to be NaN%s".format(lhs, msg.length ? " " ~ msg : ""),
			file,
			line,
		);
}

@("expect!nan")
unittest {
	float.init.expect!nan;
	real.nan.expect!nan;
}