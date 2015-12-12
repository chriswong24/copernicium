g=copernicium
v=0.2.3

build:
	gem build $(g).gemspec
	gem install ./$(g)-$(v).gem

clean:
	rm -vf *.gem

push: clean build
	gem push $(g)-$(v).gem

dev:
	filewatcher '**/*.rb' 'clear && yes | rake'

