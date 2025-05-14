import os
# Create a folder named 'ran' if it doesn't exist
os.makedirs("ran", exist_ok=True)
os.makedirs("metadata", exist_ok=True)
os.makedirs("arraydata", exist_ok=True)

# Stop once we have these files
rule all:
    input:
        "metadata/taxonomy.txt",
        "metadata/species_map.png",
        "metadata/train_metadata_nuanced.csv",
        "audio_touched",

# Run the initial filtering of metadata
rule clean:
    input:
        notebook = "scripts/filter_metadata.ipynb",
        file = "metadata/train_metadata.csv",
    output:
        file = "metadata/train_metadata_cleaned.csv",
    params:
        file = "preprocessing.json",
    shell:
        """papermill \
            -p params_file {params.file} \
            -p input_file {input.file} \
            -p output_file {output.file} \
            {input.notebook} \
            ran/filter_metadata.ipynb
        """

# Make a map of where observations were made
rule globe:
    input:
        notebook = "scripts/species_map.ipynb",
        file = "metadata/train_metadata.csv",
    output:
        file = "metadata/species_map.png",
    shell:
        """papermill \
            -p input_file {input.file} \
            -p output_file {output.file} \
            {input.notebook} \
            ran/species_map.ipynb
        """

# Determine the top N most common species
rule common:
    input:
        notebook = "scripts/common_species.ipynb",
        file = "metadata/train_metadata_cleaned.csv",
    output:
        file = "metadata/common_species.txt",
    params:
        file = "preprocessing.json",
    shell:
        """papermill \
            -p params_file {params.file} \
            -p input_file {input.file} \
            -p output_file {output.file} \
            {input.notebook} \
            ran/common_species.ipynb
        """

# Extract geographically diverse species
rule geography:
    input:
        notebook = "scripts/geography.ipynb",
        file = "metadata/train_metadata_cleaned.csv",
        common = "metadata/common_species.txt",
    output:
        file = "metadata/geography.txt",
    params:
        file = "preprocessing.json",
    shell:
        """papermill \
            -p params_file {params.file} \
            -p input_file {input.file} \
            -p output_file {output.file} \
            -p common_file {input.common} \
            {input.notebook} \
            ran/geography.ipynb
        """

# Extract some species from all orders
rule taxonomy:
    input:
        notebook = "scripts/taxonomy.ipynb",
        file = "metadata/train_metadata_cleaned.csv",
        common = "metadata/common_species.txt",
        geography = "metadata/geography.txt",
    output:
        file = "metadata/taxonomy.txt",
    params:
        file = "preprocessing.json",
    shell:
        """papermill \
            -p params_file {params.file} \
            -p input_file {input.file} \
            -p output_file {output.file} \
            -p common_file {input.common} \
            -p geography_file {input.geography} \
            {input.notebook} \
            ran/taxonomy.ipynb
        """

# Extract data from type column
rule nuance:
    input:
        notebook = "scripts/nuanced.ipynb",
        file = "metadata/train_metadata_cleaned.csv",
    output:
        file = "metadata/train_metadata_nuanced.csv",
    params:
        file = "preprocessing.json",
    shell:
        """papermill \
            -p params_file {params.file} \
            -p input_file {input.file} \
            -p output_file {output.file} \
            {input.notebook} \
            ran/nuanced.ipynb
        """

rule numerics:
    input:
        notebook = "scripts/numerics.ipynb",
    output:
        file = "audio_touched",
    params:
        file = "preprocessing.json",
    shell:
        """
        touch audio_touched
        papermill \
            -p params_file {params.file} \
            --log-output \
            {input.notebook} \
            ran/numerics.ipynb
        """

# # Do nothing after at least Brown Owl file is unzipped
# rule all:
#     input:
#         "train_audio/brnowl/XC154984.ogg",

