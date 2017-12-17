
all: test

shunit2-2.1.6:
	# https://github.com/soulseekah/test-shunit2-travis/blob/master/.travis.yml
	curl -L "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/shunit2/shunit2-2.1.6.tgz" | tar zx

test: shunit2-2.1.6 integrationtest_run unittest_run

integrationtest_run:
	./integration_test/test_basic_functionality.sh
	
unittest_run:
	./test/methods_test.sh

clean:
	rm -Rf shunit2-2.1.6
	find -iname "*~" -exec rm {} \;

release: test
	tar -zcvf jebackup-0.9.0.tgz bin/ integration_test/ Makefile

	

