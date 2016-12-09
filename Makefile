all: zip upload

zip:
	rm ca.cybera.Apache.zip || true
	zip -r ca.cybera.Apache.zip *

upload:
	murano package-import --is-public --exists-action u ca.cybera.Apache.zip
