g=copernicium
v=0.2.3

build:
	gem build $(g).gemspec
	gem install ./$(g)-$(v).gem

clean:
	rm -vf *.gem
	rm -rf html

push: clean build
	gem push $(g)-$(v).gem

doc:
	rm -rf html
	rake rdoc

dev:
	filewatcher '**/*.rb' 'clear && yes | rake'

