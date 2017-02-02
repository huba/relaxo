# Relaxo

Relaxo is a transactional database built on top of git. It's aim is to provide a robust interface for document storage.

[![Build Status](https://secure.travis-ci.org/ioquatix/relaxo.svg)](http://travis-ci.org/ioquatix/relaxo)
[![Code Climate](https://codeclimate.com/github/ioquatix/relaxo.svg)](https://codeclimate.com/github/ioquatix/relaxo)
[![Coverage Status](https://coveralls.io/repos/ioquatix/relaxo/badge.svg)](https://coveralls.io/r/ioquatix/relaxo)

## Installation

Add this line to your application's Gemfile:

	gem 'relaxo'

And then execute:

	$ bundle

Or install it yourself as:

	$ gem install relaxo

## Usage

Connect to a local database and manipulate some documents.

	require 'relaxo'
	require 'msgpack'
	
	DB = Relaxo.connect("test")
	
	DB.commit(message: "Create test data") do |dataset|
		dataset.write("doc1.json", MessagePack.dump({bob: 'dole'}))
	end
	
	DB.commit(message: "Update test data") do |dataset|
		doc = MessagePack.load dataset.read('doc1.json')
		doc[:foo] = 'bar'
		dataset.write("doc2.json", MessagePack.dump(doc))
	end
	
	doc = MessagePack.load DB.current['doc2.json']
	puts doc
	# => {"bob"=>"dole", "foo"=>"bar"}

### Datasets and Transactions

Datasets and Transactions are important concepts within relaxo.

	require 'relaxo'
	require 'securerandom'
	
	database = Relaxo.connect("http://localhost:5984/test")
	animals = ['Neko-san', 'Wan-chan', 'Nezu-chan', 'Chicken-san']
	
	# All writes must occur within a commit:
	database.commit("Add animals") do |dataset|
		animals.each do |animal|
			dataset.write("/animals/#{SecureRandom.uuid}", JSON.dump({name: animal}))
		end
	end

All documents will allocated UUIDs appropriately and at the end of the session block they will be updated (saved or deleted) using CouchDB `_bulk_save`. The Transactions interface doesn't support any kind of interaction with the server and thus views won't be updated until after the transaction is complete.

To abort the session, either raise an exception or call `transaction.abort!` which is equivalent to `throw :abort`.

### Loading Data

Relaxo includes a command line script to import documents into a CouchDB database:

	% relaxo --help
	Usage: relaxo [options] [server-url] [files]
	This script can be used to import data to CouchDB.

	Document creation:
					--existing [mode]            Control whether to 'update (new document attributes takes priority), 'merge' (existing document attributes takes priority) or replace (old document attributes discarded) existing documents.
					--format [type]              Control the input format. 'yaml' files are imported as a single document or array of documents. 'csv' files are imported as records using the first row as attribute keys.
					--[no-]transaction           Controls whether data is saved using the batch save operation. Not suitable for huge amounts of data.

	Help and Copyright information:
					--copy                       Display copyright and warranty information
			-h, --help                       Show this help message.

This command loads the documents stored in `design.yaml` and `sample.yaml` into the database at `http://localhost:5984/test`.

	% relaxo http://localhost:5984/test design.yaml sample.yaml

...where `design.yaml` and `sample.yaml` contain lists of valid documents, e.g.:

	# design.yaml
	-   _id: "_design/services"
			language: javascript
			views:
					service:
							map: |
									function(doc) {
											if (doc.type == 'service') {
													emit(doc._id, doc._rev);
											}
									}

If you specify `--format=csv`, the input files will be parsed as standard CSV. The document schema is inferred from the zeroth (header) row and all subsequent rows will be converted to individual documents. All fields will be saved as text.

If your requirements are more complex, consider writing a custom script either to import directly using the `relaxo` gem or convert your data to YAML and import that as above.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the MIT license.

Copyright, 2015, by [Samuel G. D. Williams](http://www.codeotaku.com/samuel-williams).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
