# foma

A finite state toolkit written by Mans Hulden.

Forked from the official version on [Google Code](http://code.google.com/p/foma/).

## Installation

To install the python module, first compile the foma library and then compile the module:

	cd foma/ && make && cd -
	python setup.py install

## Basic usage

```python
import foma
fsm = foma.read_binary('my_fsm.fsm')
for result in fsm.apply_up(word):
    print result
```
