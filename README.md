### NoGo is a library to find the places in your code which touch your database
Nogo's main objective is to help find and prevent code which accesses the database during testing.

## Installation
Add nogo to your Gemfile

```gem 'nogo'```

Or install from the command line

```gem install nogo```

## Usage

Currently RSpec 2 is the only test framework which is supported.

### RSpec
Wrap any spec examples that should not use the database adapter inside a "nogo do" block.

<pre>
# In your specs
require 'nogo/rspec' # Automatically connects, so this should be included after the environment is loaded.

describe Klass do
  it 'works without error' do
    Klass.create
  end

  nogo do # Any access to the database inside this block will raise an exception
    it 'raises error' do
      expect{ Klass.create }.to raise_error
    end
  end

  it 'works without error' do
    Klass.create
  end
end
</pre>

### Globally enabling NoGo
By default NoGo will not check requests to the database, even after being connected.  Here is an example of enabling NoGo.

<pre>
require 'nogo'

# Database adapter should already be connected
NoGo::Connection.connect!

ModelKlass.create                   # Works as expected

NoGo::Connection.enabled = true
ModelKlass.create                   # Raises exception

NoGo::Connection.enabled = false
ModelKlass.create                   # Works as expected
</pre>

## Platforms
Tested with:

RSpec 2.7.0, 2.8.0
ActiveRecord 3.1.3, 3.2.1.

##LICENSE

(The MIT License)

Copyright © 2012 Andy Ogzewalla

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.