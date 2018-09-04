module beep;

import std.format : format;

enum equal;
enum less;
enum greater;
enum nan;
enum throw_;

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

T1 expect(typeof(null) null_, T1)(lazy T1 lhs, string msg = "", string file = __FILE__, size_t line = __LINE__) {
	if(lhs !is null)
		throw new ExpectException(
			"null is expected, got `%s`".format(lhs),
			file,
			line,
		);

	return lhs;
}

@("expect!null")
unittest {
	void delegate() func;
	func.expect!null;

	null.expect!null;
}

auto expect(OP, E : Exception = Exception, T1)(lazy T1 lhs, string msg = "", string file = __FILE__, size_t line = __LINE__)
if(is(OP == throw_) && __traits(compiles, {lhs(/+_+/)(/*_*/);})) {
	struct Result {
		T1 data;
		string message;
	}

	Result r = Result(lhs);

	try {
		lhs()();
	} catch(Exception e) {
		if(!(cast(E) e))
			throw new ExpectException(
				"`%s` is expected to be thrown, an exception of type `%s` has been thrown instead".format(
					typeid(E).name,
					typeid(e).name),
				file,
				line,
				e,
			);

		r.message = e.message.idup;
		return r;
	}

	throw new ExpectException(
		"`%s` is expected to be thrown, but nothing has been thrown".format(typeid(E).name),
		file,
		line,
	);
}

@("expect!throw_")
unittest {
	({
		throw new Exception("Hello!");
	}).expect!throw_;
}

@("expect!(throw_, CustomException)")
unittest {
	final class CustomException : Exception {
		pure nothrow @nogc @safe this(string msg) {
			super(msg);
		}
	}

	({
		throw new CustomException("message");
	}).expect!(throw_, CustomException);

	({
		throw new CustomException("message");
	}).expect!(throw_, Exception);

	({
		({
			throw new Exception("message");
		}).expect!(throw_, CustomException);
	}).expect!(throw_, ExpectException);
}

@("expect!throw_ returns a tuple of the input data and message of the exception that has been thrown")
unittest {
	auto func = ({
		throw new Exception("Hello!");
	});
	
	auto result = func.expect!throw_;

	(func is result.data).expect!equal(true);
	result.message.expect!equal("Hello!");
}

@("expect!throw_ does *not* catch Errors")
unittest {
	import core.exception : AssertError;

	bool success;
	try {
		({
			assert(false);
		}).expect!throw_;
	} catch(AssertError e) { // This is something nobody should ever do
		success = true;
	}

	success.expect!equal(true);
}