
OUTPUT=tmp
DOC_OUTPUT=${OUTPUT}/doc
DOC_INPUT=doc

doc: README.md ${DOC_INPUT}/*.md
	@echo "=====> Building documentation"
	mkdir -p ${DOC_OUTPUT}
	markdown README.md > ${DOC_OUTPUT}/README.html
	markdown ${DOC_INPUT}/00_setting_up_the_local_pacman_repo.md > ${DOC_OUTPUT}/00_setting_up_the_local_pacman_repo.html
	markdown ${DOC_INPUT}/01_imaging.md > ${DOC_OUTPUT}/01_imaging.html
	markdown ${DOC_INPUT}/02_first_boot.md > ${DOC_OUTPUT}/02_first_boot.html
	markdown ${DOC_INPUT}/03_setting_up_the_mesh_network.md > ${DOC_OUTPUT}/03_setting_up_the_mesh_network.html
	@echo "Documentation can be found in ${DOC_OUTPUT}/README.html"

clean:
	rm -rf ${OUTPUT}

