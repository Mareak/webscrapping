SCRIPT=./app/webapp.py
INI=webapp.ini
TEST=./app/test.py

test: prepare test_syntax test_appli
run: prepare launch

prepare:
	 pipenv install

test_syntax:
	 pipenv run python $(TEST) $(SCRIPT)
	
test_appli:
	 pipenv run pytest $(SCRIPT) -v

launch:
	cd app && pipenv run uwsgi --ini $(INI)
