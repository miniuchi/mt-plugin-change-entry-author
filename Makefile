zip:
	cd .. && zip -r mt-plugin-change-entry-author/mt-plugin-change-entry-author.zip mt-plugin-change-entry-author -x *.git* */t/* */.travis.yml */Makefile

clean:
	rm mt-plugin-change-entry-author.zip

