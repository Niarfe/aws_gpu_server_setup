default:
	@cat makefile

lab_up:
	. env/bin/activate; jupyter lab --ip=0.0.0.0 --port=8888 --no-browser


remote:
	. env/bin/activate; jupyter lab --ip=127.0.0.1 --port=8888 --no-browser
