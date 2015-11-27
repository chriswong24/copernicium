g=copernicium
v=0.0.1

build:
	gem build $(g).gemspec
	gem install ./$(g)-$(v).gem

clean:
	rm -vf *.gem

push: clean build
	gem push $(g)-$(v).gem

dev:
	filewatcher '**/*.rb' 'clear && rake'
