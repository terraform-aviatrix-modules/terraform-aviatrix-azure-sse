gen_module_docs: fmt
	terraform-docs .

fmt:
	terraform fmt -recursive
