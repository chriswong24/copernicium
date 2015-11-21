g=copernicium
v=0.0.1

build:
	gem build $(g).gemspec
	gem install ./$(g)-$(v).gem

clean:
	rm -v *.gem

push: clean build
	gem push $(g)-$(v).gem

dev:
	filewatcher '**/*' 'clear && yes | rake'
