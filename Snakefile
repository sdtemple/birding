import os
# Create a folder named 'ran' if it doesn't exist
input_folder = config["input_folder"]
sub_folder = config["sub_folder"]
output_folder = config["output_folder"]
params_file = config["params_file"]
metadata_file = config["metadata_file"]
taxonomy_file = config["taxonomy_file"]
one_obs = config["one_obs"]
if not os.path.exists(input_folder):
    raise ValueError(f"Input folder {input_folder} does not exist.")
input_folder = input_folder.rstrip("/") + "/" + sub_folder
if not os.path.exists(input_folder):
    raise ValueError(f"Input folder {input_folder} does not exist.")
if not os.path.exists(output_folder):
    os.makedirs(output_folder)

# Stop once we have these files
rule all:
    input:
        f'{output_folder}/X_tensor.pt',
        f'{output_folder}/Y_tensor.pt',
        f'{output_folder}/birds.csv',
        f'{output_folder}/files.csv',
        f'{output_folder}/zc_rates.csv',
        # f'{output_folder}/train_metadata_cleaned.csv',
        # f'{output_folder}/train_metadata_nuanced.csv',
        # f'{output_folder}/common_species.txt',
        # f'{output_folder}/geography.txt',
        # f'{output_folder}/taxonomy.txt',
        # f'{output_folder}/species_map.png',
        # f'{output_folder}/orig_metadata.csv',
        # f'{output_folder}/orig_taxonomy.csv',

rule tensorize:
    input:
        notebook = "scripts/tensorize.ipynb",
        file = f'{input_folder.rstrip("/")}/{one_obs}',
    output:
        f'{output_folder}/X_tensor.pt',
        f'{output_folder}/Y_tensor.pt',
        f'{output_folder}/birds.csv',
        f'{output_folder}/files.csv',
        f'{output_folder}/zc_rates.csv',
    params:
        file = f'{params_file}',
        input_folder = f'{input_folder.rstrip("/")}',
        output_folder = f'{output_folder.rstrip("/")}',
    shell:
        """papermill \
            -p params_file {params.file} \
            -p input_folder {params.input_folder} \
            -p output_folder {params.output_folder} \
            --log-output \
            {input.notebook} \
            ran/tensorize.ipynb
        """

# Run the initial filtering of metadata
rule clean:
    input:
        notebook = "scripts/filter_metadata.ipynb",
        file = f'{metadata_file}',
    output:
        file = f'{output_folder.rstrip('/')}/train_metadata_cleaned.csv',
        copied = f'{output_folder.rstrip("/")}/orig_metadata.csv',
    params:
        file = f'{params_file}',
    shell:
        """
        cp {input.file} {output.copied}
        papermill \
            -p params_file {params.file} \
            -p input_file {input.file} \
            -p output_file {output.file} \
            --log-output \
            {input.notebook} \
            ran/filter_metadata.ipynb
        """

# Make a map of where observations were made
rule globe:
    input:
        notebook = "scripts/species_map.ipynb",
        file = f'{output_folder.rstrip("/")}/train_metadata_cleaned.csv',
    output:
        file = f'{output_folder.rstrip("/")}/species_map.png',
    shell:
        """papermill \
            -p input_file {input.file} \
            -p output_file {output.file} \
            --log-output \
            {input.notebook} \
            ran/species_map.ipynb
        """

# Determine the top N most common species
rule common:
    input:
        notebook = "scripts/common_species.ipynb",
        file = f'{output_folder.rstrip("/")}/train_metadata_cleaned.csv',
    output:
        file = f'{output_folder.rstrip("/")}/common_species.txt',
    params:
        file = f'{params_file}',
    shell:
        """papermill \
            -p params_file {params.file} \
            -p input_file {input.file} \
            -p output_file {output.file} \
            --log-output \
            {input.notebook} \
            ran/common_species.ipynb
        """

# Extract geographically diverse species
rule geography:
    input:
        notebook = "scripts/geography.ipynb",
        file = f'{output_folder.rstrip("/")}/train_metadata_cleaned.csv',
        common = f'{output_folder.rstrip("/")}/common_species.txt',
    output:
        file = f'{output_folder.rstrip("/")}/geography.txt',
    params:
        file = f'{params_file}',
    shell:
        """papermill \
            -p params_file {params.file} \
            -p input_file {input.file} \
            -p output_file {output.file} \
            -p common_file {input.common} \
            --log-output \
            {input.notebook} \
            ran/geography.ipynb
        """

# Extract some species from all orders
rule taxonomy:
    input:
        notebook = "scripts/taxonomy.ipynb",
        file = f'{output_folder.rstrip("/")}/train_metadata_cleaned.csv',
        taxo = f'{taxonomy_file}',
        common = f'{output_folder.rstrip("/")}/common_species.txt',
        geography = f'{output_folder.rstrip("/")}/geography.txt',
    output:
        file = f'{output_folder.rstrip("/")}/taxonomy.txt',
        copied = f'{output_folder.rstrip("/")}/orig_taxonomy.csv',
    params:
        file = f'{params_file}',
    shell:
        """
        cp {input.taxo} {output.copied}
        papermill \
            -p params_file {params.file} \
            -p input_file {input.file} \
            -p output_file {output.file} \
            -p common_file {input.common} \
            -p geography_file {input.geography} \
            -p taxonomy_file {input.taxo} \
            --log-output \
            {input.notebook} \
            ran/taxonomy.ipynb
        """

# Extract data from type column
rule nuance:
    input:
        notebook = "scripts/nuanced.ipynb",
        file = f'{output_folder.rstrip("/")}/train_metadata_cleaned.csv',
    output:
        file = f'{output_folder.rstrip("/")}/train_metadata_nuanced.csv',
    params:
        file = f'{params_file}',
        prefix = f'{output_folder.rstrip("/")}/train_metadata',
    shell:
        """
        papermill \
            -p params_file {params.file} \
            -p input_file {input.file} \
            -p output_prefix {params.prefix} \
            --log-output \
            {input.notebook} \
            ran/nuanced.ipynb
        """