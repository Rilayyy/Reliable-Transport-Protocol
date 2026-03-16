all:
	chmod +x 4700send 4700recv

zip:
	zip -r submission.zip 4700send 4700recv Makefile README.md

clean:
	rm -f submission.zip
	rm -rf __pycache__