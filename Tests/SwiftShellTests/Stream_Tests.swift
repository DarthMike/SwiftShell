//
// Stream_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 21/08/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

@testable import SwiftShell
import XCTest

public class Stream_Tests: XCTestCase {

	func testStreams () {
		let (writer,reader) = streams()

		writer.write("one")
		XCTAssertEqual(reader.readSome(), "one")

		writer.print()
		writer.print("two")
		XCTAssertEqual(reader.readSome(), "\ntwo\n")

		writer.write("three")
		writer.close()
		XCTAssertEqual(reader.read(), "three")
	}

	func testReadableStreamRun () {
		let (writer,reader) = streams()

		writer.write("one")
		writer.close()

		XCTAssertEqual(reader.run("cat"), "one")
	}

	func testReadableStreamRunAsync () {
		let (writer,reader) = streams()

		writer.write("one")
		writer.close()

		XCTAssertEqual(reader.runAsync("cat").stdout.read(), "one")
	}

	func testPrintStream () {
		let (writer,reader) = streams()
		writer.write("one")
		writer.close()

		var string = ""
		print(reader, to: &string)
		
		XCTAssertEqual(string, "one\n")
	}

	func testPrintToStream () {
		let (w,reader) = streams()
		// 'print' does not work with protocol types directly, not even 'TextOutputStream'.
		var writer = w as! FileHandleStream

		print("one", to: &writer)

		XCTAssertEqual(reader.readSome(), "one\n")
	}

	func testPrintWorksTheSameAsTheBuiltinOne() {
		let (writer, reader) = streams()

		var text = ""
		print(to: &text)
		writer.print()
		XCTAssertEqual(reader.readSome(), text)

		text = ""
		print("1",to: &text)
		writer.print("1")
		XCTAssertEqual(reader.readSome(), text)

		text = ""
		print("1",2,3.0, to: &text)
		writer.print("1",2,3.0)
		XCTAssertEqual(reader.readSome(), text)

		text = ""
		print("1",[2,3], separator:"", terminator:"", to: &text)
		writer.print("1",[2,3], separator:"", terminator:"")
		XCTAssertEqual(reader.readSome(), text)
	}

#if os(macOS)
	func testOnOutput () {
		let (writer,reader) = streams()

		let expectoutput = expectation(description: "onOutput will be called when output is available")
		reader.onOutput { stream in
			if stream.readSome() != nil {
				expectoutput.fulfill()
			}
		}
		writer.print()
		waitForExpectations(timeout: 0.5, handler: nil)
	}

	func testOnStringOutput () {
		let (writer,reader) = streams()

		let expectoutput = expectation(description: "onOutput will be called when output is available")
		reader.onStringOutput { string in
			XCTAssertEqual(string, "hi")
			expectoutput.fulfill()
		}
		writer.write("hi")
		waitForExpectations(timeout: 0.5, handler: nil)
	}
#endif
}

extension Stream_Tests {
	public static var allTests = [
		("testStreams", testStreams),
		("testReadableStreamRun", testReadableStreamRun),
		("testReadableStreamRunAsync", testReadableStreamRunAsync),
		("testPrintStream", testPrintStream),
		("testPrintToStream", testPrintToStream),
		("testPrintWorksTheSameAsTheBuiltinOne", testPrintWorksTheSameAsTheBuiltinOne),
		//("testOnOutput", testOnOutput),
		//("testOnStringOutput", testOnStringOutput),
		]
}
