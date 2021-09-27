This is a place to store documentation about our software that has
been using html generating systems like
[Roxygen2](https://cran.r-project.org/web/packages/roxygen2/vignettes/roxygen2.html),
[Sphinx](https://www.sphinx-doc.org/en/master/), or
[MkDocs](https://www.mkdocs.org/).

This is a static website host so any html created via any means can
be added to this site. However the scope of this website is purely
about package/software docmentation.

#### Adding new software to the website

You can add new files to the website by uploading them to
`s3://wbkb/docs/<software_name>`. How you do this is dependant
on how you make the html. If you used sphinx there will be a directory
called `_build/html` which gets produced, all of the files beneath
that directory should be uploaded. For an example of a sphinx project
see the [dogma repository](https://github.com/wholebiome/dogma) on
github. You can also automate the document upload process using drone,
see [here](https://github.com/wholebiome/dogma/blob/master/.drone.yml#L28-L45)
for an example config.

##### Documenting boxer operators and workflows
Generally operators and workflows won't have documentation built
with any of these systems however it's easy to produse some simple
documentation using [pandoc](https://pandoc.org/). One easy way to
semi-automate this is by using a makefile which you can place in
the root directory of your operator or workflow. Below is an example
of the makefile rules to make and push an index file from the
README.md of the operator. Make sure to change the placeholder
values.

```make
.PHONY: push-docs

index.html: README.md
	pandoc -s --css=/style.css README.md -o index.html --metadata pagetitle="<NAME>"

push-docs: index.html
	aws s3 cp index.html s3://wbkb/docs/<operators|workflows>/<NAME>/
```
