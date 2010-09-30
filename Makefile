Multigraph.swf: _always
	-@mkdir bin-debug
	mxmlc -use-network=false -compiler.show-actionscript-warnings=false -managers flash.fonts.AFEFontManager -define=CONFIG::player10,true -output bin-debug/MultigraphApp.swf src/MultigraphApp.mxml
	cp bin-debug/MultigraphApp.swf Multigraph.swf

Multigraph.swc: _always
	-@mkdir bin-debug
	@./compile-swc
	cp bin-debug/Multigraph.swc .

dist: _always
	@./make-dist

dist-swc: _always
	@./make-dist-swc

dist-examples: _always
	@./make-dist-examples

dist-docs: _always
	@./make-dist-docs

dist-wordpress-plugin: _always
	@./make-dist-wordpress-plugin

dist-drupal-module: _always
	@./make-dist-drupal-module

dist-src: _always
	@./make-dist-src

userguide: _always
	cd userguide ; ant clean ; ant ; ant pdf

clean: _always
	/bin/rm -rf Multigraph.swf *.zip *.swc html/examples
	cd userguide ; ant clean

# tests: _always
# 	@(cd html-template ; ./make-tests)
# 
# deploy: _always
# 	/bin/rm -rf /var/www/bin-debug
# 	tar cf - bin-debug | (cd /var/www ; tar xvf -)
# 	cd /var/www/bin-debug ; (find . -name '*.cgi' -print | xargs chmod a+x)

validate: _always
	@./validate-all

schemas/multigraph.xsd: schemas/multigraph.rnc
	trang -O xsd schemas/multigraph.rnc schemas/multigraph.xsd

.PHONY: _always

# dist: _always
#	@./make-dist
#
#
#clean: _always
#	./clean-tests
#	/bin/rm -rf dist
