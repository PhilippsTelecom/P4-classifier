all: compile

run:
	./p4app run .

compile:
	./p4app run . compile



h1:
	./p4app exec m h1 bash

h2:
	./p4app exec m h2 bash
